// lib/modules/archived_chats/archived_chats_screen.dart

import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_arsip_controller.dart';

class DetailArsipScreen extends GetView<DetailArsipController> {
  const DetailArsipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          SizedBox(height: 12),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.archivedChats.length,
                itemBuilder: (context, index) {
                  final chat = controller.archivedChats[index];
                  return ChatListTile(
                    avatarUrl: "https://i.pravatar.cc/150?u=${chat.name}",
                    name: chat.name,
                    lastMessage: "Chat ini telah diarsipkan",
                    time: '2 hari yang lalu',
                    unreadCount: chat.unreadCount,
                    isSelected: false,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.ROOM_CHAT,
                        arguments: {
                          "id": chat.id,
                          "name": chat.name,
                          "isGroup": chat.isGroup,
                        },
                      );
                    },
                    onLongPress: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          Text(
            'Diarsipkan',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
           padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
          icon: const Icon(Icons.unarchive_outlined, color: Colors.black),
          onPressed: () {
            // Tambahkan logika untuk "unarchive" di sini
          },
        ),
        )
      ],
    );
  }
}
