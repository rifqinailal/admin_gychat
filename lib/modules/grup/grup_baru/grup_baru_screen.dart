// lib/app/modules/grup/grup_baru/grup_baru_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'grup_baru_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class GrupBaruScreen extends GetView<GrupBaruController> {
  const GrupBaruScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: AppBar(
        title: const Text(
          'Grup Baru',
          style: TextStyle(color: ThemeColor.darkGrey2, fontSize: 22, fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColor.darkGrey1),
          onPressed: () => Get.back(),
        ),
        backgroundColor: ThemeColor.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => controller.showImageSourceActionSheet(),
                  child: Obx(() {
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: ThemeColor.mediumGrey4,
                      backgroundImage: controller.selectedImagePath.isNotEmpty
                          ? FileImage(File(controller.selectedImagePath.value))
                          : null,
                      child: controller.selectedImagePath.isEmpty
                          ? const Icon(
                              Icons.camera_alt,
                              color: ThemeColor.white,
                              size: 30,
                            )
                          : null,
                    );
                  }),
                ),
                // 1. FIX: Changed SizedBox height to width for horizontal spacing.
                const SizedBox(width: 16), 

                // 2. FIX: Wrapped the inner Column with an Expanded widget.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingIndicator();
            } else {
              return const SizedBox.shrink();
            }
          }),

            const Spacer(),
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
        hintStyle: const TextStyle(color: ThemeColor.mediumGrey2_40, fontSize: 16),
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
          borderSide: const BorderSide(color: ThemeColor.blue1, width: 2.0),
        ),
      ),
    );
  }

Widget _buildLoadingIndicator() {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
    decoration: BoxDecoration(
      border: Border.all(color: ThemeColor.mediumGrey4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            // Anda bisa sesuaikan warnanya jika perlu
            // color: ThemeColor.blue1,
          ),
        ),
        SizedBox(width: 16),
        Text(
          'Membuat grup.....',
          style: TextStyle(fontSize: 15, color: ThemeColor.black),
        ),
      ],
    ),
  );
}

 Widget _buildSaveButton() {
  final bool isEnabled = controller.isFormValid.value && !controller.isLoading.value;

  return SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: isEnabled ? () => controller.createGroup() : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: ThemeColor.blue1,
      disabledBackgroundColor: ThemeColor.mediumGrey4,
      disabledForegroundColor: ThemeColor.white, // Optional, but good practice
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    child: Text(
      'Simpan',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isEnabled ? ThemeColor.white : ThemeColor.white,
      ),
    ),
  ),
);
}}