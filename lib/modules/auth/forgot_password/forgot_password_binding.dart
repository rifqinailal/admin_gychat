// lib/modules/auth/forgot_password/forgot_password_binding.dart
import 'package:get/get.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}
