// lib/app/modules/grup/grup_baru/grup_baru_binding.dart
import 'package:get/get.dart';
import 'grup_baru_controller.dart';

class GrupBaruBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GrupBaruController>(() => GrupBaruController(),
    );
  }
}