// lib/modules/setting/profile/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_controller.dart';
import 'edit_profile_screen.dart'; // Import the new screen

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildProfileImage()),
              const SizedBox(height: 40),
              // Gunakan GetBuilder untuk update UI Name dan Bio
              GetBuilder<ProfileController>(
                builder: (_) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField(
                        label: 'Name',
                        value: controller.nameController.text,
                        onTap: () => _navigateToEditScreen(
                          title: 'Edit Name',
                          initialValue: controller.nameController.text,
                          onSave: (newValue) {
                            controller.nameController.text = newValue;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProfileField(
                        label: 'Bio',
                        value: controller.aboutController.text,
                        onTap: () => _navigateToEditScreen(
                          title: 'Edit Bio',
                          initialValue: controller.aboutController.text,
                          onSave: (newValue) {
                            controller.aboutController.text = newValue;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **UPDATED:** Menavigasi ke layar edit menggunakan Get.bottomSheet.
  Future<void> _navigateToEditScreen({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) async {
    // Menampilkan EditProfileScreen sebagai modal bottom sheet.
    final result = await Get.bottomSheet(
      EditProfileScreen(
        title: title,
        initialValue: initialValue,
      ),
      // Memberi bentuk dengan sudut atas melengkung.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      // Memastikan konten di dalam sheet mengikuti bentuk melengkung.
      clipBehavior: Clip.antiAliasWithSaveLayer,
      // Penting agar sheet bisa lebih tinggi dan merespons keyboard.
      isScrollControlled: true,
    );

    // Jika pengguna menyimpan (hasil tidak null), perbarui controller.
    if (result != null && result is String) {
      onSave(result);
      controller.update(); // Refresh UI untuk menampilkan nilai baru
      controller.saveProfile(); // Panggil metode simpan di controller
    }
  }

  // Widget untuk menampilkan gambar profil dan tombol edit
  Widget _buildProfileImage() {
    return Column(
      children: [
        Obx(() {
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200], 
            backgroundImage: controller.profileImage.value != null
            ? FileImage(controller.profileImage.value!)
            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            child: controller.profileImage.value == null
            ? Icon(
              Icons.person,
              size: 60,
              color: Colors.grey[400],
            )
            : null,
          );
        }),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showPhotoOptions,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFA726),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(
              color: Color(0xFFFFA726),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

 
  Widget _buildProfileField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Menampilkan bottom sheet dengan opsi untuk mengubah foto profil.
  void _showPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 34),
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildBottomSheetOption(
                      text: 'Take Photo',
                      icon: Icons.photo_camera_outlined,
                      onTap: () {
                        Get.back();
                        controller.pickImage(ImageSource.camera);
                      },
                    ),
                    const Divider(height: 0.5, indent: 18, endIndent: 18),
                    _buildBottomSheetOption(
                      text: 'Choose Photo',
                      icon: Icons.image_outlined,
                      onTap: () {
                        Get.back();
                        controller.pickImage(ImageSource.gallery);
                      },
                    ),
                    if (controller.profileImage.value != null) ...[
                      const Divider(height: 0.5, indent: 18, endIndent: 18),
                      _buildBottomSheetOption(
                        text: 'Delete Photo',
                        icon: Icons.delete_outline,
                        textColor: const Color(0xFFE53935),
                        iconColor: const Color(0xFFE53935),
                        onTap: () {
                          Get.back();
                          _showEditPhotoSheet();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // Widget yang dapat digunakan kembali untuk opsi bottom sheet.
  Widget _buildBottomSheetOption({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = Colors.black54,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  color: textColor,
                ),
              ),
              Icon(icon, color: iconColor, size: 26),
            ],
          ),
        ),
      ),
    );
  }

  /// Menampilkan dialog untuk konfirmasi penghapusan foto.
  void _showEditPhotoSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol "Delete Photo"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.back();
                  controller.deleteProfileImage();
                },
                child: const Text(
                  'Delete Photo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tombol "Cancel"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.back(), // Tutup bottom sheet
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
