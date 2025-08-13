// lib/features/quick_replies/edit_quick_reply_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quick_controller.dart';
import 'package:admin_gychat/models/quick_reply_model.dart';

class EditQuickReplyScreen extends GetView<QuickController> {
  final QuickReply? reply;
  const EditQuickReplyScreen({super.key, this.reply});

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = reply != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal
          ),),
        ),
        
        title: Text(
          isEditMode ? 'Edit Quick Reply' : 'Tambah Quick Reply',
          style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
        actions: [
          TextButton(
            onPressed: () {
              if (isEditMode) {
                controller.updateReply(reply!);
              } else {
                controller.saveNewReply();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal,
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Shortcut', controller: controller.shortcutController),
              const SizedBox(height: 16),
            _buildTextField(
              label: 'Message', controller: controller.messageController, maxLines: 5),
              const SizedBox(height: 16),
              const Text('  Attach Media', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
            _buildMediaAttachment(isEditMode),
            if (isEditMode) ...[
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.showDeleteConfirmation(reply!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: const Text('Delete', style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    {required String label, required TextEditingController controller, int maxLines = 1}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text('  $label', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                hintText: 'Enter $label',
              ),
            ),
          ),
        ],
      );
    }
    
    Widget _buildMediaAttachment(bool isEditMode) {
      return GestureDetector(
        onTap: () => controller.pickImage(),
        child: Obx(() {
          final newPickedImage = controller.selectedImage.value;
          final existingImageFile = isEditMode ? reply?.imageFile : null;
          final existingImagePath = isEditMode ? reply?.imagePath : null;
          
          if (newPickedImage != null) {
            return _buildImageDisplay(
              image: Image.file(newPickedImage, fit: BoxFit.cover),
            );
          }
          
          if (existingImageFile != null) {
            return _buildImageDisplay(
              image: Image.file(existingImageFile, fit: BoxFit.cover),
            );
          }
          
          if (existingImagePath != null) {
            return _buildImageDisplay(
              image: Image.asset(existingImagePath, fit: BoxFit.cover),
            );
          }
          return Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
            ),
          );
        }),
      );
    }

  /// A helper widget to avoid repeating code for displaying the image and message.
  Widget _buildImageDisplay({required Image image}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: image,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.messageController.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}