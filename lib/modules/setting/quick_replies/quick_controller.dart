// lib/modules/setting/quick_replies/quick_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // <-- Import package baru
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
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
  ].obs;

  var selectedImage = Rx<File?>(null);

  void goToAddScreen() {
    shortcutController.clear();
    messageController.clear();
    selectedImage.value = null;
    _showEditScreen();
  }

  void goToEditScreen(QuickReply reply) {
    shortcutController.text = reply.shortcut;
    messageController.text = reply.message;
    selectedImage.value = null;
    _showEditScreen(reply: reply);
  }

  void _showEditScreen({QuickReply? reply}) {
    Get.bottomSheet(
      Container(
        height: 700,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: EditQuickReplyScreen(reply: reply),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void showImageOptions(QuickReply? reply) {
    final bool hasExistingImage = selectedImage.value?.path.isNotEmpty ??
        (reply?.imageFile != null || (reply?.imagePath?.isNotEmpty ?? false));

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          spacing: 8,
          children: [
            if (hasExistingImage)
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Lihat Gambar'),
                onTap: () {
                  Get.back();
                  _showImagePreview(reply);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: Text(hasExistingImage ? 'Ganti dari Galeri' : 'Ambil dari Galeri'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(hasExistingImage ? 'Ganti dari Kamera' : 'Ambil dari Kamera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            if (hasExistingImage)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text('Hapus Gambar', style: TextStyle(color: Colors.red.shade700)),
                onTap: () {
                  Get.back();
                  removeImage();
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Batal'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(QuickReply? reply) {
    ImageProvider? imageProvider;
    if (selectedImage.value != null && selectedImage.value!.path.isNotEmpty) {
      imageProvider = FileImage(selectedImage.value!);
    } else if (reply?.imageFile != null) {
      imageProvider = FileImage(reply!.imageFile!);
    } else if (reply?.imagePath != null && reply!.imagePath!.isNotEmpty) {
      imageProvider = AssetImage(reply.imagePath!);
    }

    if (imageProvider != null) {
      Get.dialog(
        // Dialog dibuat transparan dan bisa di-zoom
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image(
                  image: imageProvider,
                ),
              ),
            ),
          ),
        ),
        barrierColor: Colors.transparent,
      );
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      if (source == ImageSource.camera) {
        // Jika dari kamera, panggil fungsi crop
        _cropImage(File(image.path));
      } else {
        // Jika dari galeri, langsung gunakan
        selectedImage.value = File(image.path);
      }
    }
  }

  // Fungsi baru untuk cropping
  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      // Parameter 'aspectRatioPresets' dipindahkan ke dalam uiSettings di bawah ini
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Gambar',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            // Ditambahkan di sini untuk Android
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ]),
        IOSUiSettings(
          title: 'Crop Gambar',
          aspectRatioLockEnabled: false,
           // Ditambahkan di sini untuk iOS
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      selectedImage.value = File(croppedFile.path);
    }
  }


  void removeImage() {
    selectedImage.value = File('');
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
      final QuickReply itemToUpdate = quickReplies[index];
      itemToUpdate.shortcut = shortcutController.text;
      itemToUpdate.message = messageController.text;

      if (selectedImage.value != null) {
        if (selectedImage.value!.path.isEmpty) {
          itemToUpdate.imageFile = null;
          itemToUpdate.imagePath = null;
        } else {
          itemToUpdate.imageFile = selectedImage.value;
          itemToUpdate.imagePath = null;
        }
      }

      quickReplies[index] = itemToUpdate;
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
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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