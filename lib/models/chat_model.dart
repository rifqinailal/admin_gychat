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
}