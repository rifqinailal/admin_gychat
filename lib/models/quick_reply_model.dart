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
}