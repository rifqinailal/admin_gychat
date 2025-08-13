// lib/app/data/models/chat_model.dart

class ChatModel {
  final int id;
  final String name;
  final bool isGroup;
  final int unreadCount;
  bool isArchived; 

  ChatModel({
    required this.id,
    required this.name,
    this.isGroup = false,
    this.unreadCount = 0,
    this.isArchived = false, 
  });
}