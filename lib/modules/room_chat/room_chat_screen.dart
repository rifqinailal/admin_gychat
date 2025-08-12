import 'package:admin_gychat/data/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/widget/chat_bubble.dart';
import 'package:admin_gychat/modules/room_chat/widget/date_separator.dart';
import 'package:admin_gychat/modules/room_chat/widget/pinned_message_bar.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'room_chat_controller.dart';

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

        IconButton(
          onPressed: () => controller.starSelectedMessages(),
          icon: const Icon(Icons.star_border),
        ),

        IconButton(
          onPressed: () => controller.pinSelectedMessages(),
          icon: Transform.rotate(
            angle: 1,
            child: Icon(Icons.push_pin_outlined, color: Color(0xFF1D2C86)),
          ),
        ),

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

                  // Di dalam file RoomChatScreen.dart
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
                    return Slidable(
                      key: ValueKey(message.timestamp),
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        dismissible: DismissiblePane(
                          onDismissed: () {},
                          confirmDismiss: () async {
                            Future.delayed(Duration.zero, () {
                              controller.setReplyMessage(message);
                            });
                            return false;
                          },
                        ),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              controller.setReplyMessage(message);
                            },
                            backgroundColor: Colors.transparent,
                            foregroundColor: ThemeColor.primary,
                            icon: Icons.reply,
                            label: 'Reply',
                          ),
                        ],
                      ),

                      child: Obx(() {
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
                              senderName:
                                  isGroupChat ? message.senderName : null,
                              repliedMessage: message.repliedMessage,
                              isStarred: message.isStarred,
                              isPinned: message.isPinned,
                              isSelected: isSelected,
                              type: message.type,
                              imagePath: message.imagePath,
                              documentName: message.documentName,
                              onTap: () {
                                if (controller.isMessageSelectionMode.value) {
                                  controller.toggleMessageSelection(message);
                                } else if (message.type ==
                                        MessageType.document &&
                                    message.documentPath != null) {
                                  controller.openDocument(
                                    message.documentPath!,
                                  );
                                }
                              },
                              onLongPress: () {
                                controller.startMessageSelection(message);
                              },
                            ),
                          ],
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            Column(
              children: [
                _buildReplyPreview(),
                _buildQuickReplyList(),
                _buildMessageInputBar(),
              ],
            ),
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
            onPressed: () => controller.showAttachmentOptions(),
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
                // Tombol di belakang teks
                suffixIcon: IconButton(
                  onPressed: () => controller.takePicture(),
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

  Widget _buildQuickReplyList() {
    return Obx(() {
      if (!controller.showQuickReplies.value) {
        return const SizedBox.shrink();
      }
      final bool isEmpty = controller.filteredQuickReplies.isEmpty;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isEmpty ? 100 : 250,

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick replies',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.QuickReplies);
                    },

                    child: Obx(
                      () => Text(
                        controller.quickController.quickReplies.isEmpty
                            ? 'Setting'
                            : 'Edit',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.filteredQuickReplies.length,
                itemBuilder: (context, index) {
                  final reply = controller.filteredQuickReplies[index];
                  return ListTile(
                    leading: Text(
                      '/${reply.shortcut}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(reply.message),
                    onTap: () => controller.selectQuickReply(reply),
                  );
                },

                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16, // Jarak garis dari kiri
                    endIndent: 16, // Jarak garis dari kanan
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReplyPreview() {
    return Obx(() {
      // Jika tidak ada pesan yang di-reply, tampilkan widget kosong.
      if (controller.replyMessage.value == null) {
        return const SizedBox.shrink();
      }

      final message = controller.replyMessage.value!;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        color: Colors.white,
        child: Row(
          children: [
            // Baris vertikal
            Container(width: 4, height: 40, color: const Color(0xFF1D2C86)),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: const TextStyle(
                      color: Color(0xFF1D2C86),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message.text ?? 'Gambar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => controller.cancelReply(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
    });
  }
}
