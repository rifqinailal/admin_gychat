// lib/app/modules/setting/away_message/away_binding.dart
import 'package:get/get.dart';
import 'away_controller.dart';

class AwayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AwayController>(() => AwayController());
  }
}