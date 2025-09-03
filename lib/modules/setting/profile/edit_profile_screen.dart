// lib/modules/setting/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class EditProfileScreen extends StatelessWidget {
  final String title;
  final String initialValue;
  final Function(String) onSave;

  const EditProfileScreen({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: initialValue);

    return Container(
      height: 700,
      child: Scaffold( 
      
      backgroundColor: ThemeColor.white,
      
      body: SafeArea(
        
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            fontFamily: 'Poppins',
                            color: ThemeColor.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: ThemeColor.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    InkWell(
                      onTap: () => onSave(textController.text),
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
                TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: 5,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: ThemeColor.grey3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 30, horizontal: 30
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
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