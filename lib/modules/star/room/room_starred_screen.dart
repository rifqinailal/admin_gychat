// lib/modules/star/room/room_starred_screen.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/star/widget/starred_message_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'room_starred_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class RoomStarredScreen extends GetView<RoomStarredController> {
  const RoomStarredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_room.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.filteredMessages.isEmpty) {
            return Center(
              child: Text(
                controller.isSearchActive.value ? 'Tidak ada hasil ditemukan' : 'Tidak ada pesan berbintang',
                style: const TextStyle(fontSize: 16, color: ThemeColor.grey2),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: controller.filteredMessages.length,
            itemBuilder: (context, index) {
              final message = controller.filteredMessages[index];
              return _buildMessageItem(message, context);
            },
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        if (controller.isSearchActive.value) {
          return _buildSearchAppBar();
        } else if (controller.isSelectionMode.value) {
          return _buildSelectionAppBar();
        } else {
          return _buildDefaultAppBar();
        }
      }),
    );
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: ThemeColor.black,
          size: 25
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Pesan Berbintang',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          color: ThemeColor.black,
          fontSize: 20
        ),
      ),
      actions: [
        IconButton(
          icon: Transform.rotate(
            angle: 1.3,
            child: const Icon(
              Icons.search,
              color: ThemeColor.black,
              size: 25
            ),
          ),
          onPressed: () => controller.toggleSearch(),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: ThemeColor.black,
            size: 25
          ),
          onPressed: () => controller.confirmUnstarAllInRoom(),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      titleSpacing: 18.0,
      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColor.lightGrey2,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColor.darkGrey1, size: 20),
              onPressed: () => controller.toggleSearch(),
            ),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: ThemeColor.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.close, color: ThemeColor.black),
        onPressed: () => controller.exitSelectionMode(),
      ),
      title: Obx(() => Text(
        '${controller.selectedMessages.length} dipilih',
        style: const TextStyle(color: ThemeColor.black, fontSize: 18),
      )),
      actions: [
        IconButton(
          icon: const Icon(
            MaterialCommunityIcons.star_off_outline,
            color: ThemeColor.black
          ),
          onPressed: () => controller.confirmUnstarSelected(),
        ),
      ],
    );
  }

  Widget _buildMessageItem(MessageModel message, BuildContext context) {
    final contextName = controller.roomName;

    return GestureDetector(
      onTap: () => controller.handleMessageTap(message),
      onLongPress: () => controller.handleMessageLongPress(message),
      child: Obx(
        () {
          final isSelected = controller.selectedMessages.contains(message);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isSelected ? ThemeColor.lightBlue30 : Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: ThemeColor.grey4,
                  child: Icon(
                    Icons.person,
                    color: ThemeColor.grey5,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              Icons.play_arrow,
                              size: 14,
                              color: ThemeColor.black
                            ),
                          ),
                          Expanded(
                            child: Text(
                              contextName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            DateFormat('dd/MM/yy').format(message.timestamp),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal,
                              color: ThemeColor.black,
                              fontSize: 14
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      StarredMessageCard(message: message),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}