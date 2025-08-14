import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
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
      return Column(
        children: [
          const ChatHeader(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
            ), // Disesuaikan paddingnya
            child: InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.DetailArsip);
              },
              child: Row(
                children: [
                  const Icon(Icons.archive_outlined, color: ThemeColor.gray),
                  const SizedBox(width: 12),
                  const Text(
                    'Diarsipkan',
                    style: TextStyle(color: ThemeColor.gray, fontSize: 16),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      // Ambil jumlah dari getter baru kita dan ubah ke String
                      controller.archivedChatsCount.toString(),
                      style: const TextStyle(
                        color: ThemeColor.gray,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600, // Dibuat tebal agar terlihat
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            if (!controller.isSearching.value) {
              return Expanded(
                child: ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final chat = chatList[index];
                    return Obx(() {
                      final isSelected = controller.selectedChats.contains(
                        chat,
                      );
                      return ChatListTile(
                        isPinned: chat.isPinned,
                        name: chat.name,
                        lastMessage: "Hi, I have a problem with....",
                        avatarUrl: "https://i.pravatar.cc/150?u=${chat.name}",
                        time: "10.16", // Ganti dengan data asli
                        unreadCount: chat.unreadCount,
                        isOnline: chat.name == 'Jeremy Owen',
                        isSelected: isSelected,
                        onTap: () {
                          if (controller.isSelectionMode.value) {
                            controller.toggleSelection(chat);
                          } else {
                            Get.toNamed(
                              AppRoutes.ROOM_CHAT,
                              arguments: {
                                "id": chat.id,
                                "name": chat.name,
                                "isGroup": chat.isGroup,
                                "members": "Pak Ketua, Pimpinan B, Admin A...",
                              },
                            );
                          }
                        },
                        onLongPress: () {
                          controller.startSelection(chat);
                        },
                      );
                    });
                  },
                ),
              );
            } else {
              return _buildSearchResults();
            }
          }),
        ],
      );
    });
  }


  Widget _buildSearchResults() {
    return Expanded(
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.searchResultChats.isNotEmpty) ...[
              const Text(
                'Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              // `...` (spread operator) untuk memasukkan semua widget dari list
              ...controller.searchResultChats.map((chat) {
                // Untuk setiap `chat` di dalam hasil pencarian...
                return ChatListTile(
                  // Ambil data dari objek `chat`
                  name: chat.name,
                  avatarUrl: "https://i.pravatar.cc/150?u=${chat.id}",
                  unreadCount: chat.unreadCount,
                  isPinned: chat.isPinned,

                  // Teks dan waktu bisa menggunakan placeholder
                  lastMessage: "Hasil pencarian...",
                  time: "",

                  // Di halaman search, seleksi tidak aktif
                  isSelected: false,
                  isOnline:
                      false, // Status online bisa ditambahkan jika ada datanya
                  // Aksi saat di-tap: Buka room chat
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.ROOM_CHAT,
                      arguments: {
                        "id": chat.id,
                        "name": chat.name,
                        "isGroup": chat.isGroup,
                        "members": "Pak Ketua, Pimpinan B, Admin A...",
                      },
                    );
                  },
                  onLongPress: () {},
                );
              }).toList(),
              const SizedBox(height: 24),
            ],
            if (controller.searchResultMessages.isNotEmpty) ...[
              const Text(
                'Pesan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              ...controller.searchResultMessages.map((result) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?u=${result.chat.id}",
                    ),
                  ),
                  title: Text(
                    result.chat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    result.message.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap:
                      () => Get.toNamed(
                        AppRoutes.ROOM_CHAT,
                        arguments: {
                          "id": result.chat.id,
                          "name": result.chat.name,
                          "isGroup": result.chat.isGroup,
                          "members": "Pak Ketua, Pimpinan B, Admin A...",
                        },
                      ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
