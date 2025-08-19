// lib/modules/arsip/detail_arsip_controller.dart
import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DetailArsipController extends GetxController {
  final ChatListController _chatListController = Get.find<ChatListController>();
  var selectedArchivedChats = <ChatModel>{}.obs;

  List<ChatModel> get archivedChats =>
      _chatListController.allChatsInternal
          .where((chat) => chat.isArchived)
          .toList();

  void toggleSelection(ChatModel chat) {
    if (selectedArchivedChats.contains(chat)) {
      selectedArchivedChats.remove(chat);
    } else {
      selectedArchivedChats.add(chat);
    }
  }

  void unarchiveChats() {
    for (var chat in selectedArchivedChats) {
      chat.isArchived = false;
    }
    _chatListController.refreshChatList();

    selectedArchivedChats.clear();
  }
}
