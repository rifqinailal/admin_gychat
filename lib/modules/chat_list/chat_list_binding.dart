// lib/app/modules/chat_list/chat_list_binding.dart
import 'package:get/get.dart';
import 'chat_list_controller.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatListController>(() => ChatListController());
  }
}