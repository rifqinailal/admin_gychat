// lib/modules/setting/profile/profile_binding.dart
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
