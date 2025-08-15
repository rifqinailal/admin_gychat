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

    return Scaffold( 
      backgroundColor: Colors.white,
      
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
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(result: textController.text),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.grey,
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
                    fillColor: const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 