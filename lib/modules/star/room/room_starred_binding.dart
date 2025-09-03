// lib/modules/star/room/room_starred_binding.dart
import 'package:get/get.dart';
import 'room_starred_controller.dart';

class RoomStarredBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomStarredController>(() => RoomStarredController());
  }
}