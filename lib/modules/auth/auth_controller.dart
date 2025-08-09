// lib/modules/auth/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/routes/app_routes.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final showLoginCard = false.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  /// Displays the login form card with an animation.
  void displayLoginCard() {
    showLoginCard.value = true;
  }

  /// Hides the login form card.
  void hideLoginCard() {
    showLoginCard.value = false;
  }

  /// Toggles the visibility of the password in its text field.
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Handles the user login process.
  void login() async {
    // Prevent multiple login attempts while one is in progress
    if (isLoading.value) return;
    
    isLoading.value = true;

    // Simulate a network delay for a better user experience
    await Future.delayed(const Duration(seconds: 1));

    final String username = usernameController.text.trim();
    final String password = passwordController.text;

    // Hide loading indicator before showing dialog or error
    isLoading.value = false;

    // Check if credentials match the specified values
    if (username == 'admin1@gmail.com' && password == 'admin1123') {
      // On success, show the custom success dialog
      Get.dialog(
        const SuccessDialog(),
        barrierDismissible: false,
      );
      
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.Dashboard);
      } else {
        Get.snackbar(
          'Login Failed',
          'Incorrect username or password. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(18),
        );
      }
    }
    
    @override
    void onClose() {
      usernameController.dispose();
      passwordController.dispose();
      super.onClose();
    }
  }
  
  class SuccessDialog extends StatelessWidget {
    const SuccessDialog({super.key});
    
    @override
    Widget build(BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      );
    }

    Widget contentBox(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Congratulations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Successfully Sign In',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}
