// lib/app/modules/setting/away_message/edit_message_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'away_controller.dart';

class EditMessageScreen extends StatelessWidget {
  const EditMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AwayController controller = Get.find<AwayController>();
    final textController = TextEditingController(text: controller.message.value);

    return Container(
      // Menggunakan constraints agar lebih fleksibel di berbagai ukuran layar
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
                      const Text(
                        'Edit Away Message',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: ThemeColor.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.saveMessage(textController.text);
                        },
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
                    // Mengatur maxLines ke null agar TextField bisa memanjang tanpa batas.
                    maxLines: null,
                    // Hapus minLines agar tinggi bisa menyesuaikan dari 1 baris.
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ThemeColor.grey3,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 30),
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
