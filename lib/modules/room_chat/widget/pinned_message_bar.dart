import 'package:admin_gychat/models/message_model.dart';
import 'package:flutter/material.dart';

class PinnedMessageBar extends StatelessWidget {
  final MessageModel message;
  const PinnedMessageBar({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1D2C86), 
      child: Row(
        children: [
          Transform.rotate(angle: 1,child: 
          Icon(Icons.push_pin, color: Colors.white, size: 20),),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.text ?? 'Gambar', 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}