// lib/models/chat_model.dart
import 'package:admin_gychat/models/message_model.dart';

class ChatModel {
  final int id;
  final String name;
  final bool isGroup;
  final int unreadCount;
  bool isArchived;
  bool isPinned; 
  final List<MessageModel> messages;

  ChatModel({
    required this.id,
    required this.name,
    this.isGroup = false,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isPinned = false, 
    this.messages = const [], 
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isGroup': isGroup,
      'unreadCount': unreadCount,
      'isArchived': isArchived,
      'isPinned': isPinned,
      // Ubah setiap message di list menjadi JSON juga
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  // FACTORY CONSTRUCTOR BARU: Membuat object ChatModel dari Map (JSON)
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      isGroup: json['isGroup'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      isArchived: json['isArchived'] ?? false,
      isPinned: json['isPinned'] ?? false,
      // Ambil list message dari JSON dan ubah kembali menjadi object MessageModel
      messages: (json['messages'] as List)
          .map((messageJson) => MessageModel.fromJson(messageJson))
          .toList(),
    );
  }
}