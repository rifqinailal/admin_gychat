// lib/shared/widgets/chat_list_tile.dart
import 'dart:io';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ChatListTile extends StatelessWidget {
  // Parameter yang akan diterima oleh widget ini
  final String? avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isSelected;
  final String roomType;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatListTile({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.isPinned = false,
    this.isOnline = false,
    required this.isSelected,
    required this.roomType,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    final bool isFileImage = hasImage && !avatarUrl!.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColor.secondary.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ThemeColor.primary : (unreadCount > 0 ? const Color.fromARGB(255, 229, 226, 226) : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: ThemeColor.grey4,
                  backgroundImage: hasImage ? (isFileImage ? FileImage(File(avatarUrl!)) : NetworkImage(avatarUrl!)) as ImageProvider : null,
                  child: !hasImage ? Icon(roomType == 'group' ? Icons.group : Icons.person, size: 25, color: ThemeColor.grey5) : null,
                ),
                if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ThemeColor.yelow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ThemeColor.gray,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ThemeColor.gray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isPinned)
                      Transform.rotate(
                        angle: 1.5, // dalam radian,
                        child: Icon(
                          Octicons.pin,
                          size: 18,
                          color: ThemeColor.gray,
                        ),
                      ),
                    SizedBox(width: isPinned ? 5 : 0),
                    if (unreadCount > 0)
                      Container( 
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColor.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
