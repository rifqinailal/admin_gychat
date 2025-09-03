// lib/modules/star/room/room_starred_controller.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class RoomStarredController extends GetxController {
  final ChatListController _chatListController = Get.find();

  var starredMessages = <MessageModel>[].obs;
  var filteredMessages = <MessageModel>[].obs;
  var isSelectionMode = false.obs;
  var selectedMessages = <MessageModel>{}.obs;
  var isSearchActive = false.obs;
  final TextEditingController searchController = TextEditingController();

  late int roomId; // Tipe data sudah benar (int)
  late String roomName;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      // --- PERBAIKAN DI SINI ---
      // Mengonversi argumen 'roomId' menjadi int secara aman
      roomId = Get.arguments['roomId'] is int
          ? Get.arguments['roomId']
          : int.parse(Get.arguments['roomId'].toString());
      // ------------------------

      roomName = Get.arguments['roomName'];
      loadStarredMessages();
    }
    searchController.addListener(() {
      filterMessages(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void loadStarredMessages() {
    final allMessages = _chatListController.getMessagesForRoom(roomId);
    final starred = allMessages.where((msg) => msg.isStarred && !msg.isDeleted).toList();
    starred.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    starredMessages.assignAll(starred);
    filteredMessages.assignAll(starredMessages);
  }

  void unstarMessages(List<MessageModel> messagesToUnstar) {
    for (var msgToUnstar in messagesToUnstar) {
      final updatedMessage = msgToUnstar.copyWith(isStarred: false);
      _chatListController.updateMessageInChat(roomId, updatedMessage);
    }

    if (Get.isRegistered<RoomChatController>()) {
      final roomChatController = Get.find<RoomChatController>();
      if (roomChatController.chatRoomInfo['id'] == roomId) {
        for (var msgToUnstar in messagesToUnstar) {
           var index = roomChatController.messages.indexWhere((m) => m.messageId == msgToUnstar.messageId);
           if (index != -1) {
             roomChatController.messages[index] = roomChatController.messages[index].copyWith(isStarred: false);
           }
        }
        roomChatController.messages.refresh();
      }
    }

    exitSelectionMode();
    loadStarredMessages();
  }

  // ... (Sisa kode Anda di bawah ini tidak perlu diubah) ...
  
  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchController.clear();
      filteredMessages.assignAll(starredMessages);
    }
  }

  void filterMessages(String query) {
    if (query.isEmpty) {
      filteredMessages.assignAll(starredMessages);
    } else {
      filteredMessages.assignAll(starredMessages.where((msg) =>
          (msg.senderName.toLowerCase().contains(query.toLowerCase())) ||
          (msg.text?.toLowerCase().contains(query.toLowerCase()) ?? false)));
    }
  }

  void handleMessageTap(MessageModel message) {
    if (isSelectionMode.value) {
      toggleMessageSelection(message);
    }
  }

  void handleMessageLongPress(MessageModel message) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
    toggleMessageSelection(message);
  }

  void toggleMessageSelection(MessageModel message) {
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
    selectedMessages.clear();
  }

  void confirmUnstarSelected() {
    if (selectedMessages.isEmpty) return;
    _showDeleteDialog(
      title: 'Hapus Bintang dari ${selectedMessages.length} Pesan?',
      onConfirm: () {
        unstarMessages(selectedMessages.toList());
        Get.back();
        Get.snackbar(
          'Success', 
          'Berhasil menghapus bintang dari pesan yang dipilih',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: ThemeColor.white,
        );
      },
    );
  }

  void confirmUnstarAllInRoom() {
    if (starredMessages.isEmpty) {
       Get.snackbar(
        'Info', 
        'Tidak ada pesan berbintang di room ini.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.primary.withOpacity(0.8),
        colorText: ThemeColor.white,
      );
      return;
    }
    _showDeleteDialog(
      title: 'Hapus Semua Bintang ?',
      onConfirm: () {
        unstarMessages(starredMessages.toList());
        Get.back();
        Get.snackbar(
          'Success', 
          'Berhasil menghapus semua bintang yang ada di room ini.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: ThemeColor.white,
        );
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
                side: const BorderSide(color: ThemeColor.primary, width: 1),
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
}