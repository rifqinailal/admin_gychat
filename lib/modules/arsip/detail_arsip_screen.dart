// lib/modules/archived_chats/archived_chats_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_arsip_controller.dart';

class DetailArsipScreen extends GetView<DetailArsipController> {
  const DetailArsipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.detailArsip.length,
          itemBuilder: (context, index) {
            final chat = controller.detailArsip[index];
            return _buildChatItem(chat);
          },
        ),
      ),
    );
  }

  // Widget untuk membuat AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.8,
      shadowColor: Colors.white.withOpacity(0.3),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Diarsipkan',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.unarchive_outlined, color: Colors.black),
          onPressed: () {
            // Tambahkan logika untuk "unarchive" di sini
          },
        ),
      ],
    );
  }

  // Widget untuk membuat satu item dalam daftar chat
  Widget _buildChatItem(DetailArsip chat) {
    // Warna teks pesan: hijau jika sedang mengetik, abu-abu jika tidak
    final messageColor = chat.isTyping ? Colors.blue[700] : Colors.grey[600];
    // Warna timestamp: biru jika ada pesan belum dibaca, abu-abu jika tidak
    final timeColor = chat.unreadCount > 0 ? Colors.blue[700] : Colors.grey;

    return Container(
      // Memberi highlight biru jika item dipilih (isSelected == true)
      color: chat.isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Avatar Pengirim
          CircleAvatar(
            radius: 28,
            // Anda bisa menggunakan NetworkImage jika URL dari internet
            // atau AssetImage jika dari folder assets
            backgroundImage: AssetImage(chat.avatarUrl),
          ),
          const SizedBox(width: 14),

          // Kolom untuk Nama dan Preview Pesan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.senderName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    // Tampilkan titik merah jika ada mention
                    if (chat.hasMention)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    // Preview pesan
                    Expanded(
                      child: Text(
                        chat.messagePreview,
                        style: TextStyle(
                          fontSize: 14,
                          color: messageColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Kolom untuk Waktu dan Badge Unread
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                chat.timestamp,
                style: TextStyle(
                  fontSize: 12,
                  color: timeColor,
                ),
              ),
              const SizedBox(height: 8),
              // Tampilkan badge notifikasi jika ada pesan belum dibaca
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                // Beri ruang kosong agar sejajar
                const SizedBox(height: 18),
            ],
          ),
        ],
      ),
    );
  }
}