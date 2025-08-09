import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_quick_reply_screen.dart';

// Model tidak berubah
class QuickReply {
  final String id;
  final String message;
  final String? shortcut;
  final String? imageAsset;
  final String? imagePath;

  QuickReply({
    required this.id,
    required this.message,
    this.shortcut,
    this.imageAsset,
    this.imagePath,
  });
}

class QuickController extends GetxController {
  final RxList<QuickReply> quickReplies = <QuickReply>[].obs;
  late TextEditingController shortcutController;
  late TextEditingController messageController;
  var isFormValid = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // State untuk menyimpan item yang sedang diedit
  Rx<QuickReply?> currentlyEditing = Rx<QuickReply?>(null);

  @override
  void onInit() {
    super.onInit();
    shortcutController = TextEditingController();
    messageController = TextEditingController();
    shortcutController.addListener(validateForm);
    messageController.addListener(validateForm);
    fetchQuickReplies();
  }

  void validateForm() {
    isFormValid.value =
        shortcutController.text.isNotEmpty && messageController.text.isNotEmpty;
  }

  void goToEditScreen(QuickReply reply) {
    // 1. Simpan item yang sedang diedit
    currentlyEditing.value = reply;

    // 2. Isi form dengan data dari item yang dipilih
    shortcutController.text = reply.shortcut ?? '';
    messageController.text = reply.message;
    selectedImage.value = reply.imagePath != null ? File(reply.imagePath!) : null;

    // 3. Reset validasi
    validateForm();

    // 4. Navigasi ke halaman edit
    Get.to(() => const EditQuickReplyScreen());
  }

  void updateQuickReply() {
    if (currentlyEditing.value == null || !isFormValid.value) return;

    final int index = quickReplies.indexWhere((r) => r.id == currentlyEditing.value!.id);
    if (index != -1) {
      final updatedReply = QuickReply(
        id: currentlyEditing.value!.id,
        shortcut: shortcutController.text,
        message: messageController.text,
        imagePath: selectedImage.value?.path,
        // Pertahankan asset asli jika tidak ada gambar baru yang dipilih
        imageAsset: selectedImage.value == null ? currentlyEditing.value!.imageAsset : null,
      );
      quickReplies[index] = updatedReply;
      Get.back(); // Kembali ke halaman list
      clearForm();
    }
  }

  void deleteQuickReply() {
    if (currentlyEditing.value == null) return;
    quickReplies.removeWhere((r) => r.id == currentlyEditing.value!.id);
    
    // Kembali 2x: tutup bottom sheet konfirmasi, lalu tutup halaman edit
    Get.back(); 
    Get.back(); 
    clearForm();
  }


  // --- FUNGSI LAMA (sedikit penyesuaian) ---

  void fetchQuickReplies() {
    // (Data dummy sama seperti sebelumnya)
     var replies = [
      QuickReply(
        id: '01',
        shortcut: 'salam',
        message: 'this is a quick message',
      ),
      QuickReply(
        id: '03',
        shortcut: 'produk',
        message: 'this is a quick message',
        imageAsset: 'assets/images/1.jpg', 
      ),
      QuickReply(
        id: '04',
        shortcut: '04',
        message: 'this is a quick message',
      ),
    ];
    quickReplies.assignAll(replies);
  }

  void addQuickReply() {
    if (!isFormValid.value) {
      Get.snackbar('Error', 'Shortcut dan Message tidak boleh kosong');
      return;
    }
    final newId = (quickReplies.length + 1).toString().padLeft(2, '0');
    final newReply = QuickReply(
      id: newId,
      shortcut: shortcutController.text,
      message: messageController.text,
      imagePath: selectedImage.value?.path,
    );
    quickReplies.add(newReply);
    clearForm();
    Get.back();
  }

  void clearForm() {
    shortcutController.clear();
    messageController.clear();
    selectedImage.value = null;
    currentlyEditing.value = null; // Bersihkan item yang diedit
  }

  @override
  void onClose() {
    shortcutController.removeListener(validateForm);
    messageController.removeListener(validateForm);
    shortcutController.dispose();
    messageController.dispose();
    super.onClose();
  }
}