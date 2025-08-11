// lib/app/data/models/message_model.dart

class MessageModel {
  final String senderId; // ID unik pengirim
  final String text;
  final DateTime timestamp;
  final String senderName; // Nama pengirim untuk ditampilkan di grup
  final Map<String, String>? repliedMessage; // Pesan yang dibalas (opsional)
  final bool isStarred;
  final bool isPinned;

  // Kita tambahkan ini untuk mempermudah di UI,
  // untuk menentukan apakah gelembung chat ada di kanan atau kiri.
  final bool isSender;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isSender,
    required this.senderName,
    this.repliedMessage, // Opsional, jadi tidak perlu `required`
    this.isStarred = false,
    this.isPinned = false,
  });

  MessageModel copyWith({
    bool? isStarred,
    bool? isPinned,
  }) {
    return MessageModel(
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      isSender: isSender,
      senderName: senderName,
      repliedMessage: repliedMessage,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
