// lib/modules/star/room/room_starred_controller.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_controller.dart';
import 'package:admin_gychat/modules/star/room/room_starred_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:async';

class RoomStarredController extends GetxController {
  // Variabel untuk data
  var starredMessages = <MessageModel>[].obs;
  var filteredMessages = <MessageModel>[].obs;

  var messages = <MessageModel>[].obs;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  var highlightedMessageId = Rxn<String>();

  void goToStarredMessages() async {
    final result = await Get.to(
      () => const RoomStarredScreen(),
      arguments: {
        'roomId': roomId,
        'roomName': roomName,
      },
    );
    if (result != null && result is String) {
      jumpToMessage(result);
    }
  }
  void jumpToMessage(String messageId) {
    final index = filteredMessages.indexWhere((msg) => msg.messageId == messageId);

    if (index != -1 && itemScrollController.isAttached) {
      highlightedMessageId.value = messageId;
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5, // 0.5 agar pesan berada di tengah layar
      );
      // Hapus highlight setelah beberapa detik
      Timer(const Duration(seconds: 3), () {
        if (highlightedMessageId.value == messageId) {
          highlightedMessageId.value = null;
        }
      });
    } else {
      Get.snackbar(
        'Info', 
        'Pesan mungkin tidak ada lagi di halaman ini.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.primary.withOpacity(0.8),
        colorText: ThemeColor.white,
      );
    }
  }

  // Variabel untuk mode seleksi
  var isSelectionMode = false.obs;
  var selectedMessages = <MessageModel>{}.obs;

  // Variabel untuk mode pencarian
  var isSearchActive = false.obs;
  final TextEditingController searchController = TextEditingController();

  // Info room
  late String roomId;
  late String roomName;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      roomId = Get.arguments['roomId'];
      roomName = Get.arguments['roomName'];
      loadStarredMessages();
    }
    // Search bar
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
    starredMessages.clear();
    final box = GetStorage('ChatRoom_$roomId');
    final messagesJson = box.read<List>('messages_$roomId');

    if (messagesJson != null) {
      final allMessages = messagesJson
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      //final starred = allMessages.where((msg) => msg.isStarred && !msg.isDeleted).toList();
      final starred = allMessages.where((msg) => msg.isStarred && !msg.isDeleted).toList();
      starred.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      starredMessages.assignAll(starred);
      filteredMessages.assignAll(starredMessages);
    }
    print("Total starred messages in room $roomId: ${starredMessages.length}");
  }

  // Pencarian
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
    } else {
      Get.back(result: message.messageId);
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

  // Hapus Bintang dari pesan yang dipilih
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

  // Hapus Bintang dari SEMUA pesan di room ini
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
        unstarMessages(starredMessages);
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

  // Fungsi inti untuk menghapus bintang
  void unstarMessages(List<MessageModel> messagesToUnstar) {
    final box = GetStorage('ChatRoom_$roomId');
    final messagesJson = box.read<List>('messages_$roomId');

    if (messagesJson != null) {
      var messagesList = messagesJson
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      for (var msgToUnstar in messagesToUnstar) {
        var index = messagesList.indexWhere((m) => m.messageId == msgToUnstar.messageId);
        if (index != -1) {
          messagesList[index] = messagesList[index].copyWith(isStarred: false);
        }
      }
      
      box.write('messages_$roomId', messagesList.map((m) => m.toJson()).toList());
    }

    // Update state
    if (Get.isRegistered<RoomChatController>()) {
      Get.find<RoomChatController>().refreshMessagesFromStorage();
    }
    exitSelectionMode();
    loadStarredMessages();
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