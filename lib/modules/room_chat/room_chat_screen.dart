// lib/modules/room_chat/room_chat_screen.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/widget/MessageInputBar.dart';
import 'package:admin_gychat/modules/room_chat/widget/RoomChatAppBar.dart';
import 'package:admin_gychat/modules/room_chat/widget/chat_bubble.dart';
import 'package:admin_gychat/modules/room_chat/widget/date_separator.dart';
import 'package:admin_gychat/modules/room_chat/widget/pinned_message_bar.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                            !isSameDay(
                              message.timestamp,
                              prevMessage.timestamp,
                            );
                      }

                      final bool showTail;
                      if (index == 0) {
                        showTail = true;
                      } else {
                        final prevMessage =
                            controller.filteredMessages[index - 1];
                        showTail = message.senderId != prevMessage.senderId;
                      }
                      return _SwipeToReplyWrapper(
                        message: message,
                        controller: controller,
                        child: Obx(() {
                          final isSelected = controller.selectedMessages
                              .contains(message);
                          final isHighlighted =
                              controller.highlightedMessageId.value ==
                              message.messageId;
                          return Container(
                            color:
                                isHighlighted
                                    ? ThemeColor.primary.withOpacity(0.2)
                                    : Colors.transparent,
                            child: Column(
                              children: [
                                if (showDateSeparator)
                                  DateSeparator(
                                    text: formatDateSeparator(
                                      message.timestamp,
                                    ),
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
                                  isDeleted: message.isDeleted,
                                  onTap: () {
                                    if (controller
                                        .isMessageSelectionMode
                                        .value) {
                                      controller.toggleMessageSelection(
                                        message,
                                      );
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

class _SwipeToReplyWrapper extends StatefulWidget {
  final Widget child;
  final MessageModel message;
  final RoomChatController controller;

  const _SwipeToReplyWrapper({
    required this.child,
    required this.message,
    required this.controller,
  });

  @override
  State<_SwipeToReplyWrapper> createState() => _SwipeToReplyWrapperState();
}

class _SwipeToReplyWrapperState extends State<_SwipeToReplyWrapper>
    with TickerProviderStateMixin {
  double _offsetX = 0.0;
  late AnimationController _animationController;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _hasTriggered = false;
        _animationController.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          final delta = details.delta.dx;

          // Batasi arah geser sesuai pengirim
          if (widget.message.isSender) {
            // Pesan dari kita: hanya bisa geser ke kiri
            if (delta < 0) {
              _offsetX = (_offsetX + delta).clamp(-50.0, 0.0);
            }
          } else {
            // Pesan dari orang lain: hanya bisa geser ke kanan
            if (delta > 0) {
              _offsetX = (_offsetX + delta).clamp(0.0, 50.0);
            }
          }

          // Trigger reply jika geser lebih dari 20px
          if (!_hasTriggered && _offsetX.abs() > 40) {
            _hasTriggered = true;
            widget.controller.setReplyMessage(widget.message);
            // Haptic feedback
            HapticFeedback.lightImpact();
          }
        });
      },
      onPanEnd: (details) {
        // Animasi kembali ke posisi normal
        _animationController.forward(from: 0.0).then((_) {
          setState(() {
            _offsetX = 0.0;
          });
        });
      },
      child: Stack(
        children: [
          // Background reply icon
          if (_offsetX.abs() > 5)
            Positioned.fill(
              child: Container(
                alignment:
                    widget.message.isSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                padding: EdgeInsets.only(
                  right: widget.message.isSender ? 30 : 0,
                  left: widget.message.isSender ? 0 : 30,
                ),
                child: Transform.rotate(
                  angle:
                      widget.message.isSender
                          ? 0
                          : 3.1416, // rotasi 180 derajat
                  child: Icon(
                    Icons.reply,
                    color: ThemeColor.primary.withOpacity(
                      (_offsetX.abs() / 50).clamp(0.5, 1.0),
                    ),
                    size: 20 + (_offsetX.abs() / 5),
                  ),
                ),
              ),
            ),
          // Content dengan transform
          Transform.translate(offset: Offset(_offsetX, 0), child: widget.child),
        ],
      ),
    );
  }
}
