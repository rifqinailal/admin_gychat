// lib/modules/room_chat/room_chat_binding.dart
import 'package:admin_gychat/modules/setting/quick_replies/quick_controller.dart';
import 'package:get/get.dart';
import 'room_chat_controller.dart';

class RoomChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomChatController>(() => RoomChatController());
    Get.lazyPut<QuickController>(() => QuickController());
  }
}