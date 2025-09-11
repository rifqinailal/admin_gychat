// lib/models/chat_model.dart
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
  final List<MessageModel> messages;
  final int? pinnedMessageId;
  final bool isMember; 


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
    this.pinnedMessageId,
    this.isMember = true,
  });

  ChatModel copyWith({
    String? lastMessage,
    DateTime? lastTime,
    List<MessageModel>? messages,
    int? pinnedMessageId,
    bool? isMember,
    //bool unpin = false,
    bool clearPinnedMessage = false,
  }) {
    return ChatModel(
      roomId: this.roomId,
      roomMemberId: this.roomMemberId,
      roomType: this.roomType,
      name: this.name,
      description: this.description,
      urlPhoto: this.urlPhoto,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unreadCount: this.unreadCount,
      isArchived: this.isArchived,
      isPinned: this.isPinned,
      messages: messages ?? this.messages,
      //pinnedMessageId: pinnedMessageId ?? this.pinnedMessageId,
      //pinnedMessageId: unpin ? null : (pinnedMessageId ?? this.pinnedMessageId),
      pinnedMessageId: clearPinnedMessage ? null : (pinnedMessageId ?? this.pinnedMessageId),
      isMember: isMember ?? this.isMember,
    );
  }
  
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
      'pinned_message_id': pinnedMessageId,
      'is_member': isMember,
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
      pinnedMessageId: json['pinned_message_id'],
      isMember: json['is_member'] ?? true,
    );
  }
}