// lib/modules/setting/setting_screen.dart
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'setting_controller.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) { 
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
              _buildProfileCard(),

              const SizedBox(height: 20),
              _buildOptionsCard(),

              const Spacer(),
              _buildLogoutButton(context, controller),

              const SizedBox(height: 295),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() { 
    return Card(
      elevation: 0,
      color: ThemeColor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: ThemeColor.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/gypem_logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business, color: Colors.grey[800]),
                  );
                },
              ),
            ),
          ),
          title: const Text(
            'GYPEM INDONESIA',
            style: TextStyle(fontWeight: FontWeight.bold, color: ThemeColor.black),
          ),
          subtitle: const Text('Chat Only !', style: TextStyle(color: ThemeColor.black, fontSize: 14, fontWeight: FontWeight.normal)),
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
