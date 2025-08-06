// lib/app/modules/chat_list/chat_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_list_controller.dart';

// Enum untuk menentukan tipe list yang mau ditampilkan
enum ChatListType { all, unread, group }

class ChatListView extends GetView<ChatListController> {
  // Terima tipe list dari luar
  final ChatListType listType;

  const ChatListView({super.key, required this.listType});

  @override
  Widget build(BuildContext context) {
    // Obx akan secara otomatis membangun ulang ListView ketika
    // list yang sesuai (allChats, unreadChats, atau groupChats) berubah.
    return Obx(() {
      // Tentukan list mana yang akan digunakan berdasarkan `listType`
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

      return ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          // Nanti di sini Anda akan menggunakan widget ChatListTile dari folder shared
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(chat.name),
            subtitle: Text(chat.isGroup ? 'Ini adalah grup' : 'Pesan terakhir...'),
            trailing: chat.unreadCount > 0
                ? CircleAvatar(
                    radius: 12,
                    child: Text(chat.unreadCount.toString()),
                  )
                : null,
          );
        },
      );
    });
  }
}