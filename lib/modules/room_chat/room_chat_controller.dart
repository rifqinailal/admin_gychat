// lib/modules/room_chat/room_chat_controller.dart
import 'dart:io';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:admin_gychat/modules/star/global/starred_messages_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RoomChatController extends GetxController {
  late TextEditingController messageController;
  late TextEditingController searchController;
  var messages = <MessageModel>[].obs;
  late GetStorage _box;
  String get _boxKey => 'messages_${chatRoomInfo["id"]}';
  final String currentUserId = "admin_01";
  var chatRoomInfo = {}.obs;
  var isSearchMode = false.obs;
  var searchQuery = ''.obs;
  var isMessageSelectionMode = false.obs;
  var selectedMessages = <MessageModel>{}.obs;
  var pinnedMessage = Rxn<MessageModel>();
  late QuickController quickController;
  var showQuickReplies = false.obs;
  var filteredQuickReplies = <QuickReply>[].obs;
  var replyMessage = Rxn<MessageModel>();
  var editingMessage = Rxn<MessageModel>();

  List<MessageModel> get filteredMessages {
    if (searchQuery.isEmpty) {
      return messages;
    } else {
      return messages.where((msg) {
        if (msg.text == null) return false;
        return msg.text!.toLowerCase().contains(
          searchQuery.value.toLowerCase(),
        );
      }).toList();
    }
  }

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int? messageIdToJump;
  var highlightedMessageId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    searchController = TextEditingController();
    quickController = Get.find<QuickController>();
    messageController.addListener(_onTextChanged);
    if (Get.arguments is Map<String, dynamic>) {
      final Map<String, dynamic> arguments = Get.arguments;
      chatRoomInfo.assignAll(arguments);
      messageIdToJump = arguments['jump_to_message'];
    }
    final roomId = Get.arguments?['id'] ?? 'default_room';
    _box = GetStorage('ChatRoom_$roomId');
    loadMessagesFromStorage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      jumpToMessage();
    });

    debounce(
      messages,
      (_) => saveMessagesToStorage(),
      time: const Duration(seconds: 1),
    );

    // fetchMessages();
  }

  void jumpToMessage() {
    if (messageIdToJump != null && itemScrollController.isAttached) {
      // 1. Cari index pesan di dalam list
      final index = messages.indexWhere((m) => m.messageId == messageIdToJump);

      if (index != -1) {
        // 2. Scroll ke index tersebut
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );

        // 3. (Opsional) Beri efek highlight sementara
        highlightedMessageId.value = messageIdToJump;
        Future.delayed(const Duration(seconds: 2), () {
          // Hilangkan highlight setelah 2 detik
          if (highlightedMessageId.value == messageIdToJump) {
            highlightedMessageId.value = null;
          }
        });
      }
      
      // Bersihkan agar tidak melompat lagi jika ada rebuild
      messageIdToJump = null;
    }
  }
  
  @override
  void onClose() {
    saveMessagesToStorage();
    messageController.removeListener(_onTextChanged);
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> openDocument(String path) async {
    // `OpenFilex.open()` akan membuka file menggunakan aplikasi default
    try {
      final result = await OpenFilex.open(path);
      print(result.message); // Untuk debugging
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka file. Pastikan ada aplikasi yang mendukung.',
      );
    }
  }

  // Fungsi ini akan dipanggil dari luar untuk me-refresh data pesan
  void refreshMessagesFromStorage() {
    print("Refreshing messages for room ${_boxKey}...");
    loadMessagesFromStorage();
  }

  // FUNGSI BARU: Untuk menyimpan pesan ke local storage
  void saveMessagesToStorage() {
    List<Map<String, dynamic>> messagesJson =
        messages.map((msg) => msg.toJson()).toList();
    _box.write(_boxKey, messagesJson);

    // ======================================================
    // PENAMBAHAN BARU: SIMPAN ID PESAN YANG DI-PIN
    // ======================================================
    if (pinnedMessage.value != null) {
      // Kita simpan ID-nya saja, bukan seluruh objek pesan.
      _box.write('pinnedMessageId', pinnedMessage.value!.messageId);
    } else {
      // Jika tidak ada yang di-pin, hapus key-nya dari storage.
      _box.remove('pinnedMessageId');
    }
    // ======================================================

    print("Messages and pin status for room ${_boxKey} saved!");
  }

  // FUNGSI BARU: Untuk membaca pesan dari local storage
  void loadMessagesFromStorage() {
    var messagesJson = _box.read<List>(_boxKey);
    if (messagesJson != null) {
      messages.value = messagesJson.map(
        (json) => MessageModel.fromJson(Map<String, dynamic>.from(json)),
      ).toList();

      // ======================================================
      // PENAMBAHAN BARU: BACA DAN SET PESAN YANG DI-PIN
      // ======================================================
      // 1. Baca ID yang tersimpan.
      var pinnedId = _box.read<int>('pinnedMessageId');
      if (pinnedId != null) {
        // 2. Cari pesan di dalam daftar `messages` yang ID-nya cocok.
        try {
          pinnedMessage.value = messages.firstWhere(
            (msg) => msg.messageId == pinnedId,
          );
        } catch (e) {
          // Jika pesan tidak ditemukan (mungkin terhapus), biarkan null.
          pinnedMessage.value = null;
        }
      }
      // ======================================================

      print("Messages and pin status for room ${_boxKey} loaded!");
    } else {
      fetchMessages();
      print("No messages in storage for room ${_boxKey}. Loading dummy messages.");
      //messages.clear();
    }
  }

  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: SizedBox.shrink(),
              trailing: Icon(Icons.close, color: Colors.black),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              trailing: const Icon(
                Icons.photo_library,
                color: Colors.blueAccent,
              ),
              leading: const Text(
                'Choose images',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
              onTap: () {
                Get.back();
                _sendImage(ImageSource.gallery);
              },
            ),
            const Divider(height: 1, thickness: 1),
            ListTile(
              trailing: const Icon(Icons.insert_drive_file, color: Colors.red),
              leading: const Text(
                'Choose dokumen',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
              onTap: () {
                Get.back();
                _sendDocument();
              },
            ),
            const Divider(height: 1, thickness: 1),
            SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  void takePicture() {
    _sendImage(ImageSource.camera); // Langsung panggil kamera
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      // 1. Ambil gambar menggunakan image_picker
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);

      // 2. Cek apakah user memilih gambar
      if (pickedFile != null) {
        // 3. Tampilkan halaman pratinjau untuk menambahkan caption
        _showImagePreview(pickedFile);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  Future<void> _sendDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final PlatformFile file = result.files.first;

        final newMessage = MessageModel(
          chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(),
          messageId: DateTime.now().millisecondsSinceEpoch,
          senderId: currentUserId,
          senderName: "Anda",
          timestamp: DateTime.now(),
          isSender: true,
          type: MessageType.document,
          documentPath: file.path,
          documentName: file.name,
          text: file.name,
        );

        messages.insert(0, newMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih dokumen: $e');
    }
  }

  Future<void> _showImagePreview(XFile pickedFile) async {
    final TextEditingController captionController = TextEditingController();
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(pickedFile.path), fit: BoxFit.scaleDown),
            Positioned(
              top: 40, // Jarak dari atas
              left: 16, // Jarak dari kiri
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0, // Tempelkan di bagian paling bawah
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30), // Sudut melengkung
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan keterangan...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none, // Hilangkan garis bawah
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.send,
                          color: ThemeColor.primary,
                        ),
                        onPressed: () {
                          final imagePath = pickedFile.path;
                          final caption = captionController.text.trim();
                          final newMessage = MessageModel(
                            chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(),
                            messageId: DateTime.now().millisecondsSinceEpoch,
                            senderId: currentUserId,
                            senderName: "Anda",
                            timestamp: DateTime.now(),
                            isSender: true,
                            type: MessageType.image,
                            imagePath: imagePath,
                            text: caption,
                          );
                          messages.insert(0, newMessage);
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _onTextChanged() {
    final text = messageController.text;
    if (text.startsWith('/')) {
      showQuickReplies.value = true; // Tampilkan box
      final query = text.substring(1).toLowerCase(); // Ambil teks setelah "/"
      if (query.isEmpty) {
        filteredQuickReplies.assignAll(quickController.quickReplies);
      } else {
        filteredQuickReplies.assignAll(
          quickController.quickReplies.where(
            (reply) => reply.shortcut.toLowerCase().contains(query),
          ),
        );
      }
    } else {
      showQuickReplies.value = false; // Sembunyikan box
    }
  }

  // FUNGSI BARU: Dipanggil saat salah satu quick reply dipilih.
  void selectQuickReply(QuickReply reply) {
    messageController.text = reply.message;
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: messageController.text.length),
    );
    showQuickReplies.value = false;
  }

  // Fungsi untuk memulai mode seleksi (dipanggil saat long-press).
  void startMessageSelection(MessageModel message) {
    isMessageSelectionMode.value = true;
    selectedMessages.add(message);
  }

  // Fungsi untuk memilih/batal memilih pesan (dipanggil saat tap).
  void toggleMessageSelection(MessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
    // Jika tidak ada lagi pesan yang dipilih, keluar dari mode seleksi.
    if (selectedMessages.isEmpty) {
      isMessageSelectionMode.value = false;
    }
  }

  // Fungsi untuk membersihkan semua pilihan (dipanggil dari AppBar).
  void clearMessageSelection() {
    selectedMessages.clear();
    isMessageSelectionMode.value = false;
  }

  // Fungsi untuk masuk/keluar dari mode search.
  void toggleSearchMode() {
    isSearchMode.value = !isSearchMode.value;
    if (!isSearchMode.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  // Fungsi untuk memperbarui kata kunci pencarian setiap kali user mengetik.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Fungsi untuk mengambil data pesan (simulasi dari API)
  void fetchMessages() {
    var dummyMessages = [
      MessageModel(
        chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(),
        messageId: 6,
        senderId: "pimpinan_A",
        senderName: "Pimpinan A",
        text: "the leader added an answer",
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        isSender: false,
        type: MessageType.text,
      ),
      MessageModel(
        chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(),
        messageId: 7,
        senderId: "user_02",
        senderName: "Admin A",
        text: "Thank you",
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isSender: false,
        type: MessageType.text,
        repliedMessage: {"name": "Anda", "text": "Admin message", "messageId": "123"},
      ),
      MessageModel(
        chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(),
        messageId: 8,
        senderId: currentUserId,
        senderName: "Anda",
        text: "Admin message",
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        isSender: true,
        type: MessageType.text,
      ),
    ];
    messages.assignAll(dummyMessages);
  }

  // Fungsi untuk mengatur pesan mana yang akan di-reply.
  // Ini akan dipanggil saat user menggeser bubble chat.
  void setReplyMessage(MessageModel message) {
    replyMessage.value = message;
  }

  // Fungsi untuk membatalkan mode reply (saat tombol 'X' ditekan).
  void cancelReply() {
    replyMessage.value = null;
  }

  // Fungsi untuk mengirim pesan baru
  void _sendImageWithCaption(XFile pickedFile, String caption) {
    final imagePath = pickedFile.path;
    final newMessage = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch,
      senderId: currentUserId,
      senderName: "Anda",
      chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(), 
      timestamp: DateTime.now(),
      isSender: true,
      type: MessageType.image,
      imagePath: imagePath,
      text: caption.isNotEmpty ? caption : null, 
    );
    messages.insert(0, newMessage);
  }

  void _sendDocumentFromPicker(PlatformFile file) {
       final newMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch,
        senderId: currentUserId,
        senderName: "Anda",
        // TAMBAHKAN INI
        chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(),
        timestamp: DateTime.now(),
        isSender: true,
        type: MessageType.document,
        documentPath: file.path,
        documentName: file.name,
        // text bisa diisi nama file atau null
        text: file.name, 
      );
      messages.insert(0, newMessage);
  }

  void sendMessage() {
    if (editingMessage.value != null) {
      updateMessage();
      return;
    }
    final text = messageController.text.trim();

    if (text.isNotEmpty) {
      final Map<String, String>? repliedMessageData = replyMessage.value != null
          ? {'name': replyMessage.value!.senderName, 'text': replyMessage.value!.text ?? 'File'}
          : null;
      final newMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch,
        senderId: currentUserId,
        senderName: "Anda",
        text: text,
        repliedMessage: repliedMessageData,
        timestamp: DateTime.now(),
        isSender: true,
        type: MessageType.text,
        chatRoomId: (chatRoomInfo['id'] ?? 'unknown_room').toString(), 
      );
      messages.insert(0, newMessage);
      messageController.clear();
      cancelReply();
    }
  }

  // Fungsi Star
  void starSelectedMessages() { 
    for (var selectedMessage in selectedMessages) { 
      var index = messages.indexWhere((m) => m == selectedMessage);
      if (index != -1) { 
        messages[index] = messages[index].copyWith(
          isStarred: !messages[index].isStarred,
        );
      }
    }
    messages.refresh();

    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().loadStarredMessages();
    }
    saveMessagesToStorage(); 
    clearMessageSelection();
  }

  // Fungsi untuk memberi/menghapus pin pada pesan yang dipilih
  void pinSelectedMessages() {
    // Untuk saat ini, kita hanya bisa pin satu pesan.
    // Ambil pesan pertama dari yang dipilih.
    if (selectedMessages.isNotEmpty) {
      final messageToPin = selectedMessages.first;

      // Cek: jika pesan yang dipilih sudah di-pin, maka unpin.
      // Jika belum, maka pin pesan tersebut.
      if (pinnedMessage.value == messageToPin) {
        pinnedMessage.value = null; // Unpin
      } else {
        pinnedMessage.value = messageToPin; // Pin
      }
    }
    saveMessagesToStorage(); 
    clearMessageSelection();
  }

  // Fungsi untuk menyalin teks pesan yang dipilih
  void copySelectedMessagesText() {
    // Gabungkan teks dari semua pesan yang dipilih, pisahkan dengan baris baru
    String copiedText = selectedMessages.map((m) => m.text).join('\n');
    // Salin ke clipboard
    Clipboard.setData(ClipboardData(text: copiedText));
    // Beri feedback ke user
    Get.snackbar('Disalin', 'Teks pesan telah disalin ke clipboard.');
    clearMessageSelection();
  }

  void showDeleteConfirmationDialog() {
    bool canDeleteForAll = selectedMessages.every((msg) => msg.isSender);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              const Text(
                'Hapus pesan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),

              // Tombol-tombol
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canDeleteForAll)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          deleteMessages(deleteForAll: true);
                        },
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Hapus untuk semua orang',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: ThemeColor.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        deleteMessages(deleteForAll: false);
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Hapus untuk saya',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemeColor.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Batal',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemeColor.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Fungsi utama untuk menjalankan aksi hapus
  void deleteMessages({required bool deleteForAll}) {
    // Jika "Hapus untuk saya"
    if (!deleteForAll) {
      // Langsung hapus pesan dari daftar
      messages.removeWhere((msg) => selectedMessages.contains(msg));
    }
    // Jika "Hapus untuk semua orang"
    else {
      // Jangan hapus, tapi ubah statusnya
      for (var selectedMessage in selectedMessages) {
        var index = messages.indexWhere((m) => m == selectedMessage);
        if (index != -1) {
          // Buat salinan pesan dengan status isDeleted = true
          messages[index] = messages[index].copyWith(isDeleted: true);
        }
      }
    }
    saveMessagesToStorage(); 
    messages.refresh();
    clearMessageSelection();
  }

  void setEditMessage() {
    if (selectedMessages.length == 1) {
      final messageToEdit = selectedMessages.first;
      if (messageToEdit.isSender &&
          (messageToEdit.type == MessageType.text ||
              messageToEdit.type == MessageType.image)) {
        editingMessage.value = messageToEdit;
        // Isi inputan dengan teks/caption yang sudah ada (atau string kosong jika belum ada).
        messageController.text = messageToEdit.text ?? '';
        messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length),
        );
        clearMessageSelection();
      } else {
        Get.snackbar(
          'Info',
          'Hanya pesan teks atau gambar Anda yang bisa diedit.',
        );
        clearMessageSelection();
      }
    }
  }

  // 2. Fungsi untuk membatalkan mode edit.
  void cancelEdit() {
    editingMessage.value = null;
    messageController.clear();
  }

  // 3. Fungsi untuk memperbarui pesan.
  void updateMessage() {
    final newText = messageController.text.trim();
    // Pastikan ada pesan yang sedang diedit dan teks barunya tidak kosong.
    if (editingMessage.value != null && newText.isNotEmpty) {
      // Cari indeks pesan yang akan diupdate.
      var index = messages.indexWhere((m) => m == editingMessage.value);
      if (index != -1) {
        // Buat salinan pesan dengan teks yang baru.
        messages[index] = messages[index].copyWith(text: newText);
      }
      messages.refresh();
      saveMessagesToStorage();
      cancelEdit();
    }
  }

  void showImageFullScreen(String imagePath) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true, // Aktifkan pan
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(File(imagePath)),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () {
                    downloadImage(imagePath);
                  }, 
                  icon: const Icon(Icons.download, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      // Gunakan `barrierColor` untuk kontrol penuh atas latar belakang
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  Future<void> downloadImage(String imagePath) async {
    // Meminta izin penyimpanan
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        // Membuat nama file yang unik berdasarkan waktu
        final String fileName =
            "IMG_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result = await SaverGallery.saveFile(
          androidRelativePath: "Pictures/GychatAdmin",
          filePath: imagePath,
          fileName: fileName,
          skipIfExists: true,
        );
        // ===============================================

        if (result.isSuccess) {
          Get.snackbar('Berhasil', 'Gambar berhasil disimpan di galeri.');
        } else {
          Get.snackbar(
            'Gagal',
            'Tidak dapat menyimpan gambar: ${result.errorMessage}',
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan gambar.');
      }
    } else {
      Get.snackbar(
        'Izin Ditolak',
        'Izin akses penyimpanan dibutuhkan untuk menyimpan gambar.',
      );
    }
  }
}
