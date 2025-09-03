// lib/modules/room_chat/widget/chat_bubble.dart
import 'dart:io';

import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
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
  final bool isDeleted;

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
    required this.isDeleted,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool isExpanded = false;

  Widget _buildReplyPreview() {
     if (widget.repliedMessage == null || widget.isDeleted) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        // Panggil controller untuk jump ke pesan yang direply
        final controller = Get.find<RoomChatController>();
        final replyMessageId = widget.repliedMessage!['messageId'];
        if (replyMessageId != null) {
          controller.jumpToReplyMessage(replyMessageId);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(8),
          color: widget.isSender ? Color(0xFF1A2C79) : Color(0xFFEAE8FF),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  color: widget.isSender
                      ? Colors.white70
                      : ThemeColor.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.repliedMessage!['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: widget.isSender ? ThemeColor.white : ThemeColor.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.repliedMessage!['text'] ?? '',
                        maxLines: 2, // Ubah ke 2 baris untuk pesan panjang
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: widget.isSender ? Colors.white70 : Colors.black54,
                          height: 1.3, // Line height untuk spacing yang lebih baik
                        ),
                      ),
                    ],
                  ),
                ),
                // Tambahkan icon kecil untuk indikasi bisa diklik
                Icon(
                  Icons.keyboard_arrow_up,
                  size: 16,
                  color: widget.isSender ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText() {
    final shouldShowButton = _shouldShowExpandButton();
    
    // Jika tidak ada kata kunci pencarian, tampilkan Text biasa.
    if (widget.highlightText == null || widget.highlightText!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text ?? '',
            maxLines: (shouldShowButton && !isExpanded) ? 7 : null,
            overflow: (shouldShowButton && !isExpanded) ? TextOverflow.ellipsis : TextOverflow.visible,
            style: TextStyle(color: widget.isSender ? ThemeColor.white : ThemeColor.black),
          ),
          if (shouldShowButton)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isExpanded ? 'Sembunyikan' : 'Baca selengkapnya...',
                  style: TextStyle(
                    color: widget.isSender ? Colors.white70 : Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    final regex = RegExp(widget.highlightText!, caseSensitive: false);
    final matches = regex.allMatches(widget.text ?? '');

    if (matches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text ?? '',
            maxLines: (shouldShowButton && !isExpanded) ? 7 : null,
            overflow: (shouldShowButton && !isExpanded) ? TextOverflow.ellipsis : TextOverflow.visible,
            style: TextStyle(color: widget.isSender ? ThemeColor.white : ThemeColor.black),
          ),
          if (shouldShowButton)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isExpanded ? 'Sembunyikan' : 'Baca selengkapnya...',
                  style: TextStyle(
                    color: widget.isSender ? Colors.white70 : Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // `RichText` bisa menampilkan teks dengan berbagai gaya berbeda dalam satu widget.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: (shouldShowButton && !isExpanded) ? 7 : null,
          overflow: (shouldShowButton && !isExpanded) ? TextOverflow.ellipsis : TextOverflow.visible,
          text: TextSpan(
            style: TextStyle(
              color: widget.isSender ? ThemeColor.white : ThemeColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            // `children` diisi oleh list `TextSpan` yang sudah dipecah.
            children: _generateSpans(widget.text ?? '', matches),
          ),
        ),
        if (shouldShowButton)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? 'Sembunyikan' : 'Baca selengkapnya...',
                style: TextStyle(
                  color: widget.isSender ? Colors.white70 : Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Fungsi untuk mengecek apakah perlu menampilkan tombol expand
  bool _shouldShowExpandButton() {
    if (widget.text == null || widget.text!.isEmpty) return false;
    
    // Cara sederhana: hitung berdasarkan jumlah baris dengan split
    final lines = widget.text!.split('\n').length;
    
    // Atau hitung berdasarkan panjang karakter dan perkiraan
    const int avgCharPerLine = 40; // Lebih konservatif
    const int maxLines = 7;
    
    return lines > maxLines || widget.text!.length > (avgCharPerLine * maxLines);
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
          style: TextStyle(
            backgroundColor: Color(0xFF2738A5).withOpacity(0.7), // Warna highlight
            color: ThemeColor.black, // Warna teks di dalam highlight
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
    // 1. Helper untuk membuat ekor gelembung
    Widget buildTail() {
      return Positioned(
        bottom: 0,
        right: widget.isSender ? -6 : null,
        left: widget.isSender ? null : -6,
        child: Icon(
          widget.isSender ? Icons.arrow_right : Icons.arrow_left,
          size: 20,
          color: widget.isSender ? ThemeColor.primary : ThemeColor.white,
        ),
      );
    }

    // 2. Helper untuk membuat baris ikon status (bintang/pin)
    Widget buildStatusRow() {
      if (!widget.isPinned && !widget.isStarred) return const SizedBox.shrink();

      IconData statusIcon = widget.isPinned ? Icons.push_pin : Icons.star;
      Color iconColor = widget.isSender ? Colors.white70 : Colors.black54;

      return Padding(
        padding: const EdgeInsets.only(right: 6, left: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(statusIcon, size: 14, color: iconColor)],
        ),
      );
    }

    Widget buildMessageContent() {
      if (widget.isDeleted) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.block, color: Colors.grey.shade400, size: 16),
            const SizedBox(width: 8),
            Text(
              'You deleted this message',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      }
      if (widget.type == MessageType.document && widget.documentName != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isSender) buildStatusRow(),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColor.lightGrey1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      color: ThemeColor.primary,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.documentName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ThemeColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.isSender) buildStatusRow(),
          ],
        );
      }

      if (widget.type == MessageType.image && widget.imagePath != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.find<RoomChatController>().showImageFullScreen(widget.imagePath!);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(widget.imagePath!),
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.isSender) buildStatusRow(),
                  if (widget.text != null && widget.text!.isNotEmpty) Flexible(
                    child: _buildHighlightedText(),
                  ),
                  if (!widget.isSender) buildStatusRow(),
                ],
              ),
            ),
          ],
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end, 
        children: [
          if (widget.isSender) buildStatusRow(),
          Flexible(
            child: _buildHighlightedText(),
          ),
          if (!widget.isSender) buildStatusRow(),
        ],
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.isDeleted ? null : widget.onLongPress,
      child: Container(
        color:
            widget.isSelected
                ? ThemeColor.primary.withOpacity(0.3)
                : Colors.transparent,
        child: Column(
          crossAxisAlignment:
              widget.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              child: Align(
                alignment:
                    widget.isSystemMessage
                        ? Alignment.center
                        : (widget.isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding:
                          widget.type == MessageType.image
                              ? const EdgeInsets.all(6)
                              : const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.isSystemMessage
                                ? Colors.yellow.shade200
                                : (widget.isSender
                                    ? ThemeColor.primary
                                    : ThemeColor.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(
                            widget.showTail && !widget.isSender ? 0 : 16,
                          ),
                          bottomRight: Radius.circular(
                            widget.showTail && widget.isSender ? 0 : 16,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            widget.isSender
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.start,
                        children: [
                          if (widget.senderName != null && !widget.isSender)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                widget.senderName!,
                                style: const TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          if (widget.repliedMessage != null)
                            Padding(
                              padding:
                                  widget.type == MessageType.text
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: _buildReplyPreview(),
                            ),

                          buildMessageContent(),
                        ],
                      ),
                    ),
                    if (widget.showTail && !widget.isSystemMessage) buildTail(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
              child: Text(
                DateFormat('HH:mm').format(widget.timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}