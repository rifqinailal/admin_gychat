import 'package:get/get.dart';
import 'away_controller.dart';

class AwayBinding extends Bindings {
  @override
  void dependencies() {
    // Inisialisasi controller menggunakan lazyPut agar lebih efisien
    Get.lazyPut<AwayController>(() => AwayController());
  }
}