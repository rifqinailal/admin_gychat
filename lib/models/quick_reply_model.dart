// lib/models/quick_reply_model.dart
import 'dart:io';

class QuickReply {
  final String id;
  String shortcut;
  String message;
  String? imagePath;
  File? imageFile;

  QuickReply({
    required this.id,
    required this.shortcut,
    required this.message,
    this.imagePath,
    this.imageFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortcut': shortcut,
      'message': message,
      'imagePath': imagePath,
      'imageFilePath': imageFile?.path,
    };
  }

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'],
      shortcut: json['shortcut'],
      message: json['message'],
      imagePath: json['imagePath'],
      imageFile: json['imageFilePath'] != null ? File(json['imageFilePath']) : null,
    );
  }
}