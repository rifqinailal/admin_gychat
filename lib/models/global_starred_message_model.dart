//lib/models/global_starred_message_model.dart
import 'package:admin_gychat/models/message_model.dart';
import 'package:get/get.dart';

// Model ini berfungsi sebagai "pembungkus" untuk MessageModel.
// Tujuannya adalah untuk membawa informasi tambahan seperti nama dan ID room chat
// asal pesan tersebut, yang akan kita butuhkan di halaman pesan berbintang global.

class GlobalStarredMessage {
  final MessageModel message;
  final String chatRoomName;
  final String chatRoomId;

  // Status terpilih untuk fitur multi-select di halaman berbintang
  var isSelected = false.obs;

  GlobalStarredMessage({
    required this.message,
    required this.chatRoomName,
    required this.chatRoomId,
  });
}