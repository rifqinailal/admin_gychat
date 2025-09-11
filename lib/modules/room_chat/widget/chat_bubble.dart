// lib/modules/room_chat/widget/chat_bubble.dart
import 'dart:io';

import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  final int? documentSize;
  final bool isDeleted;
  final String? highlightText;
  final int messageId;
  final double? maxWidth;
  final double? minWidth;

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
    this.documentSize,
    required this.isDeleted,
    required this.messageId,
    this.maxWidth,
    this.minWidth,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool isExpanded = false;

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Widget _buildStatusIcons() {
    final color = widget.isSender ? Colors.white70 : Colors.black54;
    return GetBuilder<RoomChatController>(
      id: 'status_${widget.messageId}',
      builder: (controller) {
        final isCurrentlyPinned =
            controller.pinnedMessage.value?.messageId == widget.messageId;
        if (!widget.isStarred && !isCurrentlyPinned) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentlyPinned) ...[
              Icon(Icons.push_pin, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            if (widget.isStarred) Icon(Icons.star, size: 14, color: color),
          ],
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    if (widget.repliedMessage == null || widget.isDeleted)
      return const SizedBox.shrink();

    final replyBackgroundColor =
        widget.isSender ? const Color(0xFF1A2C79) : const Color(0xFFEAE8FF);
    final replyTitleColor =
        widget.isSender ? ThemeColor.white : ThemeColor.primary;
    final replyTextColor = widget.isSender ? Colors.white70 : Colors.black54;
    final replyBarColor =
        widget.isSender ? Colors.white70 : ThemeColor.primary.withOpacity(0.7);

    return GestureDetector(
      onTap: () {
        final controller = Get.find<RoomChatController>();
        final replyMessageId = widget.repliedMessage!['messageId'];
        if (replyMessageId != null) {
          controller.jumpToReplyMessage(replyMessageId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: replyBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 4, color: replyBarColor),
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
                          color: replyTitleColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.repliedMessage!['text'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: replyTextColor,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText() {
    final textContent = widget.text ?? '';
    final shouldShowButton = _shouldShowExpandButton();
    final effectiveText = (shouldShowButton && !isExpanded)
        ? '${textContent.substring(0, 200)}...'
        : textContent;
    final textStyle = TextStyle(
        color: widget.isSender ? ThemeColor.white : ThemeColor.black,
        fontSize: 15);

    if (widget.highlightText == null || widget.highlightText!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(effectiveText, style: textStyle),
          if (shouldShowButton)
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isExpanded ? 'Sembunyikan' : 'Baca selengkapnya...',
                  style: TextStyle(
                    color: widget.isSender
                        ? ThemeColor.grey5
                        : ThemeColor.primary,
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
    final matches = regex.allMatches(textContent);
    if (matches.isEmpty) {
      return Text(textContent, style: textStyle);
    }
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: _generateSpans(textContent, matches),
      ),
    );
  }

  bool _shouldShowExpandButton() {
    final textContent = widget.text ?? '';
    return textContent.length > 200;
  }

  List<TextSpan> _generateSpans(String text, Iterable<RegExpMatch> matches) {
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: ThemeColor.primary.withOpacity(0.7),
            color: ThemeColor.black,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return spans;
  }

  /// [PERBAIKAN UTAMA DI SINI]
  /// Membangun konten utama (teks, gambar, dokumen) di dalam bubble.
  Widget _buildPrimaryContent() {
    // Pesan yang dihapus
    if (widget.isDeleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: ThemeColor.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Pesan ini telah dihapus',
              style: TextStyle(
                  color: ThemeColor.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    // Pesan Gambar
    if (widget.type == MessageType.image && widget.imagePath != null) {
      // Gunakan Column untuk menampung gambar dan teks (jika ada)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () =>
                Get.find<RoomChatController>().showImageFullScreen(widget.imagePath!),
            child: Image.file(
              File(widget.imagePath!),
              fit: BoxFit.cover,
            ),
          ),
          // Tambahkan teks di bawah gambar jika ada
          if (widget.text != null && widget.text!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: _buildHighlightedText(),
            ),
        ],
      );
    }

    // Pesan Dokumen
    if (widget.type == MessageType.document && widget.documentName != null) {
      // Gunakan Column untuk menampung info dokumen dan teks (jika ada)
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isSender
                  ? Colors.white.withOpacity(0.15)
                  : const Color(0xFFEAE8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  color:
                      widget.isSender ? ThemeColor.white : ThemeColor.primary,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.documentName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: widget.isSender
                                ? Colors.white
                                : ThemeColor.black,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatFileSize(widget.documentSize),
                        style: TextStyle(
                            fontSize: 12,
                            color: widget.isSender
                                ? Colors.white70
                                : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tambahkan teks di bawah info dokumen jika ada
          if (widget.text != null && widget.text!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: _buildHighlightedText(),
            ),
        ],
      );
    }
    
    // Pesan Teks (default)
    return _buildHighlightedText();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.type == MessageType.system) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: ThemeColor.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            widget.text ?? '',
            style: const TextStyle(color: ThemeColor.white, fontSize: 13),
          ),
        ),
      );
    }

    Widget buildTail() {
      return Positioned(
        bottom: 0,
        right: widget.isSender ? -6 : null,
        left: widget.isSender ? null : -6,
        child: Icon(
          widget.isSender ? Icons.arrow_right : Icons.arrow_left,
          size: 20,
          color: widget.isDeleted
              ? ThemeColor.primary.withOpacity(0.7)
              : (widget.isSender ? ThemeColor.primary : ThemeColor.white),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.isDeleted ? null : widget.onLongPress,
      child: Container(
        color: widget.isSelected
            ? ThemeColor.primary.withOpacity(0.3)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Align(
          alignment:
              widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                widget.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: widget.maxWidth ??
                          MediaQuery.of(context).size.width * 0.75,
                      minWidth: widget.minWidth ?? 0.0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: widget.isDeleted
                          ? ThemeColor.primary.withOpacity(0.7)
                          : (widget.isSender
                              ? ThemeColor.primary
                              : ThemeColor.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(
                            widget.showTail && !widget.isSender ? 0 : 16),
                        bottomRight: Radius.circular(
                            widget.showTail && widget.isSender ? 0 : 16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: (widget.type == MessageType.image)
                              ? EdgeInsets.zero
                              : const EdgeInsets.fromLTRB(10, 8, 10, 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.senderName != null &&
                                  !widget.isSender &&
                                  !widget.isDeleted)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    widget.senderName!,
                                    style: const TextStyle(
                                      color: Colors.pinkAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              if (widget.repliedMessage != null &&
                                  !widget.isDeleted)
                                _buildReplyPreview(),
                              _buildPrimaryContent(),
                            ],
                          ),
                        ),
                        if (!widget.isDeleted)
                          Positioned(
                            bottom: 5,
                            right: 8,
                            child: _buildStatusIcons(),
                          ),
                      ],
                    ),
                  ),
                  if (widget.showTail && !widget.isSystemMessage) buildTail(),
                ],
              ),
              if (!widget.isDeleted)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 6, left: 6),
                  child: Text(
                    DateFormat('HH:mm').format(widget.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}