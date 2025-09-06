// lib/modules/star/widget/starred_message_card.dart
import 'dart:io';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:intl/intl.dart' hide TextDirection;

class StarredMessageCard extends StatefulWidget {
  final MessageModel message;

  const StarredMessageCard({super.key, required this.message});

  @override
  State<StarredMessageCard> createState() => _StarredMessageCardState();
}

class _StarredMessageCardState extends State<StarredMessageCard> {
  bool _isExpanded = false;
  bool _isLongText = false;

  final int _maxLinesCollapsed = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkIfTextIsLong();
      }
    });
  }

  void _checkIfTextIsLong() {
    if (widget.message.type != MessageType.text || widget.message.text == null || widget.message.text!.isEmpty) {
      return;
    }

    final textSpan = TextSpan(
      text: widget.message.text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.normal,
        color: ThemeColor.white,
        fontSize: 15,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: _maxLinesCollapsed,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: context.size?.width ?? double.infinity);

    if (textPainter.didExceedMaxLines) {
      setState(() {
        _isLongText = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      child: Container( 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeColor.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.repliedMessage != null) _buildReplyPreview(),

            _buildMessageContent(context),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.star,
                  color: ThemeColor.white,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH.mm').format(widget.message.timestamp),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: ThemeColor.white,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    if (widget.message.repliedMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(13),
        border: Border(
          left: BorderSide(
            color: ThemeColor.primary.withOpacity(0.7),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message.repliedMessage!['name'] ?? 'Anda',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: ThemeColor.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.message.repliedMessage!['text'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
              color: ThemeColor.darkGrey1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (widget.message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(widget.message.imagePath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            if (widget.message.text != null && widget.message.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                child: Text(
                  widget.message.text!,
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.normal, color: ThemeColor.white, fontSize: 14),
                ),
              ),
          ],
        );
      case MessageType.document:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file_outlined, color: ThemeColor.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.message.documentName ?? 'Dokumen',
                style: const TextStyle(
                  color: ThemeColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      case MessageType.text:
      default:
        if (!_isLongText) {
          return Text(
            widget.message.text ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              color: ThemeColor.white,
              fontSize: 15,
            ),
          );
        }
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              color: ThemeColor.white,
              fontSize: 12,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text: _isExpanded
                    ? widget.message.text
                    : '${widget.message.text!.substring(0, _calculateTruncateLength())}... ',
              ),
              TextSpan(
                text: _isExpanded ? ' Sembunyikan' : 'Baca Selengkapnya',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: ThemeColor.white,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
              ),
            ],
          ),
        );
    }
  }

  int _calculateTruncateLength() {
    const charsPerLine = 40;
    return (_maxLinesCollapsed * charsPerLine).clamp(0, widget.message.text!.length);
  }
}