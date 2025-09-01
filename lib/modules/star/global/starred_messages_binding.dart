// lib/modules/star/global/starred_messages_binding.dart
import 'package:get/get.dart';
import 'starred_messages_controller.dart';

class StarredMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StarredMessagesController>(() => StarredMessagesController(), fenix: true);
  }
}