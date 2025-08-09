import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quick_controller.dart';

class EditQuickReplyScreen extends GetView<QuickController> {
  const EditQuickReplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        titleSpacing: 0,
        title: _buildHeader(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Bagian Form ---
            _buildSectionContainer(
              child: _buildTextField(
                controller: controller.shortcutController,
                hint: 'Shortcut',
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.selectedImage.value != null || controller.currentlyEditing.value?.imageAsset != null) {
                return _buildAttachmentView();
                } else {
                  return _buildSectionContainer(
                    child: _buildTextField(
                      controller: controller.messageController,
                      hint: 'Enter Message',
                      maxLines: 5,
                    ),
                  );
              }
            }),
            
            const SizedBox(height: 20),
            _buildSectionContainer(
              child: _buildAttachMedia(),
            ),
            const SizedBox(height: 20),

            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const buttonStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: Color.fromARGB(255, 0, 0, 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
          child: const Text('Cancel', style: buttonStyle),
        ),
        const Text(
          'Edit Quick Reply',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Obx(
          () => TextButton(
            onPressed: controller.isFormValid.value ? controller.updateQuickReply : null,
            child: Text(
              'Save',
              style: controller.isFormValid.value
                  ? buttonStyle
                  : buttonStyle.copyWith(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
  
  // Widget untuk menampilkan preview gambar dan pesan di bawahnya
  Widget _buildAttachmentView() {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reply With 1 Attachment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: controller.selectedImage.value != null
                    ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                    : Image.asset(controller.currentlyEditing.value!.imageAsset!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 5),
              Text(controller.messageController.text, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _showDeleteConfirmationDialog,
        child: const Text(
          'Delete',
          style: TextStyle(
            color: Colors.red,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Delete Quick Reply',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
             SizedBox(
              width: double.infinity,
               child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                         ),
             ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets (re-used from previous code with slight modification)
  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildAttachMedia() {
    return InkWell(
      onTap: () {
        Get.snackbar('Info', 'Fitur lampirkan media belum tersedia.');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: Color.fromARGB(255, 175, 175, 175)),
            const SizedBox(width: 8),
            const Text('Attach Media', style: TextStyle(color: Color.fromARGB(255, 136, 136, 136), fontSize: 16)),
          ],
        ),
      ),
    );
  }
}