import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quick_controller.dart'; // Pastikan path import ini benar
import 'package:admin_gychat/models/quick_reply_model.dart'; // Pastikan path import ini benar
import 'dart:io'; // Diperlukan untuk tipe data File

class EditQuickReplyScreen extends GetView<QuickController> {
  final QuickReply? reply;
  const EditQuickReplyScreen({super.key, this.reply});

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = reply != null;

    // Inisialisasi controller hanya jika dalam mode edit dan saat pertama kali build
    if (isEditMode && controller.shortcutController.text != reply!.shortcut) {
      controller.shortcutController.text = reply?.shortcut ?? '';
      controller.messageController.text = reply?.message ?? '';
    } else if (!isEditMode) {
      // Dikosongkan hanya untuk mode tambah baru
      controller.shortcutController.clear();
      controller.messageController.clear();
      controller.selectedImage.value = null;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Text(
                      isEditMode ? 'Edit Quick Reply' : 'Tambah Quick Reply',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (isEditMode) {
                          controller.updateReply(reply!);
                        } else {
                          controller.saveNewReply();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildTextField(
                    label: 'Shortcut',
                    controller: controller.shortcutController),
                const SizedBox(height: 16),
                _buildTextField(
                    label: 'Message',
                    controller: controller.messageController,
                    maxLines: 5),
                const SizedBox(height: 16),
                const Text('Attach Media',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildMediaAttachment(isEditMode),
                if (isEditMode) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.showDeleteConfirmation(reply!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Delete',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
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

  /// Membangun bagian lampiran media, menampilkan placeholder atau gambar yang dipilih.
  Widget _buildMediaAttachment(bool isEditMode) {
    // --- PERUBAHAN DI SINI ---
    // Mengubah onTap untuk memanggil fungsi pilihan
    return GestureDetector(
      onTap: () => controller.showImageOptions(reply),
      child: Obx(() {
        final newPickedImage = controller.selectedImage.value;
        Image? displayImage;

        // --- Logika Penampilan Gambar Diperbarui ---
        if (newPickedImage != null) {
          // Jika ada gambar baru yang dipilih (atau ditandai hapus)
          if (newPickedImage.path.isNotEmpty) {
            // Jika path tidak kosong, tampilkan gambar baru
            displayImage = Image.file(newPickedImage, fit: BoxFit.cover);
          }
          // Jika path kosong (tanda hapus), displayImage tetap null, tampilkan placeholder
        } else if (isEditMode) {
          // Jika tidak ada interaksi baru, tampilkan gambar lama
          final existingImageFile = reply?.imageFile;
          final existingImagePath = reply?.imagePath;
          if (existingImageFile != null) {
            displayImage = Image.file(existingImageFile, fit: BoxFit.cover);
          } else if (existingImagePath != null && existingImagePath.isNotEmpty) {
            displayImage = Image.asset(existingImagePath, fit: BoxFit.cover);
          }
        }

        if (displayImage != null) {
          // Jika gambar tersedia, tampilkan dengan gaya baru.
          return _buildImageDisplay(image: displayImage);
        } else {
          // Jika tidak ada gambar, tampilkan placeholder.
          return Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Add Media', style: TextStyle(color: Colors.grey)),
                  ]),
            ),
          );
        }
      }),
    );
  }

  /// Membangun kartu tampilan gambar yang sesuai dengan screenshot.
  Widget _buildImageDisplay({required Image image}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container ini membungkus gambar dan memberinya border.
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(10.5), // Agar border tidak terpotong
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: image,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Menampilkan teks pesan di bawah gambar.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
                controller.messageController.text, // Dibuat reaktif
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
          ],
      ),
    );
  }
}