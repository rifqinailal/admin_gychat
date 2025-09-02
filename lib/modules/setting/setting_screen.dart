// lib/modules/setting/setting_screen.dart
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/shared/theme/colors.dart'; 
import 'package:admin_gychat/modules/setting/profile/profile_controller.dart';
import 'setting_controller.dart';
import 'dart:io';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final profileController = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),
              const Text(
                'Setting',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.blue1,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Obx(() {
                return _buildProfileCard(profileController);
              }),
              SizedBox(height: screenHeight * 0.025),
              _buildOptionsCard(),
              SizedBox(height: screenHeight * 0.025),
             _buildLogoutButton(context, controller), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileController profileCtrl) {
    return Card(
      elevation: 0,
      color: ThemeColor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: ThemeColor.grey4,
            backgroundImage: profileCtrl.profileImage.value != null
                ? FileImage(profileCtrl.profileImage.value!)
                : null,
            child: profileCtrl.profileImage.value == null
                ? const Icon(Icons.person, size: 40, color: ThemeColor.grey5)
                : null,
          ),
          title: Text(
            profileCtrl.name.value,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: ThemeColor.black),
          ),
          subtitle: Text(
            profileCtrl.about.value,
            style: const TextStyle(
                fontFamily: 'Poppins',
                color: ThemeColor.black,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
          trailing: const Icon(Icons.chevron_right, color: ThemeColor.black),
          onTap: () {
            Get.toNamed(AppRoutes.Profile);
          },
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      elevation: 0,
      color: ThemeColor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: ThemeColor.black),
            title: const Text('Away Message',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            subtitle: const Text('Reply automatically when you are away'),
            trailing: const Icon(Icons.chevron_right, color: ThemeColor.black),
            onTap: () {
              Get.toNamed(AppRoutes.AwayMessage);
            },
          ), 
          ListTile(
            leading: const Icon(Icons.flash_on, color: ThemeColor.black),
            title: const Text('Quick Replies',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            subtitle: const Text('Reuse frequent message'),
            trailing: const Icon(Icons.chevron_right, color: ThemeColor.black),
            onTap: () {
              Get.toNamed(AppRoutes.QuickReplies);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, SettingController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.blue1,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColor.white,
          ),
        ),
      ),
    );
  }
} 