// lib/modules/grup/detail_grup/grup_qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'detail_grup_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class GrupQrCodeScreen extends GetView<DetailGrupController> {
  const GrupQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      appBar: AppBar(
        backgroundColor: ThemeColor.white,
        elevation: 0.8,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, 
            color: ThemeColor.black, 
            size: 22
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kode QR Grup',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ThemeColor.black, 
            fontWeight: FontWeight.normal, 
            fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share, 
              color: ThemeColor.black, 
              size: 24
            ),
            onPressed: controller.forwardInviteLink,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ThemeColor.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColor.grey4.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                child: Column(
                  children: [ 
                    Obx(() => CircleAvatar(
                      radius: 35,
                      backgroundColor: ThemeColor.lightGrey1,
                      backgroundImage: controller.groupImage.value != null ? FileImage(controller.groupImage.value!) : null,
                      child: controller.groupImage.value == null ? const Icon(Icons.group, size: 45, color: ThemeColor.grey5) : null,
                    )),
                    const SizedBox(height: 15),
                    Obx(() => Text(
                      controller.groupName.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.black
                      ),
                        )),
                    const SizedBox(height: 5),
                    const Text(
                      'Grup GyChat',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15, 
                        fontWeight: FontWeight.normal, 
                        color: ThemeColor.black
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => QrImageView(
                      data: controller.groupInviteLink.value,
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Kode QR grup ini bersifat privat. Jika Anda membagikannya kepada seseorang, dia dapat memindainya dengan kamera Gychat untuk bergabung ke grup ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 14, 
                    color: ThemeColor.black, 
                    height: 1.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}