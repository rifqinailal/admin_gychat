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
          Expanded(
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return Obx(() {
                  final isSelected = controller.selectedChats.contains(chat);
                  return ChatListTile(
                   isPinned: chat.isPinned,
                    name: chat.name,
                    lastMessage:
                        "Hi, I have a problem with....", 
                    avatarUrl:
                        "https://i.pravatar.cc/150?u=${chat.name}",
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
                            "isGroup":
                                chat.isGroup, 
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
    });
  }
}
