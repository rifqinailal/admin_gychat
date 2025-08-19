// lib/modules/grup/detail_grup/grup_qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'detail_grup_controller.dart';

class GrupQrCodeScreen extends GetView<DetailGrupController> {
  const GrupQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8, // Tambahkan sedikit elevasi/shadow
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kode QR Grup',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), // Lebih kecil dan bold
        ),
        centerTitle: false, // Judul di kiri
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: controller.forwardInviteLink, // Menggunakan fungsi forward yang sudah ada
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView( // Agar konten bisa di-scroll jika terlalu panjang
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // Sudut lebih tumpul
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4), // Posisi bayangan
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                child: Column(
                  children: [
                    // Avatar grup diganti dengan ikon generik sesuai desain
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
                    const SizedBox(height: 16),
                    Obx(() => Text(
                          controller.groupName.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )),
                    const SizedBox(height: 6),
                    const Text(
                      'Grup GyChat',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    // Tampilan QR Code di dalam container
                    Obx(() => QrImageView(
                          data: controller.groupInviteLink.value,
                          version: QrVersions.auto,
                          size: 220.0, // Ukuran disesuaikan
                          gapless: false,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Kode QR grup ini bersifat privat. Jika Anda membagikannya kepada seseorang, dia dapat memindainya dengan kamera gychat untuk bergabung ke grup ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}