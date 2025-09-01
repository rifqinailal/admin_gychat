// lib/modules/grup/detail_grup/edit_description_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class EditDescriptionScreen extends GetView<DetailGrupController> {
  const EditDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom top bar replacing the AppBar
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
                              fontFamily: 'Poppins',
                              color: ThemeColor.black,
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Edit Description',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: ThemeColor.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      InkWell(
                        onTap: controller.saveGroupDescription,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Poppins',
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

                  // Refactored TextField with direct styling
                  TextField(
                    controller: controller.descriptionController,
                    autofocus: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Group Description',
                      filled: true,
                      fillColor: ThemeColor.grey3,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 30
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}