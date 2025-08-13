import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/widgets/chat_header.dart';
import 'package:admin_gychat/shared/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_list_controller.dart';

enum ChatListType { all, unread, group }

class ChatListView extends GetView<ChatListController> {
  final ChatListType listType;

  const ChatListView({super.key, required this.listType});

  @override
  Widget build(BuildContext context) {
    // Obx tetap membungkus semuanya agar seluruh UI bisa reaktif
    return Obx(() {
      List<ChatModel> chatList;
      switch (listType) {
        case ChatListType.all:
          chatList = controller.allChats;
          break;
        case ChatListType.unread:
          chatList = controller.unreadChats;
          break;
        case ChatListType.group:
          chatList = controller.groupChats;
          break;
      }

      // 2. GUNAKAN COLUMN SEBAGAI WIDGET UTAMA
      // untuk menyusun Header di atas dan List di bawah.
      return Column(
        children: [
          // ANAK PERTAMA: PANGGIL WIDGET HEADER ANDA
          const ChatHeader(),

          // ANAK KEDUA: GUNAKAN EXPANDED
          // Ini sangat penting agar ListView tahu batasan tingginya.
          Expanded(
            // ListView.builder Anda sekarang berada di dalam Expanded
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chat = chatList[index];
                // GANTI ListTile YANG LAMA DENGAN INI
                return Obx(() {
                  final isSelected = controller.selectedChats.contains(chat);
                  return ChatListTile(
                    // Hubungkan data dari model Anda ke parameter widget
                    name: chat.name,
                    lastMessage:
                        "Hi, I have a problem with....", // Ganti dengan data asli
                    avatarUrl:
                        "https://i.pravatar.cc/150?u=${chat.name}", // Contoh URL dinamis
                    time: "10.16", // Ganti dengan data asli
                    unreadCount: chat.unreadCount,
                    isOnline: chat.name == 'Jeremy Owen',
                    isPinned:
                        chat.name == 'Jeremy Owen', // Contoh logika online
                    isSelected: isSelected,
                    onTap: () {
                      if (controller.isSelectionMode.value) {
                        controller.toggleSelection(chat);
                      } else {
                        // Ganti print dengan navigasi menggunakan GetX
                        Get.toNamed(
                          AppRoutes.ROOM_CHAT,
                          arguments: {
                            "id": chat.id, // Pastikan ChatModel punya id
                            "name": chat.name,
                            "isGroup":
                                chat.isGroup, // Pastikan ChatModel punya isGroup
                            "members":
                                "Pak Ketua, Pimpinan B, Admin A...", // Contoh
                          },
                        );
                      }
                    },
                    onLongPress: () {
                      // Selalu mulai mode seleksi saat di-tap lama.
                      controller.startSelection(chat);
                    },
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }
}
