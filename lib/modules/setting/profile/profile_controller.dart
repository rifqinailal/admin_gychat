// lib/modules/setting/profile/profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final Rx<File?> profileImage = Rx<File?>(null);

  // Controllers for the text fields
  late TextEditingController nameController;
  late TextEditingController aboutController;

  // Instance of ImagePicker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers with initial data
    nameController = TextEditingController(text: 'GYPEM INDONESIA');
    aboutController = TextEditingController(text: 'Chat Only !');
  }

  @override
  void onClose() {
    nameController.dispose();
    aboutController.dispose();
    super.onClose();
  }

  // Function to pick and crop an image
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        // Call the image crop function
        final croppedFile = await _cropImage(File(pickedFile.path));

        if (croppedFile != null) {
          profileImage.value = File(croppedFile.path);
          Get.snackbar(
            'Success',
            'Profile photo updated successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(18),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Function to crop an image
  Future<CroppedFile?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color.fromARGB(255, 0, 0, 0),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
      compressQuality: 70,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
  }

  // Function to delete the profile image
  void deleteProfileImage() {
    if (profileImage.value != null) {
      profileImage.value = null;
      Get.snackbar(
        'Success',
        'Profile photo has been deleted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(18),
      );
      update();
    } else {
      Get.snackbar('Info', 'No profile photo to delete.');
    }
  }

  // Function to save profile changes
  void saveProfile() {
    Get.snackbar(
      'Success',
      'Profile updated successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(18),
    );
    // Print for debugging
    print("Name: ${nameController.text}");
    print("About: ${aboutController.text}");
    update();
  }
}
