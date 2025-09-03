// lib/modules/room_chat/room_chat_controller.dart
import 'dart:io';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_controller.dart';
import 'package:admin_gychat/modules/star/global/starred_messages_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RoomChatController extends GetxController {
  late TextEditingController messageController;
  late TextEditingController searchController;
  var messages = <MessageModel>[].obs;

  final ChatListController _chatListController = Get.find();

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
    if (searchQuery.isEmpty) return messages;
    return messages
        .where(
          (msg) =>
              msg.text?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false,
        )
        .toList();
  }

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
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
      chatRoomInfo.assignAll(Get.arguments);
      messageIdToJump = Get.arguments['jump_to_message'];
    }

    final int roomId = chatRoomInfo['id'];
    var initialMessages = _chatListController.getMessagesForRoom(roomId);
    messages.assignAll(initialMessages);

    final chat = _chatListController.allChatsInternal.firstWhere(
      (c) => c.roomId == roomId,
      orElse: () => throw "Chat not found!",
    );
    if (chat.pinnedMessageId != null) {
      try {
        pinnedMessage.value = messages.firstWhere(
          (m) => m.messageId == chat.pinnedMessageId,
        );
      } catch (e) {
        pinnedMessage.value = null;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => jumpToMessage());
  }

  @override
  void onClose() {
    messageController.removeListener(_onTextChanged);
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void sendMessage() {
    if (editingMessage.value != null) {
      updateMessage();
      return;
    }
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch,
      senderId: currentUserId,
      senderName: "Anda",
      text: text,
      repliedMessage:
          replyMessage.value != null
              ? {
                'name': replyMessage.value!.senderName,
                'text': replyMessage.value!.text ?? 'File',
                'messageId': replyMessage.value!.messageId.toString(),
              }
              : null,
      timestamp: DateTime.now(),
      isSender: true,
      type: MessageType.text,
      chatRoomId: chatRoomInfo['id'].toString(),
    );

    messages.insert(0, newMessage);
    _chatListController.addMessageToChat(chatRoomInfo['id'], newMessage);
    messageController.clear();
    cancelReply();
  }

  void starSelectedMessages() {
    for (var msg in selectedMessages) {
      var index = messages.indexWhere((m) => m.messageId == msg.messageId);
      if (index != -1) {
        // Buat objek pesan baru dengan status bintang yang diperbarui
        final updatedMessage = messages[index].copyWith(
          isStarred: !messages[index].isStarred,
        );
        // Perbarui UI lokal
        messages[index] = updatedMessage;
        // Minta controller utama untuk menyimpan perubahan
        _chatListController.updateMessageInChat(
          chatRoomInfo['id'],
          updatedMessage,
        );
      }
    }
    messages.refresh();

    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().loadStarredMessages();
    }
    clearMessageSelection();
  }

  void pinSelectedMessages() {
    if (selectedMessages.isNotEmpty) {
      final messageToPin = selectedMessages.first;
      if (pinnedMessage.value == messageToPin) {
        pinnedMessage.value = null;
        _chatListController.setPinnedMessage(chatRoomInfo['id'], null);
      } else {
        pinnedMessage.value = messageToPin;
        _chatListController.setPinnedMessage(
          chatRoomInfo['id'],
          messageToPin.messageId,
        );
      }
    }
    clearMessageSelection();
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  void deleteMessages({required bool deleteForAll}) {
    List<MessageModel> messagesToDelete = List.from(selectedMessages);

    if (!deleteForAll) {
      messages.removeWhere((msg) => messagesToDelete.contains(msg));
    } else {
      for (var msg in messagesToDelete) {
        var index = messages.indexWhere((m) => m.messageId == msg.messageId);
        if (index != -1) {
          final updatedMessage = messages[index].copyWith(isDeleted: true);
          messages[index] = updatedMessage;
          _chatListController.updateMessageInChat(
            chatRoomInfo['id'],
            updatedMessage,
          );
        }
      }
    }

    // Jika 'Hapus untuk saya', kita perlu mengupdate seluruh list pesan di ChatModel
    if (!deleteForAll) {
      final chat = _chatListController.allChatsInternal.firstWhere(
        (c) => c.roomId == chatRoomInfo['id'],
      );
      chat.messages.removeWhere((msg) => messagesToDelete.contains(msg));
    }

    _chatListController.saveChatsToStorage();
    messages.refresh();
    clearMessageSelection();
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  void updateMessage() {
    final newText = messageController.text.trim();
    if (editingMessage.value != null && newText.isNotEmpty) {
      var index = messages.indexWhere(
        (m) => m.messageId == editingMessage.value!.messageId,
      );
      if (index != -1) {
        final updatedMessage = messages[index].copyWith(text: newText);
        messages[index] = updatedMessage;
        _chatListController.updateMessageInChat(
          chatRoomInfo['id'],
          updatedMessage,
        );
      }
      messages.refresh();
      cancelEdit();
    }
  }

  // ... (Sisa kode di bawah ini sudah benar dan tidak perlu diubah) ...

  void jumpToMessage() {
    if (messageIdToJump != null && itemScrollController.isAttached) {
      final index = messages.indexWhere((m) => m.messageId == messageIdToJump);
      if (index != -1) {
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
        highlightedMessageId.value = messageIdToJump;
        Future.delayed(const Duration(seconds: 2), () {
          if (highlightedMessageId.value == messageIdToJump) {
            highlightedMessageId.value = null;
          }
        });
      }
      messageIdToJump = null;
    }
  }

  Future<void> openDocument(String path) async {
    try {
      await OpenFilex.open(path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka file. Pastikan ada aplikasi yang mendukung.',
      );
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
              onTap: () => Get.back(),
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
    _sendImage(ImageSource.camera);
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
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
          chatRoomId: chatRoomInfo['id'].toString(),
          messageId: DateTime.now().millisecondsSinceEpoch,
          senderId: currentUserId,
          senderName: "Anda",
          timestamp: DateTime.now(),
          isSender: true,
          type: MessageType.document,
          documentPath: file.path,
          documentName: file.name,
          text: file.name,
          repliedMessage:
              replyMessage.value != null
                  ? {
                    'name': replyMessage.value!.senderName,
                    'text': replyMessage.value!.text ?? 'File',
                    'messageId': replyMessage.value!.messageId.toString(),
                  }
                  : null,
        );
        messages.insert(0, newMessage);
        _chatListController.addMessageToChat(chatRoomInfo['id'], newMessage);
        cancelReply();
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
              bottom: 0,
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
                  borderRadius: BorderRadius.circular(30),
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
                          border: InputBorder.none,
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
                          final newMessage = MessageModel(
                            chatRoomId: chatRoomInfo['id'].toString(),
                            messageId: DateTime.now().millisecondsSinceEpoch,
                            senderId: currentUserId,
                            senderName: "Anda",
                            timestamp: DateTime.now(),
                            isSender: true,
                            type: MessageType.image,
                            imagePath: pickedFile.path,
                            text: captionController.text.trim(),
                            repliedMessage:
                                replyMessage.value != null
                                    ? {
                                      'name': replyMessage.value!.senderName,
                                      'text':
                                          replyMessage.value!.text ?? 'File',
                                      'messageId':
                                          replyMessage.value!.messageId
                                              .toString(),
                                    }
                                    : null,
                          );
                          messages.insert(0, newMessage);
                          _chatListController.addMessageToChat(
                            chatRoomInfo['id'],
                            newMessage,
                          );
                          Get.back();
                          cancelReply();
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
      showQuickReplies.value = true;
      final query = text.substring(1).toLowerCase();
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
      showQuickReplies.value = false;
    }
  }

  void selectQuickReply(QuickReply reply) {
    if (reply.imageFile != null) {
      final newMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch,
        senderId: currentUserId,
        senderName: "Anda",
        chatRoomId: chatRoomInfo['id'].toString(),
        timestamp: DateTime.now(),
        isSender: true,
        type: MessageType.image,
        imagePath: reply.imageFile!.path,
        text: reply.message.isNotEmpty ? reply.message : null,
        repliedMessage:
            replyMessage.value != null
                ? {
                  'name': replyMessage.value!.senderName,
                  'text': replyMessage.value!.text ?? 'File',
                  'messageId': replyMessage.value!.messageId.toString(),
                }
                : null,
      );
      messages.insert(0, newMessage);
      _chatListController.addMessageToChat(chatRoomInfo['id'], newMessage);
      messageController.clear();
      cancelReply();
    } else {
      messageController.text = reply.message;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
    }
    showQuickReplies.value = false;
  }

  void startMessageSelection(MessageModel message) {
    isMessageSelectionMode.value = true;
    selectedMessages.add(message);
  }

  void toggleMessageSelection(MessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
    if (selectedMessages.isEmpty) {
      isMessageSelectionMode.value = false;
    }
  }

  void clearMessageSelection() {
    selectedMessages.clear();
    isMessageSelectionMode.value = false;
  }

  void toggleSearchMode() {
    isSearchMode.value = !isSearchMode.value;
    if (!isSearchMode.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setReplyMessage(MessageModel message) {
    replyMessage.value = message;
  }

  void cancelReply() {
    replyMessage.value = null;
  }

  void copySelectedMessagesText() {
    String copiedText = selectedMessages.map((m) => m.text).join('\n');
    Clipboard.setData(ClipboardData(text: copiedText));
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
              const Text(
                'Hapus pesan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
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

  void setEditMessage() {
    if (selectedMessages.length == 1) {
      final messageToEdit = selectedMessages.first;
      if (messageToEdit.isSender &&
          (messageToEdit.type == MessageType.text ||
              messageToEdit.type == MessageType.image)) {
        editingMessage.value = messageToEdit;
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

  void cancelEdit() {
    editingMessage.value = null;
    messageController.clear();
  }

  void showImageFullScreen(String imagePath) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
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
                  onPressed: () => downloadImage(imagePath),
                  icon: const Icon(Icons.download, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  Future<void> downloadImage(String imagePath) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final String fileName =
            "IMG_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result = await SaverGallery.saveFile(
          androidRelativePath: "Pictures/GychatAdmin",
          filePath: imagePath,
          fileName: fileName,
          skipIfExists: true,
        );
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

  void jumpToReplyMessage(String replyMessageId) {
    try {
      final int targetMessageId = int.parse(replyMessageId);
      final index = messages.indexWhere((m) => m.messageId == targetMessageId);
      if (index != -1 && itemScrollController.isAttached) {
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        highlightedMessageId.value = targetMessageId;
        Future.delayed(const Duration(seconds: 2), () {
          if (highlightedMessageId.value == targetMessageId) {
            highlightedMessageId.value = null;
          }
        });
      } else {
        Get.snackbar(
          'Info',
          'Pesan yang direply tidak ditemukan',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Error jumping to reply message: $e');
    }
  }
}
