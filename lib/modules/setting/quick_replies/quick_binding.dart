import 'package:get/get.dart';
import 'quick_controller.dart';

class QuickBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuickController>(() => QuickController());
  }
}