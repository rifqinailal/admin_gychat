// lib/modules/grup/detail_grup/grup_invite_link_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class GrupInviteLinkScreen extends GetView<DetailGrupController> {
  const GrupInviteLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: AppBar(
        backgroundColor: ThemeColor.white,
        elevation: 0,
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
          'Tautan Grup',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ThemeColor.black, 
            fontWeight: FontWeight.normal, 
            fontSize: 20
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14), 
          InkWell(
            onTap: controller.launchGroupLink,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 32,
                    backgroundColor: ThemeColor.grey4,
                    backgroundImage: controller.groupImage.value != null ? FileImage(controller.groupImage.value!) : null,
                    child: controller.groupImage.value == null ? const Icon(Icons.group, size: 38, color: ThemeColor.grey5) : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.groupName.value,
                          style: const TextStyle(
                            color: ThemeColor.black,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                              ),
                            )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          controller.groupInviteLink.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.normal,
                            color: ThemeColor.blue,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 8),

          ListTile( 
            leading: Transform.scale(
              scaleX: -1,
              child: const Icon(
                Icons.reply,
                size: 25,
                color: ThemeColor.black
              ),
            ),
            title: const Text(
              'Forward link', 
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
            ),
            onTap: controller.forwardInviteLink,
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: ThemeColor.black, size: 23),
            title: const Text(
              'Copy link', 
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                color: ThemeColor.black,
                fontSize: 17
              ),
            ),
            onTap: controller.copyInviteLink,
          ),
          ListTile( 
            leading: const Icon(Icons.qr_code, color: ThemeColor.black,size: 23),
            title: const Text(
              'Kode QR', 
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                color: ThemeColor.black,
                fontSize: 17
              ),
            ),
            onTap: controller.goToQrCodeScreen, 
          ),
        ],
      ),
    );
  }
}