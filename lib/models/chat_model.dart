import 'package:admin_gychat/models/message_model.dart';

class ChatModel {
  // Sesuaikan nama properti dengan JSON API
  final int roomId;
  final int roomMemberId;
  final String roomType;
  final String name;
  final String? description;
  final String? urlPhoto;
  final String? lastMessage;
  final DateTime? lastTime;
  final int unreadCount;
  bool isArchived;
  bool isPinned;
  final List<MessageModel> messages; // Tetap kita simpan untuk pencarian lokal

  ChatModel({
    required this.roomId,
    required this.roomMemberId,
    required this.roomType,
    required this.name,
    this.description,
    this.urlPhoto,
    this.lastMessage,
    this.lastTime,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isPinned = false,
    this.messages = const [],
  });
  
  // Method `toJson` untuk menyimpan ke GetStorage
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'room_member_id': roomMemberId,
      'room_type': roomType,
      'name': name,
      'description': description,
      'url_photo': urlPhoto,
      'last_message': lastMessage,
      'last_time': lastTime?.toIso8601String(),
      'unread_count': unreadCount,
      'is_archived': isArchived,
      'is_pinned': isPinned,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
  
  // `factory constructor` untuk membuat objek dari JSON (data dari API/storage)
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      roomId: json['room_id'],
      roomMemberId: json['room_member_id'],
      roomType: json['room_type'],
      name: json['name'],
      description: json['description'],
      urlPhoto: json['url_photo'],
      lastMessage: json['last_message'],
      lastTime: json['last_time'] != null ? DateTime.parse(json['last_time']) : null,
      unreadCount: json['unread_count'] ?? 0,
      isArchived: json['is_archived'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      messages: json['messages'] != null
          ? (json['messages'] as List).map((m) => MessageModel.fromJson(m)).toList()
          : [],
    );
  }
}