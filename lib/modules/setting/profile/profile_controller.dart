// lib/modules/setting/profile/profile_controller.dart
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class ProfileController extends GetxController {
  final Rx<File?> profileImage = Rx<File?>(null);
  
  late TextEditingController nameController;
  late TextEditingController aboutController;

  // ImagePicker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    
    nameController = TextEditingController(text: 'GYPEM INDONESIA');
    aboutController = TextEditingController(text: 'Chat Only !');
  }

  @override
  void onClose() {
    nameController.dispose();
    aboutController.dispose();
    super.onClose();
  }

  // Pick and crop an image
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        
        final croppedFile = await _cropImage(File(pickedFile.path));
        
        if (croppedFile != null) {
          profileImage.value = File(croppedFile.path);
          Get.snackbar(
            'Success',
            'Profile photo updated successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
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
          toolbarColor: const Color.fromARGB(255, 0, 0, 0),
          toolbarWidgetColor: ThemeColor.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
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
      Get.snackbar(
        'Success',
        'Profile photo has been deleted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18),
      );
      } else {
        Get.snackbar('Info', 'No profile photo to delete.');
      }
    }

  // Save profile
  void saveProfile() {
    Get.snackbar(
      'Success',
      'Profile updated successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: ThemeColor.white,
      margin: const EdgeInsets.all(18),
    );

    print("Name: ${nameController.text}");
    print("About: ${aboutController.text}");
  } 
} 