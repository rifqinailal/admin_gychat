import 'package:admin_gychat/modules/room_chat/widget/chat_bubble.dart';
import 'package:admin_gychat/modules/room_chat/widget/date_separator.dart';
import 'package:admin_gychat/modules/room_chat/widget/pinned_message_bar.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'room_chat_controller.dart';

// FUNGSI HELPER UNTUK TANGGAL
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String formatDateSeparator(DateTime date) {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  if (isSameDay(date, now)) return "Today";
  if (isSameDay(date, yesterday)) return "Yesterday";
  return DateFormat('dd MMMM yyyy').format(date);
}
// AKHIR FUNGSI HELPER

class RoomChatScreen extends GetView<RoomChatController> {
  const RoomChatScreen({super.key});

  AppBar _buildNormalAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
              "https://i.pravatar.cc/150?u=a042581f4e29026704d",
            ),
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
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
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'search', child: Text('Search')),
                const PopupMenuItem(
                  value: 'starred',
                  child: Text('Pesan Berbintang'),
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
      leading: IconButton(
        onPressed: () => controller.toggleSearchMode(),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      title: TextField(
        controller: controller.searchController,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
        ),
        onChanged: (value) => controller.updateSearchQuery(value),
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
        IconButton(onPressed: () {}, icon: const Icon(Icons.reply)),
        // HUBUNGKAN FUNGSI STAR
        IconButton(
          onPressed: () => controller.starSelectedMessages(),
          icon: const Icon(Icons.star_border),
        ),
        // HUBUNGKAN FUNGSI PIN
        IconButton(
          onPressed: () => controller.pinSelectedMessages(),
          icon: Transform.rotate(
            angle: 1, // dalam radian,
            child: Icon(Icons.push_pin_outlined, color: Color(0xFF1D2C86)),
          ),
        ),
        // HUBUNGKAN FUNGSI COPY
        IconButton(
          onPressed: () => controller.copySelectedMessagesText(),
          icon: const Icon(Icons.copy),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          if (controller.isMessageSelectionMode.value) {
            return _buildMessageSelectionAppBar();
          } else if (controller.isSearchMode.value) {
            return _buildSearchAppBar();
          } else {
            return _buildNormalAppBar();
          }
        }),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_room.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Obx(() {
              // Cek apakah ada pesan yang di-pin di controller.
              if (controller.pinnedMessage.value != null) {
                // Jika ada, tampilkan widget PinnedMessageBar.
                return PinnedMessageBar(
                  message: controller.pinnedMessage.value!,
                );
              } else {
                // Jika tidak ada, tampilkan widget kosong.
                return const SizedBox.shrink();
              }
            }),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  itemCount: controller.filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = controller.filteredMessages[index];
                    final bool isGroupChat =
                        controller.chatRoomInfo['isGroup'] ?? false;

                    final bool showDateSeparator;
                    if (index == controller.filteredMessages.length - 1) {
                      showDateSeparator = true;
                    } else {
                      final prevMessage =
                          controller.filteredMessages[index + 1];
                      showDateSeparator =
                          !isSameDay(message.timestamp, prevMessage.timestamp);
                    }

                    final bool showTail;
                    if (index == 0) {
                      showTail = true;
                    } else {
                      final prevMessage =
                          controller.filteredMessages[index - 1];
                      showTail = message.senderId != prevMessage.senderId;
                    }

                    // ========================================================
                    // BAGIAN YANG DILENGKAPI ADA DI SINI
                    // ========================================================
                    return Obx(() {
                      // Cek apakah pesan ini ada di dalam daftar pilihan.
                      final isSelected = controller.selectedMessages.contains(
                        message,
                      );

                      return Column(
                        children: [
                          if (showDateSeparator)
                            DateSeparator(
                              text: formatDateSeparator(message.timestamp),
                            ),
                          ChatBubble(
                            text: message.text,
                            isSender: message.isSender,
                            timestamp: message.timestamp,
                            showTail: showTail,
                            highlightText: controller.searchQuery.value,
                            senderName: isGroupChat ? message.senderName : null,
                            repliedMessage: message.repliedMessage,
                            isStarred: message.isStarred,
                            isPinned: message.isPinned,
                            // Hubungkan parameter interaksi
                            isSelected: isSelected,
                            onTap: () {
                              if (controller.isMessageSelectionMode.value) {
                                controller.toggleMessageSelection(message);
                              }
                            },
                            onLongPress: () {
                              controller.startMessageSelection(message);
                            },
                          ),
                        ],
                      );
                    });
                  },
                ),
              ),
            ),
            _buildMessageInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.insert_drive_file_outlined,
              color: ThemeColor.primary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'write down the answer',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color(0xFF1D2C86),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color(0xFF1D2C86),
                    width: 2,
                  ),
                ),

                // Tombol di depan teks
                prefixIcon: IconButton(
                  onPressed: () {
                    // TODO: Aksi yang mau dilakukan saat tombol ditekan
                    print("Prefix icon ditekan");
                  },
                  icon: Transform.rotate(
                    angle: 1, // dalam radian,
                    child: Icon(Icons.remove, color: Color(0xFF1D2C86)),
                  ),
                ),

                // Tombol di belakang teks
                suffixIcon: IconButton(
                  onPressed: () {
                    // TODO: Aksi saat camera ditekan
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF1D2C86),
                  ),
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: controller.sendMessage,
            icon: const Icon(Icons.send, color: ThemeColor.primary),
          ),
        ],
      ),
    );
  }
}
