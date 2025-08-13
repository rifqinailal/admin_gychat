import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  // Parameter yang akan diterima oleh widget ini
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isSelected;
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
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
     return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isSelected ? ThemeColor.secondary.withOpacity(0.3) : Colors.transparent,
        border: Border.all(
  color: isSelected
      ? ThemeColor.primary
      : (unreadCount > 0
          ? const Color.fromARGB(255, 229, 226, 226)
          // TAMBAHKAN BAGIAN INI: : nilai_jika_salah
          : Colors.grey.shade300), 
  width: 1,
),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?u=a042581f4e29026704d",
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: ThemeColor.yelow,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // `Expanded` akan "memaksa" anaknya (Column) untuk mengisi semua
          // ruang horizontal yang tersisa di dalam Row. Ini sangat penting!
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: ThemeColor.gray),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: ThemeColor.gray),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isPinned)
                    Transform.rotate(
                      angle: 1, // dalam radian,
                      child: Icon(Icons.push_pin_outlined, color: ThemeColor.gray),
                    ),
                    SizedBox(width: 5,),
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
    )
     );
  }
}
