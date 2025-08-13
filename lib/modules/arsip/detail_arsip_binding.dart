
import 'package:get/get.dart';
import 'detail_arsip_controller.dart';

class DetailArsipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailArsipController>(() => DetailArsipController());
  }
}