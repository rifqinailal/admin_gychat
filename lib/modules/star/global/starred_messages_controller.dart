// lib/modules/star/global/starred_messages_controller.dart
import 'package:admin_gychat/models/global_starred_message_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart'; // <-- HAPUS

class StarredMessagesController extends GetxController {
  var starredMessages = <GlobalStarredMessage>[].obs;
  var filteredMessages = <GlobalStarredMessage>[].obs;

  var isSelectionMode = false.obs;
  var selectedMessages = <GlobalStarredMessage>[].obs;

  var isSearchActive = false.obs;
  final TextEditingController searchController = TextEditingController();

  final ChatListController _chatListController = Get.find<ChatListController>();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      filterMessages(searchController.text);
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Memanggil load di onReady memastikan ChatListController sudah siap
    loadStarredMessages();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // --- FUNGSI DIPERBARUI TOTAL ---
  void loadStarredMessages() {
    starredMessages.clear();
    // 1. Ambil semua chat dari sumber data utama
    for (var chat in _chatListController.allChatsInternal) {
      // 2. Filter pesan berbintang dari setiap chat
      final starredInRoom = chat.messages.where((msg) => msg.isStarred && !msg.isDeleted);

      // 3. Bungkus setiap pesan berbintang ke dalam model GlobalStarredMessage
      for (var msg in starredInRoom) {
        starredMessages.add(GlobalStarredMessage(
          message: msg,
          chatRoomName: chat.name,
          chatRoomId: chat.roomId.toString(),
        ));
      }
    }
    // Urutkan berdasarkan waktu terbaru
    starredMessages.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
    filteredMessages.assignAll(starredMessages);
    print("Total global starred messages loaded: ${starredMessages.length}");
  }

  // --- FUNGSI DIPERBARUI TOTAL ---
  void unstarSelectedMessages() {
    for (var gMsg in selectedMessages) {
      // 1. Buat versi pesan yang sudah tidak berbintang
      final updatedMessage = gMsg.message.copyWith(isStarred: false);
      final int roomId = int.parse(gMsg.chatRoomId);
      
      // 2. Minta ChatListController untuk memperbarui dan menyimpan pesan
      _chatListController.updateMessageInChat(roomId, updatedMessage);
    }
    exitSelectionMode();
    // Muat ulang daftar dari sumber data yang sudah diperbarui
    loadStarredMessages();
  }

  // --- FUNGSI DIPERBARUI TOTAL ---
  void unstarAllMessages() {
    // Buat salinan list untuk menghindari error saat iterasi
    for (var gMsg in List<GlobalStarredMessage>.from(starredMessages)) {
      final updatedMessage = gMsg.message.copyWith(isStarred: false);
      final int roomId = int.parse(gMsg.chatRoomId);
      _chatListController.updateMessageInChat(roomId, updatedMessage);
    }
    exitSelectionMode();
    loadStarredMessages();
  }

  // ... (Sisa kode Anda di bawah ini sudah benar dan tidak perlu diubah) ...

  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchController.clear();
    }
  }

  void filterMessages(String query) {
    if (query.isEmpty) {
      filteredMessages.assignAll(starredMessages);
    } else {
      filteredMessages.assignAll(starredMessages.where((gMsg) =>
        (gMsg.message.senderName.toLowerCase().contains(query.toLowerCase())) ||
        (gMsg.message.text?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (gMsg.chatRoomName.toLowerCase().contains(query.toLowerCase()))));
    }
  }

  void handleMessageTap(GlobalStarredMessage message) {
    if (isSelectionMode.value) {
      toggleMessageSelection(message);
    } else {
      _navigateToOriginalMessage(message);
    }
  }

  void _navigateToOriginalMessage(GlobalStarredMessage gMessage) {
    final chatInfo = _chatListController.allChatsInternal.firstWhere(
      (chat) => chat.roomId.toString() == gMessage.chatRoomId,
    );

    Get.toNamed(
      '/room_chat',
      arguments: {
        'id': chatInfo.roomId,
        'name': chatInfo.name,
        'avatarUrl': chatInfo.urlPhoto,
        'isGroup': chatInfo.roomType == 'group',
        'jump_to_message': gMessage.message.messageId, 
      },
    );
  }

  void handleMessageLongPress(GlobalStarredMessage message) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
    toggleMessageSelection(message);
  }

  void toggleMessageSelection(GlobalStarredMessage message) {
    message.isSelected.toggle();
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }

    if (selectedMessages.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    for (var msg in selectedMessages) {
      msg.isSelected.value = false;
    }
    selectedMessages.clear();
  }

  void confirmDeleteAll() {
    if (starredMessages.isEmpty) {
      Get.snackbar(
        'Info', 
        'Tidak ada pesan berbintang.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.primary.withOpacity(0.6),
        colorText: ThemeColor.white,
      );
      return;
    }

    _showDeleteDialog(
      title: 'Hapus Bintang dari Semua Pesan?',
      onConfirm: () {
        unstarAllMessages();
        Get.back();
      },
    );
  }

  void _showDeleteDialog({required String title, required VoidCallback onConfirm}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.white,
              foregroundColor: ThemeColor.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: ThemeColor.primary,
                  width: 1
                ),
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primary,
              foregroundColor: ThemeColor.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onConfirm,
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void confirmUnstarSelected() {
    if (selectedMessages.isEmpty) return;
    _showConfirmationDialog(
      title: 'Hapus ${selectedMessages.length} Bintang?',
      onConfirm: () {
        unstarSelectedMessages();
        Get.back();
      },
    );
  }

  void _showConfirmationDialog({required String title, required VoidCallback onConfirm}) {
     Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.white,
              foregroundColor: ThemeColor.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide(
                  color: ThemeColor.primary,
                  width: 1
                ),
            ),
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primary,
              foregroundColor: ThemeColor.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onConfirm,
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}