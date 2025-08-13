// lib/modules/quick_replies/quick_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'edit_quick_reply_screen.dart';

class QuickController extends GetxController {
  final shortcutController = TextEditingController();
  final messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  var quickReplies = <QuickReply>[
    QuickReply(
      id: '1',
      shortcut: '01',
      message: 'this is a quick message',
      imagePath: 'assets/images/pp2.jpg',
    ),
    QuickReply(
      id: '2',
      shortcut: '02',
      message: 'this is a quick message this is a quick message',
    ),
    QuickReply(
      id: '3',
      shortcut: '03',
      message: 'this is a quick message',
      imagePath: 'assets/images/pp2.jpg',
    ),
  ].obs;

  var selectedImage = Rx<File?>(null);

  void goToAddScreen() {
    // Clear previous data
    shortcutController.clear();
    messageController.clear();
    selectedImage.value = null;
    Get.to(() => EditQuickReplyScreen());
  }

  void goToEditScreen(QuickReply reply) {
    // Populate with existing data
    shortcutController.text = reply.shortcut;
    messageController.text = reply.message;
    selectedImage.value = reply.imageFile;

    Get.to(() => EditQuickReplyScreen(reply: reply));
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void saveNewReply() {
    if (shortcutController.text.isNotEmpty && messageController.text.isNotEmpty) {
      final newReply = QuickReply(
        id: DateTime.now().toString(),
        shortcut: shortcutController.text,
        message: messageController.text,
        imageFile: selectedImage.value,
      );
      quickReplies.add(newReply);
      Get.back();
    } else {
      Get.snackbar('Error', 'Shortcut and message cannot be empty.');
    }
  }

  void updateReply(QuickReply reply) {
    int index = quickReplies.indexWhere((r) => r.id == reply.id);
    if (index != -1) {
      reply.shortcut = shortcutController.text;
      reply.message = messageController.text;
      reply.imageFile = selectedImage.value;
      quickReplies[index] = reply;
      quickReplies.refresh(); 
      Get.back();
    }
  }
  
  void deleteReply(QuickReply reply) {
     quickReplies.removeWhere((r) => r.id == reply.id);
     Get.back(); 
     Get.back();
  }

  void showDeleteConfirmation(QuickReply reply) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- KOTAK KONFIRMASI (PUTIH) ---
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    'Edit Quick Reply',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => deleteReply(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      child: const Text(
                        'Delete Quick Reply',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // --- TOMBOL CANCEL ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {

    shortcutController.dispose();
    messageController.dispose();
    super.onClose();
  }
}