// lib/modules/grup/detail_grup/edit_detail_profile_grup_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

// Ubah menjadi StatelessWidget karena kita tidak butuh GetView lagi
class EditDetailProfileGrupScreen extends StatelessWidget {
  const EditDetailProfileGrupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller secara manual
    final controller = Get.find<DetailGrupController>();

    // 1. Widget terluar adalah Container untuk styling (warna, border radius)
    return Container(
      // Atur agar sudut atasnya melengkung, persis seperti bottom sheet
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      // Atur tinggi agar hampir penuh layar, sisakan sedikit di atas
      height: MediaQuery.of(context).size.height * 0.85,
      child: Scaffold(
        // 2. Scaffold di dalam dibuat transparan agar warna Container terlihat
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                // 3. Buat AppBar manual menggunakan Row, seperti di contoh Anda
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal)),
                    ),
                    const Text(
                      'Edit Group',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    TextButton(
                      onPressed: controller.saveGroupInfo,
                      child: const Text('Save', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Isi kontennya sama seperti sebelumnya
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: controller.showEditPhotoOptions,
                          child: Column(
                            children: [
                              Obx(() => CircleAvatar(
                                    radius: 50,
                                    backgroundColor: const Color.fromARGB(255, 100, 100, 100).withOpacity(0.1),
                                    backgroundImage: controller.groupImage.value != null ? FileImage(controller.groupImage.value!) : null,
                                    child: controller.groupImage.value == null ? Icon(Icons.person, size: 60, color: const Color.fromARGB(149, 118, 118, 118).withOpacity(0.7)) : null,
                                  )),
                              const SizedBox(height: 12),
                              const Text('Add photo', style: TextStyle(color: Color.fromARGB(255, 253, 214, 20), fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        GetBuilder<DetailGrupController>(
                          builder: (c) {
                            return TextFormField(
                              controller: c.nameController,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 239, 239, 239),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: c.nameController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.cancel, color: Colors.grey.shade500),
                                        onPressed: () {
                                          c.nameController.clear();
                                          c.update();
                                        },
                                      )
                                    : null,
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
}