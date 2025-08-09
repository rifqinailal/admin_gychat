// lib/modules/auth/forgot_password/forgot_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();

  void sendResetLink() {
    String email = emailController.text;
    if (email.isNotEmpty && GetUtils.isEmail(email)) {
      Get.snackbar(
        'Success',
        'Password reset link has been sent to $email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(18),
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } else {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(18),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
