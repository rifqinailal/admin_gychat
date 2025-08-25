// lib/modules/arsip/detail_arsip_screen.dart
import 'package:admin_gychat/modules/arsip/detail_arsip_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class DetailArsipScreen extends GetView<DetailArsipController> {
  const DetailArsipScreen({super.key});

  String _formatChatTime(DateTime? time) {
    if (time == null) {
      return '';
    }
    // Menggunakan cara manual untuk format HH:mm
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.archivedChats.length,
                itemBuilder: (context, index) {
                  final chat = controller.archivedChats[index];
                  return Obx(() { 
                    final isSelected = controller.selectedArchivedChats.contains(chat);
                    return ChatListTile(
                      avatarUrl: chat.urlPhoto,
                      name: chat.name,
                      lastMessage: chat.lastMessage ?? '',
                      time: _formatChatTime(chat.lastTime),
                      unreadCount: chat.unreadCount,
                      isSelected: isSelected,
                      roomType: chat.roomType, 
                      
                      onTap: () { 
                        if (controller.selectedArchivedChats.isNotEmpty) {
                          controller.toggleSelection(chat);
                        } else {
                          Get.toNamed(
                            AppRoutes.ROOM_CHAT,
                            arguments: {
                              "id": chat.roomId,
                              "name": chat.name,
                               "isGroup": chat.roomType == 'group', 
                            },
                          );
                        }
                      },
                      onLongPress: () { 
                        controller.toggleSelection(chat);
                      },
                    );
                  });
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text('Diarsipkan', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Obx(() { 
            if (controller.selectedArchivedChats.isNotEmpty) {
              return IconButton(
                icon: const Icon(Feather.upload, color: Colors.black),
                onPressed: () { 
                  controller.unarchiveChats();
                },
              );
            }
            return const SizedBox.shrink();
          }),
        )
      ],
    );
  }
}