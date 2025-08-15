// lib/app/modules/grup_baru/grup_baru_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class GrupBaruController extends GetxController {
  var selectedImagePath = ''.obs;
  var groupNameController = TextEditingController();
  var groupDescController = TextEditingController();

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    groupNameController.addListener(validateForm);
    groupDescController.addListener(validateForm);
  }

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescController.dispose();
    super.onClose();
  }

  /// Menampilkan bottom sheet untuk memilih sumber gambar.
  void showImageSourceActionSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ),

            // Melihat foto, hanya muncul jika foto sudah ada
            if (selectedImagePath.isNotEmpty) ...[
              _buildListTile(
                title: 'See Photo',
                icon: Icons.zoom_in_rounded,
                onTap: viewImage,
              ),
              const Divider(),
            ],

            // Mengambil foto atau memilih dari galeri
            _buildListTile(
              title: 'Take Photo',
              icon: Icons.camera_alt_outlined,
              onTap: () {
                Get.back();
                _pickAndCropImage(ImageSource.camera);
              },
            ),
            const Divider(),
            _buildListTile(
              title: 'Choose Photo',
              icon: Icons.photo_library_outlined,
              onTap: () {
                Get.back();
                _pickAndCropImage(ImageSource.gallery);
              },
            ),

            // Menghapus foto, hanya muncul jika foto sudah ada
            if (selectedImagePath.isNotEmpty) ...[
              const Divider(),
              _buildListTile(
                title: 'Delete Photo',
                icon: Icons.delete_outline,
                onTap: deleteImage,
                textColor: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Menampilkan gambar dalam dialog fullscreen
  void viewImage() {
    if (selectedImagePath.isEmpty) return;
    Get.back();

    Get.dialog(
      Stack(
        children: [
          // Gambar bisa di-zoom dan digeser
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(selectedImagePath.value),
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Tombol close
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      barrierColor: Colors.black.withOpacity(0.85),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      trailing: Icon(icon, color: textColor),
      onTap: onTap,
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: false),
        ],
      );

      if (croppedFile != null) {
        selectedImagePath.value = croppedFile.path;
        validateForm();
      }
    }
  }

  void deleteImage() {
    selectedImagePath.value = '';
    Get.back();
    validateForm();
  }

  void validateForm() {
    isFormValid.value =
    groupNameController.text.isNotEmpty &&
    groupDescController.text.isNotEmpty;
  }

  Future<void> createGroup() async {
    if (isFormValid.value) {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      Get.snackbar(
        "Berhasil",
        "Grup '${groupNameController.text}' berhasil dibuat.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }
}
