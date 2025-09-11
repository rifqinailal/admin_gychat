// lib/modules/grup/detail_grup/edit_detail_profile_grup_screen.dart 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'detail_grup_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class EditDetailProfileGrupScreen extends StatelessWidget { 
  const EditDetailProfileGrupScreen({super.key});

  @override
  Widget build(BuildContext context) { 
    final controller = Get.find<DetailGrupController>();
    return Container( 
      decoration: const BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ), 
      height: MediaQuery.of(context).size.height * 0.85,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [ 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel', 
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: ThemeColor.black, 
                          fontSize: 17, 
                          fontWeight: FontWeight.normal
                        ),
                      ),
                    ),
                    const Text(
                      'Edit Group',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: ThemeColor.black, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 17
                      ),
                    ),
                    TextButton(
                      onPressed: controller.saveGroupInfo,
                      child: const Text(
                        'Save', 
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: ThemeColor.black, 
                          fontSize: 17, 
                          fontWeight: FontWeight.normal
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                Expanded( 
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (controller.groupImage != null) {
                              controller.viewGroupImage();
                            } else {
                              _showPhotoOptions(controller);
                            }
                          },
                          child: Obx(() => CircleAvatar(
                            radius: 50,
                            backgroundColor: ThemeColor.grey4,
                            backgroundImage: controller.groupImage != null ? FileImage(controller.groupImage!) : null,
                            child: controller.groupImage == null ? Icon(Icons.group, size: 60, color: ThemeColor.grey5) : null,
                          )),
                        ),
                        const SizedBox(height: 1),
                        TextButton(
                          onPressed: () => _showPhotoOptions(controller),
                          child: const Text(
                            'Add Photo',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: ThemeColor.yelow,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GetBuilder<DetailGrupController>(
                          builder: (c) {
                            return TextFormField(
                              controller: c.nameController,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Poppins', 
                                fontSize: 16, 
                                color: ThemeColor.black
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: ThemeColor.lightGrey3,
                                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: c.nameController.text.isNotEmpty ? IconButton( icon: Icon(Icons.cancel, color: ThemeColor.mediumGrey2),
                                onPressed: () {
                                  c.nameController.clear();
                                  c.update();
                                }): null,
                              ),
                              onChanged: (value) {
                                c.update();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Mengubah foto grup
  void _showPhotoOptions(DetailGrupController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          12, 
          12, 
          12, 
          34 + MediaQuery.of(Get.context!).viewPadding.bottom
        ),
        decoration: const BoxDecoration(
          color: ThemeColor.grey6,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: ThemeColor.grey2,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: ThemeColor.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildBottomSheetOption(
                      text: 'Take Photo',
                      icon: Icons.photo_camera_outlined,
                      onTap: () {
                        Get.back();
                        controller.pickImage(ImageSource.camera);
                      },
                    ),
                    const Divider(height: 0.5, indent: 18, endIndent: 18),
                    _buildBottomSheetOption(
                      text: 'Choose Photo',
                      icon: Icons.image_outlined,
                      textColor: ThemeColor.black,
                      iconColor: ThemeColor.black,
                      onTap: () {
                        Get.back();
                        controller.pickImage(ImageSource.gallery);
                      },
                    ),
                    if (controller.groupImage != null) ...[
                      const Divider(height: 0.5, indent: 18, endIndent: 18),
                      _buildBottomSheetOption(
                        text: 'Delete Photo',
                        icon: Icons.delete_outline,
                        textColor: ThemeColor.Red1,
                        iconColor: ThemeColor.Red1,
                        onTap: () {
                          Get.back();
                          _showDeleteConfirmationSheet(controller);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: ThemeColor.black.withOpacity(0.3),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  Widget _buildBottomSheetOption({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = ThemeColor.black,
    Color iconColor = ThemeColor.black,
  }) {
    return Material(
      color: ThemeColor.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  color: textColor,
                ),
              ),
              Icon(icon, color: iconColor, size: 26),
            ],
          ),
        ),
      ),
    );
  }
  void _showDeleteConfirmationSheet(DetailGrupController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          16, 
          24, 
          16, 
          34 + MediaQuery.of(Get.context!).viewPadding.bottom
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.white,
                  foregroundColor: ThemeColor.Red1,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  controller.deletePhoto();
                },
                child: const Text('Delete Photo', style: TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.normal)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.primary,
                  foregroundColor: ThemeColor.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.normal)),
              ),
            ),
          ],
        ),
      ),
      ignoreSafeArea: false,
    );
  }
}