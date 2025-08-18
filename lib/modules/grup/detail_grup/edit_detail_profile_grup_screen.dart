// lib/modules/grup/detail_grup/edit_detail_profile_grup_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

class EditDetailProfileGrupScreen extends GetView<DetailGrupController> {
  const EditDetailProfileGrupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17)),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Group',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: controller.saveGroupInfo,
            child: const Text('Save', style: TextStyle(color: primaryColor, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: controller.showEditPhotoOptions,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Obx(() => CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: controller.groupImage.value != null
                            ? FileImage(controller.groupImage.value!)
                            : null,
                        child: controller.groupImage.value == null
                            ? const Icon(Icons.group, size: 70, color: Colors.white)
                            : null,
                      )),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: controller.nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Group Name',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}