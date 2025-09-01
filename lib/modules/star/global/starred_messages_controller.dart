// lib/modules/star/room/starred_messages_controller.dart
import 'package:admin_gychat/models/global_starred_message_model.dart';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_gychat/routes/app_pages.dart';

class StarredMessagesController extends GetxController {
  var starredMessages = <GlobalStarredMessage>[].obs;
  var filteredMessages = <GlobalStarredMessage>[].obs;

  var isSelectionMode = false.obs;
  var selectedMessages = <GlobalStarredMessage>[].obs;

  var isSearchActive = false.obs;
  final TextEditingController searchController = TextEditingController();

  //Mengambil instance ChatListController yang sudah ada
  final ChatListController _chatListController = Get.find<ChatListController>();

  @override
  void onInit() {
    super.onInit();
    //loadStarredMessages();
    searchController.addListener(() {
      filterMessages(searchController.text);
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadStarredMessages();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Memuat semua pesan berbintang dari semua room
  void loadStarredMessages() {
    starredMessages.clear();
    for (var chat in _chatListController.allChatsInternal) {
      final String roomId = chat.roomId.toString();
      final String roomName = chat.name;
      
      final box = GetStorage('ChatRoom_$roomId');
      final messagesJson = box.read<List>('messages_$roomId');

      if (messagesJson != null) {
        final allMessagesInRoom = messagesJson.map(
          (json) => MessageModel.fromJson(Map<String, dynamic>.from(json))
          ).toList();
        
        final starredInRoom = allMessagesInRoom.where((msg) => msg.isStarred);

        for (var msg in starredInRoom) {
          starredMessages.add(GlobalStarredMessage(
            message: msg,
            chatRoomName: roomName,
            chatRoomId: roomId,
          ));
        }
      }
    }
    starredMessages.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
    filteredMessages.assignAll(starredMessages);
    print("Total starred messages loaded: ${starredMessages.length}");
  }

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
    // Cari informasi lengkap chat room dari ChatListController
    // Ini penting agar semua argumen yang dibutuhkan RoomChatScreen terpenuhi
    final chatInfo = _chatListController.allChatsInternal.firstWhere(
      (chat) => chat.roomId.toString() == gMessage.chatRoomId,
      // orElse: () => null, // sesuaikan dengan model Chat Anda jika bisa null
    );

    // Navigasi ke RoomChatScreen dengan argumen tambahan
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

  // Menghapus semua pesan berbintang
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

  // Menghapus bintang dari SEMUA pesan
  void unstarAllMessages() {
    for (var gMsg in List<GlobalStarredMessage>.from(starredMessages)) {
      final box = GetStorage('ChatRoom_${gMsg.chatRoomId}');
      final messagesJson = box.read<List>('messages_${gMsg.chatRoomId}');

      if (messagesJson != null) {
        var messagesList = messagesJson.map(
          (json) => MessageModel.fromJson(Map<String, dynamic>.from(json))
        ).toList();
        
        var index = messagesList.indexWhere((m) => m.messageId == gMsg.message.messageId);

        if (index != -1) {
          messagesList[index] = messagesList[index].copyWith(isStarred: false);
          
          box.write('messages_${gMsg.chatRoomId}', messagesList.map((m) => m.toJson()).toList());
        }
      }
    }
    loadStarredMessages();
  }


  // Helper konfirmasi (Tidak perlu diubah)
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

  void unstarSelectedMessages() {
    for (var gMsg in selectedMessages) {
      final box = GetStorage('ChatRoom_${gMsg.chatRoomId}');
      final messagesJson = box.read<List>('messages_${gMsg.chatRoomId}');

      if (messagesJson != null) {
        var messagesList = messagesJson
            .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        
        var index = messagesList.indexWhere((m) => m.messageId == gMsg.message.messageId);

        if (index != -1) {
          messagesList[index] = messagesList[index].copyWith(isStarred: false);
          
          box.write('messages_${gMsg.chatRoomId}', messagesList.map((m) => m.toJson()).toList());
        }
      }
    }
    exitSelectionMode();
    loadStarredMessages();
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