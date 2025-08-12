import 'dart:io';

import 'package:admin_gychat/data/models/message_model.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String? text;
  final bool isSender;
  final bool isSystemMessage;
  final DateTime timestamp;
  final bool showTail;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String? senderName;
  final bool isStarred;
  final bool isPinned;
  final MessageType type;
  final String? imagePath;
  final Map<String, String>? repliedMessage;
  final String? documentName;

  // PENAMBAHAN PARAMETER BARU UNTUK HIGHLIGHT
  final String? highlightText;

  const ChatBubble({
    super.key,
    this.text,
    this.isSender = false,
    this.isSystemMessage = false,
    required this.timestamp,
    required this.showTail,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.highlightText,
    this.senderName,
    this.repliedMessage,
    required this.isStarred,
    required this.isPinned,
    required this.type,
    this.imagePath,
    this.documentName,
  });

  Widget _buildReplyPreview() {
    if (repliedMessage == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black.withOpacity(0.05),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                color:
                    isSender
                        ? Colors.white70
                        : ThemeColor.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repliedMessage!['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSender ? Colors.white : ThemeColor.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    repliedMessage!['text'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSender ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText() {
    // Jika tidak ada kata kunci pencarian, tampilkan Text biasa.
    if (highlightText == null || highlightText!.isEmpty) {
      return Text(
        text ?? '',
        style: TextStyle(color: isSender ? Colors.white : Colors.black),
      );
    }

    final regex = RegExp(highlightText!, caseSensitive: false);
    final matches = regex.allMatches(text ?? '');

    if (matches.isEmpty) {
      return Text(
        text ?? '',
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
        children: _generateSpans(text ?? '', matches),
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
    // Widget helper untuk membuat ekor gelembung (tidak berubah)
    Widget buildTail(bool isSender) {
      return Positioned(
        bottom: 0,
        right: isSender ? -6 : null,
        left: isSender ? null : -6,
        child: Icon(
          isSender ? Icons.arrow_right : Icons.arrow_left,
          size: 20,
          color: isSender ? ThemeColor.primary : Colors.white,
        ),
      );
    }

    // Widget helper untuk ikon status (tidak berubah)
    Widget _buildStatusIcon() {
      if (isPinned) {
        return Transform.rotate(
          angle: 0.5, // Sedikit dimiringkan
          child: Icon(
            Icons.push_pin,
            size: 16,
            color: isSender ? Colors.white70 : Colors.black54,
          ),
        );
      }
      if (isStarred) {
        return Icon(
          Icons.star,
          size: 16,
          color: isSender ? Colors.white70 : Colors.black54,
        );
      }
      return const SizedBox.shrink();
    }

    Widget _buildMessageContent() {
      if (type == MessageType.document && documentName != null) {
        // JIKA PESAN DOKUMEN, BUAT TAMPILAN KHUSUS
        return Row(
          mainAxisSize: MainAxisSize.min, // Membuat Row sependek mungkin
          children: [
            // Ikon File
            Icon(
              Icons.insert_drive_file_rounded,
              color: isSender ? Colors.white : Colors.grey.shade700,
              size: 40,
            ),
            const SizedBox(width: 12),
            // Kolom untuk nama file dan info lainnya
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentName!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Anda bisa menambahkan info ukuran file di sini jika ada
                ],
              ),
            ),
          ],
        );
      }
      // 1. CEK APAKAH PESAN INI ADALAH GAMBAR
      if (type == MessageType.image && imagePath != null) {
        // JIKA YA, BUAT WIDGET GAMBAR
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                File(imagePath!),
                // `width` akan membatasi lebar gambar agar tidak terlalu besar
                width:
                    MediaQuery.of(context).size.width *
                    0.9, // Maksimal 60% lebar layar
                fit: BoxFit.cover,
              ),
            ),
            if (text != null)
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  text ?? '',
                  style: TextStyle(
                    color: isSender ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
          ],
        );
      }
      final textWidget = Flexible(child: _buildHighlightedText());
      final statusIconWidget = _buildStatusIcon();
      const spacer = SizedBox(width: 8);

      if (isSender) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [statusIconWidget, spacer, textWidget],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [textWidget, spacer, statusIconWidget],
        );
      }
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color:
            isSelected
                ? ThemeColor.primary.withOpacity(0.3)
                : Colors.transparent,
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
                    Container(
                      padding:
                          type == MessageType.image
                              ? EdgeInsets.all(3)
                              : const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSystemMessage
                                ? Colors.yellow.shade200
                                : (isSender
                                    ? ThemeColor.primary
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jika pesan adalah teks, tampilkan nama dan reply di dalam.
                          // Jika gambar, nama dan reply bisa ditampilkan di atasnya (opsional).
                          if (type == MessageType.text) ...[
                            if (senderName != null && !isSender)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  senderName!,
                                  style: const TextStyle(
                                    color: Colors.pinkAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            _buildReplyPreview(),
                            if (repliedMessage != null)
                              const SizedBox(height: 8),
                          ],

                          // PANGGIL METHOD PENGATUR KONTEN DI SINI
                          _buildMessageContent(),
                        ],
                      ),
                    ),
                    if (showTail && !isSystemMessage) buildTail(isSender),
                  ],
                ),
              ),
            ),
            // Bagian Timestamp
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
