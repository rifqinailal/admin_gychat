// lib/app/modules/chat_list/chat_list_view.dart
import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:admin_gychat/shared/widgets/chat_header.dart';
import 'package:admin_gychat/shared/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'chat_list_controller.dart';

enum ChatListType { all, unread, group }

class ChatListView extends GetView<ChatListController> {
  final ChatListType listType;

  const ChatListView({super.key, required this.listType});

  @override
  Widget build(BuildContext context) {
    List<ChatModel> getChatList() {
      switch (listType) {
        case ChatListType.all:
          return controller.allChats;

        case ChatListType.unread:
          return controller.unreadChats;

        case ChatListType.group:
          return controller.groupChats;
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const ChatHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final chatList = getChatList();

              if (controller.isSearching.value) {
                return _buildSearchResults();
              } else {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.DetailArsip);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Ionicons.ios_archive_outline,
                              color: ThemeColor.gray,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Diarsipkan',
                              style: TextStyle(
                                color: ThemeColor.gray,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              controller.archivedChatsCount.toString(),
                              style: const TextStyle(
                                color: ThemeColor.gray,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Chat List
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {
                          final chat = chatList[index];

                          return Obx(() {
                            final isSelected = controller.selectedChats
                                .contains(chat);

                            return ChatListTile(
                              isPinned: chat.isPinned,
                              name: chat.name,
                              lastMessage: "Hi, I have a problem with....",
                              avatarUrl:
                                  "https://i.pravatar.cc/150?u=${chat.name}",
                              time: "10.16",
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
                                      "members":
                                          "Pak Ketua, Pimpinan B, Admin A...",
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
                    ),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      return ListView(
        // padding: const EdgeInsets.all(16),
        children: [
          // Hasil Pencarian Chat
          if (controller.searchResultChats.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Chat',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 10),
            ...controller.searchResultChats.map((chat) {
              return ChatListTile(
                name: chat.name,
                avatarUrl: "https://i.pravatar.cc/150?u=${chat.id}",
                unreadCount: chat.unreadCount,
                isPinned: chat.isPinned,
                lastMessage: 'assalamualaikum',
                time: "10.11",
                isSelected: false,
                isOnline: false,
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
            const SizedBox(height: 10),
          ],

          // Hasil Pencarian Pesan
          if (controller.searchResultMessages.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Pesan',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...controller.searchResultMessages.map((result) {
              return ListTile(
                textColor: Colors.grey,
                // leading: CircleAvatar(
                //   backgroundImage: NetworkImage(
                //     "https://i.pravatar.cc/150?u=${result.chat.id}",
                //   ),
                // ),
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

          // Tampilkan pesan jika tidak ada hasil
          if (controller.searchResultChats.isEmpty &&
              controller.searchResultMessages.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada hasil pencarian',
                  style: TextStyle(color: ThemeColor.gray, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
