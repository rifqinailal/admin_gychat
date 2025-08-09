// lib/app/modules/room_chat/widgets/date_separator.dart

import 'package:flutter/material.dart';

class DateSeparator extends StatelessWidget {
  // Widget ini hanya butuh satu parameter: teks yang akan ditampilkan.
  final String text;

  const DateSeparator({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // `Center` agar widget berada di tengah layar secara horizontal.
    return Center(
      // `Container` untuk membuat kotak abu-abunya.
      child: Container(
        // `padding` untuk memberi jarak antara teks dan tepi kotak.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        // `margin` untuk memberi jarak antara pemisah ini dengan bubble chat.
        margin: const EdgeInsets.symmetric(vertical: 12),
        // `decoration` untuk menghias kotak.
        decoration: BoxDecoration(
          color: Colors.white, // Warna latar abu-abu.
          borderRadius: BorderRadius.circular(12), // Membuat sudut melengkung.
        ),
        // `Text` untuk menampilkan tanggalnya.
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}