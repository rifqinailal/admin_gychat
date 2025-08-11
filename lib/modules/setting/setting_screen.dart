import 'package:admin_gychat/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'setting_controller.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller sudah di-find secara otomatis oleh GetView
    // final SettingController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Setting',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildOptionsCard(),
              // Spacer akan mendorong semua widget di bawahnya ke dasar layar
              const Spacer(),
              _buildLogoutButton(context, controller),
              // Beri sedikit jarak dari tepi bawah
              const SizedBox(height: 310),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    // Kode ini sudah bagus, tidak perlu diubah
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          subtitle: const Text('Chat Only !', style: TextStyle(color: Colors.grey)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Get.toNamed(AppRoutes.Profile);
          },
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    // Kode ini sudah bagus, tidak perlu diubah
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: Colors.grey),
            title: const Text('Away Message'),
            subtitle: const Text('Reply automatically when you are away'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Get.toNamed(AppRoutes.AwayMessage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flash_on, color: Colors.grey),
            title: const Text('Quick Replies'),
            subtitle: const Text('Reuse frequent message'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
          // Memanggil fungsi dari controller yang sudah kita buat
          controller.showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F51B5), 
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            // Diubah agar lebih membulat seperti tombol cancel
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
