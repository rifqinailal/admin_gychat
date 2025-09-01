import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/widget/MessageInputBar.dart';
import 'package:admin_gychat/modules/room_chat/widget/RoomChatAppBar.dart';
import 'package:admin_gychat/modules/room_chat/widget/chat_bubble.dart';
import 'package:admin_gychat/modules/room_chat/widget/date_separator.dart';
import 'package:admin_gychat/modules/room_chat/widget/pinned_message_bar.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'room_chat_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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

class RoomChatScreen extends GetView<RoomChatController> {
  const RoomChatScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: RoomChatAppBar(), 
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_room.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Obx(() {
                if (controller.pinnedMessage.value != null) {
                  return PinnedMessageBar(
                    message: controller.pinnedMessage.value!,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              Expanded(
                child: Obx(
                  () => ScrollablePositionedList.builder(
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
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
                          final isHighlighted = controller.highlightedMessageId.value == message.messageId;
                          return Container(
                            color: isHighlighted ? ThemeColor.primary.withOpacity(0.2) : Colors.transparent,
                            child: Column(
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
                                  isSelected: isSelected,
                                  type: message.type,
                                  imagePath: message.imagePath,
                                  documentName: message.documentName,
                                  isDeleted: message.isDeleted,
                                  onTap: () { 
                                    if (controller.isMessageSelectionMode.value) {
                                      controller.toggleMessageSelection(message);
                                    } else if (message.type == MessageType.document && message.documentPath != null) {
                                      controller.openDocument(
                                        message.documentPath!
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    controller.startMessageSelection(message);
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              // Wrap MessageInputBar dengan Container dan padding untuk spacing tambahan
              MessageInputBar(),
            ],
          ),
        ),
      ),
    );
  }
} 