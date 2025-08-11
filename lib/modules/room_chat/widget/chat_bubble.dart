import 'package:admin_gychat/shared/theme/colors.dart';
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
  final String? senderName;
  final bool isStarred;
  final bool isPinned;
  final Map<String, String>? repliedMessage;

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
    this.senderName,
    this.repliedMessage,
    required this.isStarred,
    required this.isPinned,
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
                        :  ThemeColor.primary.withOpacity(0.7),
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
    // Widget helper untuk membuat ekor gelembung (tidak berubah)
    Widget buildTail(bool isSender) {
      return Positioned(
        bottom: 0,
        right: isSender ? -6 : null,
        left: isSender ? null : -6,
        child: Icon(
          isSender ? Icons.arrow_right : Icons.arrow_left,
          size: 20,
          color: isSender ?  ThemeColor.primary : Colors.white,
        ),
      );
    }

    // WIDGET HELPER untuk ikon status (Bintang/Pin)
    // Warnanya diubah menjadi hitam sesuai permintaan.
    Widget _buildStatusIcon() {
      if (isPinned) {
        return Transform.rotate(
          angle: 1,
       child:  Icon(
          Icons.push_pin,
          size: 16,
          color: isSender ? Colors.white70 : Colors.black54,
        ));
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
            // Bagian gelembung chat (Stack)
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSystemMessage
                                ? Colors.yellow.shade200
                                : (isSender
                                    ?  ThemeColor.primary
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
                          if (repliedMessage != null) const SizedBox(height: 8),

                          Builder(
                            builder: (context) {
                              // Siapkan dulu widget-widgetnya
                              final textWidget = Flexible(
                                child: _buildHighlightedText(),
                              );
                              final statusIconWidget = _buildStatusIcon();
                              const spacer = SizedBox(width: 8);

                              // Tentukan urutannya berdasarkan `isSender`
                              if (isSender) {
                                // Jika PENGIRIM: [IKON] [JARAK] [TEKS]
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    statusIconWidget,
                                    spacer,
                                    textWidget,
                                  ],
                                );
                              } else {
                                // Jika PENERIMA: [TEKS] [JARAK] [IKON]
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    textWidget,
                                    spacer,
                                    statusIconWidget,
                                  ],
                                );
                              }
                            },
                          ),
                          // ===============================================
                        ],
                      ),
                    ),
                    if (showTail && !isSystemMessage) buildTail(isSender),
                  ],
                ),
              ),
            ),

            // Bagian Timestamp (kembali ke luar seperti semula)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
              child: Text(
                DateFormat('HH:mm').format(timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
