// lib/app/modules/grup_baru/grup_baru_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'grup_baru_controller.dart';

class GrupBaruScreen extends GetView<GrupBaruController> {
  const GrupBaruScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Grup Baru',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.showImageSourceActionSheet(),
              child: Obx(() {
                return CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: controller.selectedImagePath.isNotEmpty
                      ? FileImage(File(controller.selectedImagePath.value))
                      : null,
                  child: controller.selectedImagePath.isEmpty
                      ? const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF757575),
                          size: 30,
                        )
                      : null,
                );
              }),
            ),
            const SizedBox(height: 32),

            // TextFields
            _buildTextField(
              controller: controller.groupNameController,
              hintText: 'Nama Grup',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.groupDescController,
              hintText: 'Deskripsi Group',
              maxLines: 4,
            ),
            const Spacer(),

            // Save Button
            Obx(() {
              return _buildSaveButton();
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF2F3C7E), width: 2.0),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final bool isEnabled = controller.isFormValid.value && !controller.isLoading.value;
    final bool isLoading = controller.isLoading.value;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => controller.createGroup() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled || isLoading ? const Color(0xFF2F3C7E) : const Color(0xFFBDBDBD),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Membuat grup....',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              )
            : Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : const Color(0xFF757575),
                ),
              ),
      ),
    );
  }
}