import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final bool isSystemMessage;
  final DateTime timestamp;
  final bool showTail;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  // PENAMBAHAN PARAMETER BARU UNTUK HIGHLIGHT
  final String? highlightText;

  const ChatBubble({
    super.key,
    required this.text,
    this.isSender = false,
    this.isSystemMessage = false,
    required this.timestamp,
    required this.showTail,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.highlightText,
  });

  // METHOD BARU UNTUK MEMBUAT TEKS DENGAN HIGHLIGHT
  Widget _buildHighlightedText() {
    // Jika tidak ada kata kunci pencarian, tampilkan Text biasa.
    if (highlightText == null || highlightText!.isEmpty) {
      return Text(
        text,
        style: TextStyle(color: isSender ? Colors.white : Colors.black),
      );
    }

    final regex = RegExp(highlightText!, caseSensitive: false);
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(color: isSender ? Colors.white : Colors.black),
      );
    }

    // `RichText` bisa menampilkan teks dengan berbagai gaya berbeda dalam satu widget.
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isSender ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        // `children` diisi oleh list `TextSpan` yang sudah dipecah.
        children: _generateSpans(text, matches),
      ),
    );
  }

  // Fungsi untuk memecah teks menjadi bagian normal dan bagian highlight.
  List<TextSpan> _generateSpans(String text, Iterable<RegExpMatch> matches) {
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Tambahkan bagian teks normal (sebelum kata kunci).
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      // Tambahkan bagian teks yang cocok (kata kunci) dengan gaya berbeda.
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            backgroundColor: Colors.yellow, // Warna highlight
            color: Colors.black, // Warna teks di dalam highlight
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    // Tambahkan sisa teks normal (setelah kata kunci terakhir).
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // Widget untuk membuat ekornya
    Widget buildTail(bool isSender) {
      return Positioned(
        bottom: 0,
        right: isSender ? -6 : null,
        left: isSender ? null : -6,
        child: Icon(
          isSender ? Icons.arrow_right : Icons.arrow_left,
          size: 20,
          color: isSender ? const Color(0xFF1D2C86) : Colors.white,
        ),
      );
    }

    // `Column` untuk menyusun gelembung dan waktu
    return GestureDetector(
      // `onTap` dihubungkan ke parameter onTap dari constructor.
      onTap: onTap,
      // `onLongPress` dihubungkan ke parameter onLongPress dari constructor.
      onLongPress: onLongPress,

      // 2. DIBUNGKUS DENGAN Container UNTUK WARNA SELEKSI
      //    Container ini bertugas memberi warna latar saat bubble dipilih.
      child: Container(
        // `color` diatur secara kondisional.
        // Jika `isSelected` bernilai true, beri warna biru transparan.
        // Jika false, buat transparan (tidak berwarna).
        color: isSelected ? const Color(0xFF1D2C86).withOpacity(0.3) : Colors.transparent,

        // 3. KONTEN ASLI ANDA
        //    Seluruh Column yang sudah Anda buat sebelumnya diletakkan di sini.
        //    Tidak ada yang berubah di dalam Column ini.
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              child: Align(
                alignment:
                    isSystemMessage
                        ? Alignment.center
                        : (isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bubble Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSystemMessage
                                ? Colors.yellow.shade200
                                : (isSender
                                    ? const Color(0xFF1D2C86)
                                    : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(
                            showTail && !isSender ? 0 : 16,
                          ),
                          bottomRight: Radius.circular(
                            showTail && isSender ? 0 : 16,
                          ),
                        ),
                      ),
                      child:
                          _buildHighlightedText(), // Memanggil method highlight
                    ),
                    // Tampilkan ekor hanya jika `showTail` adalah true
                    if (showTail && !isSystemMessage) buildTail(isSender),
                  ],
                ),
              ),
            ),

            // Widget untuk Timestamp
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
              child: Text(
                DateFormat('HH:mm').format(timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
