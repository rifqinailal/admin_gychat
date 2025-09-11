// lib/models/message_model.dart

enum MessageType { text, image, document, system }

class MessageModel {
  final int messageId;
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
  final int? documentSize; 
  final bool isDeleted;
  final String chatRoomId;

  MessageModel({
    required this.chatRoomId,
    required this.messageId,
    required this.senderId,
    this.text,
    required this.timestamp,
    required this.isSender,
    required this.senderName,
    this.repliedMessage,
    this.imagePath,
    this.documentPath,
    this.documentName,
    this.documentSize,
    required this.type,
    this.isStarred = false,
    this.isPinned = false,
    this.isDeleted = false,
  }) : assert(
            (type == MessageType.text && text != null && text.isNotEmpty) ||
                (type == MessageType.image && imagePath != null) ||
                (type == MessageType.document &&
                    documentPath != null &&
                    documentName != null) ||
                (type == MessageType.system && text != null),
            'Setiap tipe pesan harus memiliki data yang sesuai.');

  MessageModel copyWith({
    String? text,
    bool? isStarred,
    bool? isPinned,
    bool? isDeleted,
  }) {
    return MessageModel(
      chatRoomId: chatRoomId,
      messageId: messageId,
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
      documentSize: documentSize,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'messageId': messageId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSender': isSender,
      'senderName': senderName,
      'repliedMessage': repliedMessage,
      'isStarred': isStarred,
      'isPinned': isPinned,
      'type': type.name,
      'imagePath': imagePath,
      'documentPath': documentPath,
      'documentName': documentName,
      'documentSize': documentSize,
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      chatRoomId: json['chatRoomId'] ?? 'unknown_room',
      messageId: json['messageId'],
      senderId: json['senderId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      isSender: json['isSender'],
      senderName: json['senderName'],
      repliedMessage: json['repliedMessage'] != null
          ? Map<String, String>.from(json['repliedMessage'])
          : null,
      isStarred: json['isStarred'] ?? false,
      isPinned: json['isPinned'] ?? false,
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      imagePath: json['imagePath'],
      documentPath: json['documentPath'],
      documentName: json['documentName'],
      documentSize: json['documentSize'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}