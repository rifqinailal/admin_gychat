// lib/modules/setting/setting_controller.dart
import 'package:flutter/material.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class SettingController extends GetxController {
  final box = GetStorage();

  void showLogoutConfirmation(BuildContext context) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ThemeColor.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height:10),
                  const Text(
                    'Are you sure you want to leave?',
                    style: TextStyle(fontFamily: 'Poppins', color: ThemeColor.grey2, fontSize: 12),
                  ),
                  InkWell(
                    onTap: () {
                      box.remove('isLoggedIn');
                      
                      Get.back();
                      Get.offAllNamed(AppRoutes.Auth);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      child: const Text(
                        'Log Out',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeColor.Red1,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), 
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.blue1,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}