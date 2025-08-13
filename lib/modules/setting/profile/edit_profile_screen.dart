// lib/modules/setting/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  final String title;
  final String initialValue;

  const EditProfileScreen({
    super.key,
    required this.title,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: initialValue);

    // Scaffold ini menyediakan struktur dasar.
    // Sudut melengkung dan perilaku modal akan diatur oleh Get.bottomSheet di profile_screen.
    return Scaffold(
      // Latar belakang putih sesuai desain.
      backgroundColor: Colors.white,
      // SafeArea memastikan UI tidak terhalang oleh notch atau status bar.
      body: SafeArea(
        child: Padding(
          // Padding keseluruhan untuk konten.
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            // Penting agar bottom sheet hanya memakan ruang yang dibutuhkan.
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Kustom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol "Cancel"
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  // Judul Halaman
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  // Tombol "Save"
                  InkWell(
                    onTap: () => Get.back(result: textController.text),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          // Warna abu-abu sesuai desain Figma.
                          color: Colors.grey,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. TextField untuk input
              TextField(
                controller: textController,
                autofocus: true,
                maxLines: 5,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    // Tidak ada border yang terlihat, sesuai desain.
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              // Memberi ruang agar keyboard tidak menutupi TextField.
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
