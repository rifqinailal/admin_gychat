// lib/modules/grup/detail_grup/detail_grup_binding.dart
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

class DetailGrupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailGrupController>(() => DetailGrupController());
  }
}