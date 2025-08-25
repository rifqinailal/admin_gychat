import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'quick_controller.dart';
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'dart:io';

class EditQuickReplyScreen extends GetView<QuickController> {
  final QuickReply? reply;
  const EditQuickReplyScreen({super.key, this.reply});

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = reply != null;

    if (isEditMode && controller.shortcutController.text != reply!.shortcut) { 
      controller.shortcutController.text = reply?.shortcut ?? '';
      controller.messageController.text = reply?.message ?? '';
    } else if (!isEditMode && controller.shortcutController.text.isNotEmpty) {}
    //} else if (!isEditMode) {
    //controller.shortcutController.clear();
    //controller.messageController.clear();
    //controller.selectedImage.value = null;
    //}

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ThemeColor.lightGrey1,
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
                            color: ThemeColor.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      isEditMode ? 'Edit Quick Reply' : 'Tambah Quick Reply',
                      style: const TextStyle(
                        color: ThemeColor.black,
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
                            color: ThemeColor.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Obx(
                  () => _buildTextField(
                    label: 'Shortcut',
                    controller: controller.shortcutController,
                    errorText: controller.shortcutErrorText.value,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    // Panggil validasi setiap kali user mengetik
                    onChanged: (value) => controller.validateShortcut(currentReplyId: reply?.id),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => _buildTextField(
                  label: 'Message',
                  controller: controller.messageController,
                  maxLines: 5,
                  errorText: controller.messageErrorText.value,
                )),
                const SizedBox(height: 16),
                const Text(
                  'Attach Media',
                  style: TextStyle(
                    color: ThemeColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMediaAttachment(isEditMode),
                // [NEW] Tampilkan pesan error di bawah media jika ada
                Obx(() {
                  if (controller.mediaError.value &&
                      controller.messageErrorText.value != null) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 6.0),
                      child: Text(
                        controller.messageErrorText.value!,
                        style: const TextStyle(
                            color: ThemeColor.Red1, fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                if (isEditMode) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.showDeleteConfirmation(reply!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeColor.Red1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ThemeColor.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ThemeColor.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.transparent,
              width: 1.5,
            ),
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: 'Enter $label',
              errorText: null,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 6.0),
            child: Text(
              errorText,
              style: const TextStyle(color: ThemeColor.Red1, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Attach Media
  Widget _buildMediaAttachment(bool isEditMode) { 
    return GestureDetector(
      onTap: () => controller.showImageOptions(reply),
      child: Obx(() { 
        final newPickedImage = controller.selectedImage.value;
        Image? displayImage;
        final bool hasError = controller.mediaError.value;

        if (newPickedImage != null) { 
          if (newPickedImage.path.isNotEmpty) { 
            displayImage = Image.file(newPickedImage, fit: BoxFit.cover);
          }
        } else if (isEditMode) { 
          final existingImageFile = reply?.imageFile;
          final existingImagePath = reply?.imagePath;
          if (existingImageFile != null) {
            displayImage = Image.file(existingImageFile, fit: BoxFit.cover);
          } else if (existingImagePath != null &&
              existingImagePath.isNotEmpty) {
            displayImage = Image.asset(existingImagePath, fit: BoxFit.cover);
          }
        }

        if (displayImage != null) {
          return _buildImageDisplay(image: displayImage, hasError: hasError);
        } else { 
          return Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ThemeColor.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: hasError ? Colors.red : Colors.transparent,
                width: 1.5,
              ),
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
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 35,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add Media',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildImageDisplay({required Image image, required bool hasError}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
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
          Container( 
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.5),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: image,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding( 
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              controller.messageController.text,
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
