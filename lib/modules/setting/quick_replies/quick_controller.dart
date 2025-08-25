// lib/modules/setting/quick_replies/quick_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'edit_quick_reply_screen.dart';
import 'package:get_storage/get_storage.dart';

class QuickController extends GetxController {
  final shortcutController = TextEditingController();
  final messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final _box = GetStorage();
  final _storageKey = 'quickReplies';

  //var quickReplies = <QuickReply>[
    //QuickReply(
      //id: '1',
      //shortcut: '01',
      //message: 'this is a quick message',
      //imagePath: 'assets/images/pp2.jpg',
    //),
  //].obs;

  var quickReplies = <QuickReply>[].obs;
  var selectedImage = Rx<File?>(null);
  var shortcutErrorText = Rx<String?>(null);
  var messageErrorText = Rx<String?>(null);
  var mediaError = Rx<bool>(false);

  @override
  void onInit() {
    super.onInit();
    _loadRepliesFromStorage();
  }

  void _loadRepliesFromStorage() {
    final List<dynamic>? storedReplies = _box.read<List<dynamic>>(_storageKey);
    if (storedReplies != null) {
      final replies = storedReplies
      .map((json) => QuickReply.fromJson(json as Map<String, dynamic>))
      .toList();
      quickReplies.assignAll(replies);
    }
  }
  
  Future<void> _saveRepliesToStorage() async {
    final List<Map<String, dynamic>> listToSave =
    quickReplies.map((reply) => reply.toJson()).toList();
    await _box.write(_storageKey, listToSave);
  }

  bool validateShortcut({String? currentReplyId}) {
    final shortcut = shortcutController.text;
    if (shortcut.isEmpty) {
      shortcutErrorText.value = 'Shortcut tidak boleh kosong.';
      return false;
    }
  
    if (shortcut.length > 3) {
      shortcutErrorText.value = 'Shortcut maksimal 3 digit angka.';
      return false;
    }

    // Cek duplikasi shortcut
    final isDuplicate = quickReplies.any((reply) {
      return reply.shortcut == shortcut && (currentReplyId == null || reply.id != currentReplyId);
    });

    if (isDuplicate) {
      shortcutErrorText.value = 'Shortcut ini sudah digunakan.';
      return false;
    }
    shortcutErrorText.value = null;
    return true;
  }

  bool _validateForm({QuickReply? existingReply}) {
    messageErrorText.value = null;
    mediaError.value = false;
    
    final isShortcutValid = validateShortcut(currentReplyId: existingReply?.id);
    if (!isShortcutValid) {
      return false; 
    }
    
    final isMessageFilled = messageController.text.isNotEmpty;
    
    bool isMediaAttached = false;
    if (selectedImage.value != null) {
      isMediaAttached = selectedImage.value!.path.isNotEmpty;
    } else if (existingReply != null) {
      isMediaAttached = (existingReply.imageFile != null || (
        existingReply.imagePath != null && existingReply.imagePath!.isNotEmpty
      ));
    }
    
    if (!isMessageFilled && !isMediaAttached) {
      const errorMsg = 'Harap isi pesan atau lampirkan media.';
      messageErrorText.value = errorMsg;
      mediaError.value = true;
      
      Get.snackbar(
        'Gagal Menyimpan',
        'Minimal harus ada 2 kolom yang terisi (Shortcut + Pesan/Media).',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.Red1.withOpacity(0.6),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    }
    return true;
  }

  void goToAddScreen() {
    shortcutController.clear();
    messageController.clear();
    selectedImage.value = null;
    shortcutErrorText.value = null;
    messageErrorText.value = null;
    mediaError.value = false;
    _showEditScreen();
  }

  void goToEditScreen(QuickReply reply) {
    shortcutController.text = reply.shortcut;
    messageController.text = reply.message;
    selectedImage.value = null;
    shortcutErrorText.value = null;
    messageErrorText.value = null;
    mediaError.value = false;
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
    if (!_validateForm()) return;

    final newReply = QuickReply(
      id: DateTime.now().toString(),
      shortcut: shortcutController.text,
      message: messageController.text,
      imageFile: selectedImage.value,
      imagePath: null,
    );
    quickReplies.add(newReply);
    _saveRepliesToStorage();
    Get.back();

    Get.snackbar(
      'Success',
      'Quick reply has been added successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.6),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
  }

  void updateReply(QuickReply reply) {
    if (!_validateForm(existingReply: reply)) return;

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
      _saveRepliesToStorage();
      quickReplies.refresh();
      Get.back();
      Get.snackbar(
        'Success',
        'Quick reply has been updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.6),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    }
  }
  
  void deleteReply(QuickReply reply) {
    quickReplies.removeWhere((r) => r.id == reply.id);
    _saveRepliesToStorage();
    Get.back();
    Get.back();
    Get.snackbar(
      'Success',
      'Quick reply has been deleted.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.6),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
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