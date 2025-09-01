// lib/app/modules/room_chat/widgets/room_chat_app_bar.dart
import 'dart:io';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import '../room_chat_controller.dart';

// Widget ini sekarang menjadi StatefulWidget atau GetWidget agar bisa punya method sendiri
class RoomChatAppBar extends GetView<RoomChatController>
    implements PreferredSizeWidget {
  const RoomChatAppBar({super.key});

  // Method-method build AppBar dipindahkan ke sini dari Screen
  AppBar _buildNormalAppBar() {

    final String? photoUrl = controller.chatRoomInfo['url_photo'];
    final bool hasImage = photoUrl != null && photoUrl.isNotEmpty;
    final bool isFileImage = hasImage && !photoUrl!.startsWith('http');

    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      leadingWidth: 35,
      titleSpacing: 5,
      leading: Padding(
        padding: EdgeInsets.only(left: 4),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      title: InkWell(
        onTap: (controller.chatRoomInfo['isGroup'] == true) ? () => Get.toNamed(AppRoutes.DetailGrup) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20, // Sesuaikan ukuran radius
                  backgroundColor: ThemeColor.grey4,
                  backgroundImage: hasImage ? (isFileImage ? FileImage(File(photoUrl!)) : NetworkImage(photoUrl!)) as ImageProvider : null,
                  child: !hasImage ? Icon(
                    controller.chatRoomInfo['isGroup'] == true ? Icons.group : Icons.person, size: 24, color: ThemeColor.grey5
                  ) : null,
                ),
                if (controller.chatRoomInfo['isOnline'] == 0)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: ThemeColor.yelow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.chatRoomInfo['name'] ?? 'Chat Room',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.chatRoomInfo['isGroup'] == true) {
                      return Text(
                        controller.chatRoomInfo['members'] ?? 'Tidak ada member',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(() {
                    if (controller.chatRoomInfo['isGroup'] == false) {
                      return Text(
                        'Online',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'search') {
              Future.delayed(Duration.zero, () {
                controller.toggleSearchMode();
              });
            } else if (value == 'room-star') {
              final String currentRoomId = controller.chatRoomInfo['id'].toString();
              final String currentRoomName = controller.chatRoomInfo['name'];
    
              Get.toNamed(
                AppRoutes.RoomStar,
                arguments: {
                  'roomId': currentRoomId,
                  'roomName': currentRoomName,
                },
              );
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'search',
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF1D2C86),
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'room-star',
                  child: Text(
                    'Pesan Berbintang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF1D2C86),
                    ),
                  ),
                ),
              ],
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      leadingWidth: 65,
      titleSpacing: -20,
      leading: IconButton(
        onPressed: () => controller.toggleSearchMode(),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      title: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 350),
        child: IntrinsicWidth(
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search...           ',
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            onChanged: (value) => controller.updateSearchQuery(value),
          ),
        ),
      ),
    );
  }

  AppBar _buildMessageSelectionAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      leadingWidth: 100,
      leading: Row(
        children: [
          IconButton(
            onPressed: () => controller.clearMessageSelection(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Obx(
            () => Text(
              '${controller.selectedMessages.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () {},
              icon: const Icon(Octicons.reply, size: 20),
            ),

            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () => controller.starSelectedMessages(),
              icon: Icon(FontAwesome5Regular.star, size: 20),
            ),

            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () => controller.pinSelectedMessages(),
              icon: Transform.rotate(
                angle: 1.5,
                child: Icon(Octicons.pin, size: 20),
              ),
            ),

            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () => controller.copySelectedMessagesText(),
              icon: const Icon(Icons.copy, size: 20),
            ),
            Obx(() {
              // Hanya tampilkan jika 1 pesan teks milik kita yang dipilih
              if (controller.selectedMessages.length == 1 &&
                  controller.selectedMessages.first.isSender &&
                  (controller.selectedMessages.first.type == MessageType.text ||
                      controller.selectedMessages.first.type ==
                          MessageType.image)) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.setEditMessage(),
                  icon: const Icon(Octicons.pencil, size: 20),
                );
              }
              return const SizedBox.shrink(); // Jika tidak, sembunyikan
            }),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () => controller.showDeleteConfirmationDialog(),
              icon: const Icon(FontAwesome5Regular.trash_alt, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isMessageSelectionMode.value) {
        return _buildMessageSelectionAppBar();
      } else if (controller.isSearchMode.value) {
        return _buildSearchAppBar();
      } else {
        return _buildNormalAppBar();
      }
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
