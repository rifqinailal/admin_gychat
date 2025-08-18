// lib/modules/grup/detail_grup/edit_description_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

class EditDescriptionScreen extends GetView<DetailGrupController> {
  const EditDescriptionScreen({super.key});

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
          'Edit Description',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: controller.saveGroupDescription, // Panggil fungsi simpan deskripsi
            child: const Text('Save', style: TextStyle(color: primaryColor, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.descriptionController,
            autofocus: true,
            maxLines: null, // Memungkinkan input teks multi-baris tanpa batas
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Group Description',
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}