// lib/modules/arsip/detail_arsip_binding.dart
import 'package:get/get.dart';
import 'detail_arsip_controller.dart';

class DetailArsipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailArsipController>(() => DetailArsipController());
  }
}