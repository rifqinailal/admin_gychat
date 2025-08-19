// lib/models/message_model.dart

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
  final bool isDeleted;

  MessageModel({
    required this.senderId, 
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
    this.isDeleted = false,
  }) : assert(
         (type == MessageType.text && text != null && text.isNotEmpty) ||
             (type == MessageType.image && imagePath != null) ||
             (type == MessageType.document &&
                 documentPath != null &&
                 documentName != null),
         'Setiap tipe pesan harus memiliki data yang sesuai.',
       );

  MessageModel copyWith({String? text,bool? isStarred, bool? isPinned,bool? isDeleted, }) {
    return MessageModel(
      senderId: senderId,
      text: text ?? this.text, 
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
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
