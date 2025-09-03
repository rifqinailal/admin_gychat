import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_controller.dart';
import 'edit_profile_screen.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: ThemeColor.lightGrey1,
        foregroundColor: ThemeColor.black,
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
              Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField(
                        label: 'Name',
                        value: controller.name.value,
                        onTap: () {
                          Get.bottomSheet(
                            EditProfileScreen(
                              title: 'Edit Name',
                              initialValue: controller.name.value,
                              onSave: (newValue) {
                                if (newValue.trim().isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Name cannot be empty.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: ThemeColor.Red1.withOpacity(0.6),
                                    colorText: ThemeColor.white,
                                    margin: const EdgeInsets.all(18),
                                  );
                                  return;
                                }
                                controller.name.value = newValue;
                                controller.saveProfile();
                                //controller.update();

                                Get.back();

                                Get.snackbar(
                                  'Success',
                                  'Name has been updated.',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: ThemeColor.primary.withOpacity(0.6),
                                  colorText: ThemeColor.white,
                                  margin: const EdgeInsets.all(18),
                                );
                              },
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            isScrollControlled: true,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildProfileField(
                        label: 'Bio',
                        value: controller.about.value,
                        onTap: () {
                          if (controller.name.value.trim().isEmpty) {
                            Get.snackbar(
                              'Info',
                              'Please enter your name before editing the bio.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: ThemeColor.blue1.withOpacity(0.6),
                              colorText: ThemeColor.white,
                              margin: const EdgeInsets.all(18),
                            );
                          } else {
                            Get.bottomSheet(
                              EditProfileScreen(
                                title: 'Edit Bio',
                                initialValue: controller.about.value,
                                onSave: (newValue) {
                                  controller.about.value = newValue;
                                  controller.saveProfile();
                                  //controller.update();

                                  Get.back();

                                  Get.snackbar(
                                    'Success',
                                    'Bio has been updated.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: ThemeColor.primary.withOpacity(0.6),
                                    colorText: ThemeColor.white,
                                    margin: const EdgeInsets.all(18),
                                  );
                                },
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              isScrollControlled: true,
                            );
                          }
                        },
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

  // Menampilkan gambar profil dan tombol edit
  Widget _buildProfileImage() {
    return Column(
      children: [
        GestureDetector(
          onTap: () { 
            if (controller.profileImage.value != null) {
              controller.viewProfileImage();
            } else { 
              _showPhotoOptions();
            }
          },
          child: Obx(() {
            return CircleAvatar(
              radius: 60,
              backgroundColor: ThemeColor.grey4,
              backgroundImage: controller.profileImage.value != null
                  ? FileImage(controller.profileImage.value!)
                  : null,
              child: controller.profileImage.value == null
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: ThemeColor.grey5,
                    )
                  : null,
            );
          }),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showPhotoOptions,
          style: TextButton.styleFrom(
            foregroundColor: ThemeColor.yelow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: ThemeColor.yelow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColor.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: ThemeColor.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ThemeColor.white),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: ThemeColor.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: ThemeColor.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Menampilkan opsi mengubah foto profil.
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
                color: ThemeColor.white,
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
                        textColor: ThemeColor.Red1,
                        iconColor: ThemeColor.Red1,
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
      backgroundColor: ThemeColor.black.withOpacity(0.3),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetOption({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = ThemeColor.black,
    Color iconColor = ThemeColor.black,
  }) {
    return Material(
      color: ThemeColor.white,
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
                  fontFamily: 'Poppins',
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

  /// Menampilkan konfirmasi penghapusan foto.
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
                  backgroundColor: ThemeColor.white,
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
                    fontFamily: 'Poppins',
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
                  foregroundColor: ThemeColor.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}