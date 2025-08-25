// lib/app/modules/grup/grup_baru/grup_baru_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart'; 

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
          color: ThemeColor.white,
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
                textColor: ThemeColor.Red1,
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
                backgroundColor: ThemeColor.black,
                child: Icon(Icons.close, color: ThemeColor.white),
              ),
            ),
          ),
        ],
      ),
      barrierColor: ThemeColor.black.withOpacity(0.5),
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
            toolbarColor: ThemeColor.black,
            toolbarWidgetColor: ThemeColor.white,
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
    isFormValid.value = groupNameController.text.isNotEmpty;
  }

  Future<void> createGroup() async {
    if (isFormValid.value) {
      final chatListController = Get.find<ChatListController>();
      final newGroupName = groupNameController.text.trim();
      final isDuplicate = chatListController.allChatsInternal.any((chat) => chat.name.trim() == newGroupName);
      
      if (isDuplicate) {
        Get.snackbar(
          "Error",
          "Group by name $newGroupName already available.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: ThemeColor.Red1.withOpacity(0.6),
          colorText: ThemeColor.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 10,
        );
        return;
      }
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;
      
      // Buat grup baru
      final newGroup = ChatModel(
        roomId: DateTime.now().millisecondsSinceEpoch,
        roomMemberId: 99,
        roomType: 'group',
        name: newGroupName,
        description: groupDescController.text.isNotEmpty ? groupDescController.text : null,
        urlPhoto: selectedImagePath.isNotEmpty ? selectedImagePath.value : null,
        lastMessage: "new group has been created",
        lastTime: DateTime.now(),
      );
      
      // Tambahkan grup baru ke daftar chat
      try {
        chatListController.addNewChat(newGroup);
      } catch (e) {
        print("Error: ChatListController tidak ditemukan. Pastikan sudah diinisialisasi di halaman sebelumnya.");
      }
      isLoading.value = false;
      Get.back();
      
      Get.snackbar(
        "Success",
        "Group ${groupNameController.text} successfully created.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.6),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
    }
  }
}
