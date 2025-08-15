

import 'package:admin_gychat/modules/arsip/detail_arsip_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class DetailArsipScreen extends GetView<DetailArsipController> {
  const DetailArsipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.archivedChats.length,
                itemBuilder: (context, index) {
                  final chat = controller.archivedChats[index];
                  return Obx(() {
                    // Ambil status `isSelected` langsung dari controller
                    final isSelected = controller.selectedArchivedChats.contains(chat);
                    return ChatListTile(
                      avatarUrl: "https://i.pravatar.cc/150?u=${chat.id}",
                      name: chat.name,
                      lastMessage: chat.name,
                      time: 'Arsip', // Contoh teks
                      unreadCount: chat.unreadCount,
                      isSelected: isSelected,
                      onTap: () {
                        // Semua logika sekarang memanggil fungsi dari `controller`
                        if (controller.selectedArchivedChats.isNotEmpty) {
                          controller.toggleSelection(chat);
                        } else {
                          Get.toNamed(
                            AppRoutes.ROOM_CHAT,
                            arguments: {
                              "id": chat.id,
                              "name": chat.name,
                              "isGroup": chat.isGroup,
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
            // Cek status seleksi langsung dari controller
            if (controller.selectedArchivedChats.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.unarchive_outlined, color: Colors.black),
                onPressed: () {
                  // Panggil fungsi unarchive dari controller
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