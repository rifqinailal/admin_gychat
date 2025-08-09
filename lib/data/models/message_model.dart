// lib/app/data/models/message_model.dart

class MessageModel {
  final String senderId; // ID unik pengirim
  final String text;
  final DateTime timestamp;

  // Kita tambahkan ini untuk mempermudah di UI,
  // untuk menentukan apakah gelembung chat ada di kanan atau kiri.
  final bool isSender; 

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isSender,
  });
}