// lib/app/data/models/message_model.dart

enum MessageType { text, image, document }

class MessageModel {
  final String senderId;
  final String? text;
  final DateTime timestamp;
  final String senderName;
  final Map<String, String>? repliedMessage;
  final bool isStarred;
  final bool isPinned;
  final MessageType type;
  final String? imagePath;
  final bool isSender;
  final String? documentPath;
  final String? documentName;

  MessageModel({
    required this.senderId,
    // 1. UBAH `required this.text` MENJADI `this.text`
    this.text,
    required this.timestamp,
    required this.isSender,
    required this.senderName,
    this.repliedMessage,
    this.imagePath,
    this.documentPath,
    this.documentName,
    required this.type,
    this.isStarred = false,
    this.isPinned = false,
  }) : assert(
         (type == MessageType.text && text != null && text.isNotEmpty) ||
             (type == MessageType.image && imagePath != null) ||
             (type == MessageType.document &&
                 documentPath != null &&
                 documentName != null),
         'Setiap tipe pesan harus memiliki data yang sesuai.',
       );

  MessageModel copyWith({bool? isStarred, bool? isPinned}) {
    return MessageModel(
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      isSender: isSender,
      senderName: senderName,
      repliedMessage: repliedMessage,
      imagePath: imagePath,
      type: type,
      documentPath: documentPath, 
      documentName: documentName, 
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
