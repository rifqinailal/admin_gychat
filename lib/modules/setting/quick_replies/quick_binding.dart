import 'package:get/get.dart';
import 'quick_controller.dart';

class QuickBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan QuickController agar bisa diakses di QuickScreen
    Get.lazyPut<QuickController>(() => QuickController());
  }
}