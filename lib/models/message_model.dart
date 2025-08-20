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
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(), // Ubah DateTime menjadi String
      'senderName': senderName,
      'repliedMessage': repliedMessage,
      'isStarred': isStarred,
      'isPinned': isPinned,
      'type': type.name, // Ubah enum menjadi String
      'imagePath': imagePath,
      'isSender': isSender,
      'documentPath': documentPath,
      'documentName': documentName,
      'isDeleted': isDeleted,
    };
  }

  // FACTORY CONSTRUCTOR BARU: Membuat object MessageModel dari Map (JSON)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']), // Ubah String menjadi DateTime
      senderName: json['senderName'],
      repliedMessage: json['repliedMessage'] != null
          ? Map<String, String>.from(json['repliedMessage'])
          : null,
      isStarred: json['isStarred'] ?? false,
      isPinned: json['isPinned'] ?? false,
      type: MessageType.values.firstWhere((e) => e.name == json['type']), // Ubah String menjadi enum
      imagePath: json['imagePath'],
      isSender: json['isSender'],
      documentPath: json['documentPath'],
      documentName: json['documentName'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
