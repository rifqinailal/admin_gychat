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
          'Group Baru',
          style: TextStyle(
            fontFamily: 'Poppins', 
            color: ThemeColor.darkGrey2, 
            fontSize: 20, 
            fontWeight: FontWeight.normal
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, 
            size: 25, 
            color: ThemeColor.darkGrey1
          ),
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
                      radius: 25,
                      backgroundColor: ThemeColor.mediumGrey4,
                      backgroundImage: controller.selectedImagePath.isNotEmpty ? FileImage(File(controller.selectedImagePath.value)) : null,
                      child: controller.selectedImagePath.isEmpty ? const Icon(Icons.camera_alt, color: ThemeColor.white, size: 32) : null,
                    );
                  }),
                ), 
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: controller.groupNameController,
                        hintText: 'Name Group',
                      ),
                      const SizedBox(height: 13),
                      _buildTextField(
                        controller: controller.groupDescController,
                        hintText: 'Description Group',
                        maxLines: 1,
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
        hintStyle: const TextStyle(
          fontFamily: 'Poppins', 
          color: ThemeColor.mediumGrey4, 
          fontSize: 15
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0, 
          horizontal: 16.0
        ),
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
          borderSide: const BorderSide(color: ThemeColor.primary, width: 2.0),
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
              // color: ThemeColor.primary,
            ),
          ),
          SizedBox(width: 16),
          Text(
            'Create Group...',
            style: TextStyle(
              fontFamily: 'Poppins', 
              fontSize: 15, 
              fontWeight: FontWeight.normal, 
              color: ThemeColor.black
            ),
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
          backgroundColor: ThemeColor.primary,
          disabledBackgroundColor: ThemeColor.mediumGrey4,
          disabledForegroundColor: ThemeColor.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isEnabled ? ThemeColor.white : ThemeColor.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}