// lib/modules/room_chat/widget/pinned_message_bar.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PinnedMessageBar extends StatelessWidget {
  final MessageModel message;
  const PinnedMessageBar({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Text(
              message.text ?? 'Gambar',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
