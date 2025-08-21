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
    final profileController = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Setting',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.blue1,
                  
                ),
              ),

              const SizedBox(height: 25),
              GetBuilder<ProfileController>(
                builder: (profileCtrl) {
                  return _buildProfileCard(profileCtrl);
                },
              ),

              const SizedBox(height: 20),
              _buildOptionsCard(),

              const Spacer(),
              _buildLogoutButton(context, controller),

              const SizedBox(height: 275),
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
            backgroundColor: Colors.grey[200],
            // Tampilkan gambar profil dari controller
            backgroundImage: profileCtrl.profileImage.value != null
                ? FileImage(profileCtrl.profileImage.value! as File)
                : const AssetImage('assets/images/gypem_logo.png')
                    as ImageProvider,
          ),
          // Tampilkan nama dan bio dari controller
          title: Text(
            profileCtrl.nameController.text,
            style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeColor.black),
          ),
          subtitle: Text(
            profileCtrl.aboutController.text,
            style: const TextStyle(
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
            title: const Text('Away Message', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Reply automatically when you are away'),
            trailing: const Icon(Icons.chevron_right, color: ThemeColor.black),
            onTap: () {
              Get.toNamed(AppRoutes.AwayMessage);
            },
            
          ),
          ListTile(
            leading: const Icon(Icons.flash_on, color: ThemeColor.black),
            title: const Text('Quick Replies', style: TextStyle(fontWeight: FontWeight.bold)),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColor.white,
          ),
        ),
      ),
    );
  }
}
