// lib/modules/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.showLoginCard.value,
        onPopInvoked: (didPop) {
          if (didPop) return;
          controller.hideLoginCard();
        },
        child: Scaffold(
          body: Stack(
            children: [
              GestureDetector(
                onTap: controller.hideLoginCard,
                child: _buildBackgroundImage(),
              ),
              controller.showLoginCard.value
                  ? _buildLoginView()
                  : _buildWelcomeView(),
              
              // Add the loading overlay here
              _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the loading overlay
  Widget _buildLoadingOverlay() {
    return Obx(() {
      // Show overlay only when isLoading is true
      if (controller.isLoading.value) {
        return Container(
          // Semi-transparent background
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            // The circular progress indicator
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      } else {
        // Return an empty container when not loading
        return const SizedBox.shrink();
      }
    });
  }

  // Widget untuk Latar Belakang Gambar
  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgloginadmin.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget untuk Tampilan Welcome
  Widget _buildWelcomeView() {
    return SafeArea(
      key: const ValueKey('welcomeView'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 4),
            const Text(
              'Welcome to GyChat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait for a message from the participant before starting the conversation',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const Spacer(flex: 3),
            ElevatedButton(
              onPressed: controller.displayLoginCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }

  // Widget untuk Tampilan Login (sebelah kanan desain)
  Widget _buildLoginView() {
    return Align(
      key: const ValueKey('loginView'),
      alignment: Alignment.bottomCenter,
      child: Container(
        height: Get.height * 0.65,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to GyChat',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: controller.usernameController,
                hintText: 'Username',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Obx(
                () => _buildTextField(
                  controller: controller.passwordController,
                  hintText: 'Password',
                  obscureText: controller.isPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.ForgotPassword);
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF3F51B5)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat TextField yang seragam
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
