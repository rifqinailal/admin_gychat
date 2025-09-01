// lib/modules/setting/profile/profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class ProfileController extends GetxController {
  final Rx<File?> profileImage = Rx<File?>(null);

  final name = 'GYPEM INDONESIA'.obs;
  final about = 'Chat Only !'.obs;

  // GetStorage
  final box = GetStorage();

  final String _nameKey = 'profile_name';
  final String _aboutKey = 'profile_about';
  final String _imagePathKey = 'profile_image_path';
  // ImagePicker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  void _loadProfileData() {
    // Muat name
    name.value = box.read(_nameKey) ?? 'GYPEM INDONESIA';
    //Muat bio
    about.value = box.read(_aboutKey) ?? 'Chat Only !';

    // Muat path gambar
    final imagePath = box.read<String?>(_imagePathKey);
    if (imagePath != null && imagePath.isNotEmpty) {
      profileImage.value = File(imagePath);
    }

    // Tambahkan listener untuk otomatis menyimpan saat teks berubah
    // Ini opsional, karena penyimpanan sudah ada di fungsi saveProfile
    // nameController.addListener(() => box.write(_nameKey, nameController.text));
    // aboutController.addListener(() => box.write(_aboutKey, aboutController.text));
  }

  // Pick and crop an image 
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path)); 

        if (croppedFile != null) {
          profileImage.value = File(croppedFile.path);
          box.write(_imagePathKey, croppedFile.path);
          Get.snackbar(
            'Success',
            'Profile photo updated successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: ThemeColor.primary.withOpacity(0.8),
            colorText: ThemeColor.white,
            margin: const EdgeInsets.all(18),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Crop image
  Future<CroppedFile?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: ThemeColor.black,
          toolbarWidgetColor: ThemeColor.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPickerButtonHidden: false,
        ),
      ],
    );
  }

  // View profile image
  void viewProfileImage() {
    if (profileImage.value != null) {
      Get.to(
        () => Scaffold(
          backgroundColor: ThemeColor.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.file(
                    profileImage.value!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              // Tombol 'close'
              Positioned(
                top: 50.0,
                left: 16.0,
                child: CircleAvatar(
                  backgroundColor: ThemeColor.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: ThemeColor.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ],
          ),
        ),
        fullscreenDialog: true,
        transition: Transition.fade,
      );
    }
  }

  // Delete profile image
  void deleteProfileImage() {
    if (profileImage.value != null) {
      profileImage.value = null;
      box.remove(_imagePathKey);
      Get.snackbar(
        'Success',
        'Profile photo has been deleted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.primary.withOpacity(0.8),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18),
      );
    } else {
      Get.snackbar('Info', 'No profile photo to delete.');
    }
  }

  // Save profile
  void saveProfile() {
    box.write(_nameKey, name.value);
    box.write(_aboutKey, about.value);
    
    print("Name saved: ${name.value}");
    print("About saved: ${about.value}");
  }
}
