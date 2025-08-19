// lib/modules/grup/detail_grup/grup_invite_link_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

class GrupInviteLinkScreen extends GetView<DetailGrupController> {
  const GrupInviteLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Tautan Grup',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // --- [UBAH DI SINI] Bungkus dengan InkWell ---
          InkWell(
            onTap: controller.launchGroupLink, // Panggil fungsi saat ditekan
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Obx(() => CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: controller.groupImage.value != null
                            ? FileImage(controller.groupImage.value!)
                            : null,
                        child: controller.groupImage.value == null
                            ? const Icon(Icons.group, size: 40, color: Colors.grey)
                            : null,
                      )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              controller.groupName.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.groupInviteLink.value,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue.shade700,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),

          // --- Bagian Tombol Aksi ---
          ListTile(
            leading: Transform.scale(
              scaleX: -1,
              child: const Icon(Icons.reply, color: Colors.black54),
            ),
            title: const Text('Forward link', style: TextStyle(fontSize: 17)),
            onTap: controller.forwardInviteLink,
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.black54),
            title: const Text('Copy link', style: TextStyle(fontSize: 17)),
            onTap: controller.copyInviteLink,
          ),
          // [UBAH DI SINI] Tombol untuk membuka halaman QR Code
          ListTile(
            leading: const Icon(Icons.qr_code, color: Colors.black54),
            title: const Text('Kode QR', style: TextStyle(fontSize: 17)),
            onTap: controller.goToQrCodeScreen, // Panggil fungsi navigasi baru
          ),
        ],
      ),
    );
  }
}