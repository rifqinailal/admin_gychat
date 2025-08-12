// lib/app/modules/room_chat/room_chat_controller.dart

import 'package:admin_gychat/data/models/message_model.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// Import model yang baru kita buat

class RoomChatController extends GetxController {
  // `TextEditingController` adalah cara standar Flutter untuk mengelola
  // input pada sebuah `TextField`.
  late TextEditingController messageController;
  late TextEditingController searchController;

  // Variabel untuk menyimpan semua pesan dalam chat room ini.
  // Kita bungkus dengan .obs agar UI bisa reaktif.
  var messages = <MessageModel>[].obs;
  final String currentUserId = "admin_01";
  var chatRoomInfo = {}.obs;

  // Penanda apakah mode search sedang aktif atau tidak.
  var isSearchMode = false.obs;
  // Menyimpan kata kunci yang sedang dicari.
  var searchQuery = ''.obs;
  var isMessageSelectionMode = false.obs;
  // Menyimpan pesan-pesan yang dipilih.
  var selectedMessages = <MessageModel>{}.obs;
  var pinnedMessage = Rxn<MessageModel>();
  // Variabel untuk mengakses data dari QuickController.
  late QuickController quickController;
  // Penanda untuk menampilkan/menyembunyikan box quick reply.
  var showQuickReplies = false.obs;
  // List untuk menampung hasil filter.
  var filteredQuickReplies = <QuickReply>[].obs;
  var replyMessage = Rxn<MessageModel>();

  // Di dalam getter `filteredMessages` di RoomChatController
List<MessageModel> get filteredMessages {
  if (searchQuery.isEmpty) {
    return messages;
  } else {
    return messages.where((msg) {
      // JIKA PESAN TIDAK PUNYA TEKS (misal: gambar), JANGAN TAMPILKAN DI HASIL SEARCH
      if (msg.text == null) return false;
      
      // JIKA PUNYA TEKS, LAKUKAN PENGECEKAN SEPERTI BIASA
      return msg.text!.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }
}

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller untuk text field.
    messageController = TextEditingController();
    searchController = TextEditingController();
    // Inisialisasi QuickController. `Get.find()` akan mencari instance
    // yang sudah dibuat oleh teman Anda.
    quickController = Get.find<QuickController>();

    // Tambahkan "pendengar" ke inputan pesan.
    // Fungsi `_onTextChanged` akan dijalankan setiap kali ada perubahan.
    messageController.addListener(_onTextChanged);
    // Panggil data pesan saat halaman pertama kali dibuka.
    if (Get.arguments != null) {
      chatRoomInfo.value = Get.arguments as Map<String, dynamic>;
    }
    fetchMessages();
  }

  @override
  void onClose() {
    // Penting! Selalu dispose controller untuk mencegah memory leak.
    messageController.removeListener(_onTextChanged);
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void pickImage() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2738a5),),
              title: const Text('Galeri'),
              onTap: () {
                Get.back(); // Tutup bottom sheet
                _sendImage(ImageSource.gallery,); // Kirim dari galeri
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera,color: Color(0xFF2738a5)),
              title: const Text('Kamera'),
              onTap: () {
                Get.back(); // Tutup bottom sheet
                _sendImage(ImageSource.camera); // Kirim dari kamera
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi internal untuk mengambil dan "mengirim" gambar
  Future<void> _sendImage(ImageSource source) async {
    try {
      // 1. Ambil gambar menggunakan image_picker
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);

      // 2. Cek apakah user memilih gambar
      if (pickedFile != null) {
        // 3. Buat objek MessageModel baru dengan tipe gambar
        final newMessage = MessageModel(
          senderId: currentUserId,
          senderName: "Anda",
          timestamp: DateTime.now(),
          isSender: true,
          type: MessageType.image, // Tipe pesan adalah gambar
          imagePath: pickedFile.path, // Simpan path file-nya
        );

        // 4. Tambahkan ke daftar pesan
        messages.insert(0, newMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  void _onTextChanged() {
    final text = messageController.text;
    // Cek apakah teks dimulai dengan "/"
    if (text.startsWith('/')) {
      showQuickReplies.value = true; // Tampilkan box
      final query = text.substring(1).toLowerCase(); // Ambil teks setelah "/"

      // Jika tidak ada query, tampilkan semua.
      if (query.isEmpty) {
        filteredQuickReplies.assignAll(quickController.quickReplies);
      } else {
        // Jika ada query, filter berdasarkan shortcut.
        filteredQuickReplies.assignAll(
          quickController.quickReplies.where(
            (reply) => reply.shortcut!.toLowerCase().contains(query),
          ),
        );
      }
    } else {
      showQuickReplies.value = false; // Sembunyikan box
    }
  }

  // FUNGSI BARU: Dipanggil saat salah satu quick reply dipilih.
  void selectQuickReply(QuickReply reply) {
    // Ganti teks di inputan dengan pesan dari quick reply.
    messageController.text = reply.message;
    // Pindahkan cursor ke akhir teks.
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: messageController.text.length),
    );
    // Sembunyikan kembali box quick reply.
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
        senderId: "pimpinan_A",
        senderName: "Pimpinan A",
        text: "the leader added an answer",
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        isSender: false,
        type: MessageType.text, // <-- TAMBAHKAN INI
      ),
      MessageModel(
        senderId: "user_02",
        senderName: "Admin A",
        text: "Thank you",
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isSender: false,
        type: MessageType.text, // <-- TAMBAHKAN INI
        repliedMessage: {"name": "Anda", "text": "Admin message"},
      ),
      MessageModel(
        senderId: currentUserId,
        senderName: "Anda",
        text: "Admin message",
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        isSender: true,
        type: MessageType.text, // <-- TAMBAHKAN INI
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
  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isNotEmpty) {
      // Siapkan data pesan yang di-reply, jika ada.
      final Map<String, String>? repliedMessageData =
          replyMessage.value != null
              ? {
                'name': replyMessage.value!.senderName,
                'text': replyMessage.value!.text ?? 'Gambar',
              }
              : null;
      final newMessage = MessageModel(
        senderId: currentUserId,
        senderName: "Anda", // BARU: Tambahkan nama pengirim
        text: text,
        repliedMessage: repliedMessageData,
        timestamp: DateTime.now(),
        isSender: true,
         type: MessageType.text, 
      );
      messages.insert(0, newMessage);
      messageController.clear();
      cancelReply();
    }
  }

  // Fungsi untuk memberi/menghapus bintang pada pesan yang dipilih
  void starSelectedMessages() {
    // Kita iterasi setiap pesan yang dipilih
    for (var selectedMessage in selectedMessages) {
      // Cari indeks pesan tersebut di list utama
      var index = messages.indexWhere((m) => m == selectedMessage);
      if (index != -1) {
        // Buat salinan pesan dengan status isStarred yang dibalik
        messages[index] = messages[index].copyWith(
          isStarred: !messages[index].isStarred,
        );
      }
    }
    // `refresh()` memberitahu UI untuk update
    messages.refresh();
    // Setelah selesai, bersihkan seleksi
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

    // Kita tidak lagi mengubah properti `isPinned` di setiap pesan,
    // karena hanya ada satu pin global per room chat.

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
}
