// lib/modules/room_chat/widget/pinned_message_bar.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PinnedMessageBar extends StatelessWidget {
  final MessageModel message;
  const PinnedMessageBar({super.key, required this.message});

  Widget _buildMessageContent() {
    final bool hasText = message.text != null && message.text!.isNotEmpty;

    IconData? iconData;
    String displayText;

    switch (message.type) {
      case MessageType.image:iconData = Icons.photo_camera_back_outlined;
      displayText = hasText ? message.text! : 'Foto';
      break;
      case MessageType.document:iconData = Icons.insert_drive_file_outlined;
      displayText = hasText ? message.text! : (message.documentName ?? 'Dokumen');
      break;
      case MessageType.text:default:displayText = message.text ?? 'Pesan disematkan';
      break;
    }

    return Row(
      children: [
        if (iconData != null)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            iconData,
            color: Colors.white,
            size: 18,
          ),
        ),
        Expanded(
          child: Text(
            displayText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<RoomChatController>().jumpToPinnedMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: const Color(0xFF1D2C86),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Pin_fill.svg',
              width: 21,
              height: 21,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMessageContent(),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
} 