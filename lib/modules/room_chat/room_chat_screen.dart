import 'package:admin_gychat/modules/room_chat/widget/chat_bubble.dart';
import 'package:admin_gychat/modules/room_chat/widget/date_separator.dart';
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

  // Method untuk AppBar saat mode normal
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
              controller.toggleSearchMode();
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

  // Method untuk AppBar saat mode search
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
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
        ),
        onChanged: (value) => controller.updateSearchQuery(value),
      ),
    );
  }

  // Di dalam class RoomChatScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MODIFIKASI DIMULAI DI SINI
      appBar: PreferredSize(
        // 1. Beri tahu ukuran standar sebuah AppBar.
        // `kToolbarHeight` adalah konstanta tinggi default AppBar di Flutter.
        preferredSize: const Size.fromHeight(kToolbarHeight),

        // 2. Widget dinamis Anda (Obx) sekarang menjadi `child`-nya.
        child: Obx(
          () =>
              controller.isSearchMode.value
                  ? _buildSearchAppBar()
                  : _buildNormalAppBar(),
        ),
      ),

      // AKHIR MODIFIKASI
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_room.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
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
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Panggilan untuk input bar sekarang ada di tempat yang benar
            _buildMessageInputBar(),
          ],
        ),
      ),
    );
  }

  // Method untuk input bar di bagian bawah
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
                fillColor: Colors.grey.shade100, // Warna abu-abu muda
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none, // Tanpa border luar
                ),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: ThemeColor.primary,
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
