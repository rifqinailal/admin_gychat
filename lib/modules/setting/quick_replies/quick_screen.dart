import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quick_controller.dart';

class QuickScreen extends GetView<QuickController> {
  const QuickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0.5,
        shadowColor: Colors.grey.withOpacity(0.2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Quick Replies',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black54, size: 32),
            onPressed: () {
              // Panggil bottom sheet saat tombol ditekan
              _showAddReplySheet();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.quickReplies.length,
                itemBuilder: (context, index) {
                  final reply = controller.quickReplies[index];
                  return InkWell(
                    onTap: () => controller.goToEditScreen(reply),
                    child: _buildReplyItem(reply),
                  );
                },
                separatorBuilder: (context, index) {
                  // Separator dengan indentasi
                  return const Divider(height: 1, indent: 72, endIndent: 16);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddReplySheet() {
    controller.clearForm(); // Pastikan form bersih saat sheet dibuka
    Get.bottomSheet(
      const AddQuickReplySheet(), // Widget custom kita
      backgroundColor: const Color(0xFFF2F2F7),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ).whenComplete(() {
      controller.clearForm(); // Bersihkan juga saat sheet ditutup
    });
  }

  Widget _buildReplyItem(QuickReply reply) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeadingWidget(reply),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0), // Agar teks sejajar
              child: Text(
                reply.message,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingWidget(QuickReply reply) {
    // Logika untuk menampilkan gambar dari path (jika ada)
    if (reply.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          File(reply.imagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    // Jika tidak, gunakan gambar dari asset (dummy data)
    else if (reply.imageAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          reply.imageAsset!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    // Jika tidak ada gambar, tampilkan nomor
    else {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFE5E5EA),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            reply.id,
            style: const TextStyle(
              color: Color(0xFF8A8A8E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
}

// WIDGET BARU UNTUK ISI BOTTOM SHEET
class AddQuickReplySheet extends GetView<QuickController> {
  const AddQuickReplySheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan DraggableScrollableSheet untuk layout yang lebih baik
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSectionContainer([
                    _buildTextField(
                      controller: controller.shortcutController,
                      hint: 'Shortcut',
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionContainer([
                    _buildTextField(
                      controller: controller.messageController,
                      hint: 'Enter Message',
                      maxLines: 5,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionContainer([
                    _buildAttachMedia(),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
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
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: buttonStyle),
        ),
        const Text(
          'Tambah Quick Reply',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Obx(
          () => TextButton(
            onPressed:
                controller.isFormValid.value ? controller.addQuickReply : null,
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

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
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
        border: InputBorder.none, // Hapus border bawaan
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
            const Icon(Icons.image_outlined, color: Colors.black54),
            const SizedBox(width: 8),
            const Text('Attach Media', style: TextStyle(color: Colors.black54, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}