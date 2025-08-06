// lib/app/modules/chat_list/chat_list_controller.dart

import 'package:get/get.dart';
// Jangan lupa import model Anda nanti
// import 'package:chatapp_admin/app/data/models/chat_model.dart';

// Untuk sementara, kita buat model dummy di sini
class ChatModel {
  final String name;
  final bool isGroup;
  final int unreadCount;
  ChatModel({required this.name, this.isGroup = false, this.unreadCount = 0});
}


class ChatListController extends GetxController {
  // Ini adalah "Single Source of Truth" atau sumber data utama untuk semua chat.
  // Semua perubahan (data baru, chat dibaca) hanya terjadi pada list ini.
  var allChats = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Nanti, di sini Anda akan memanggil repository untuk mengambil data dari API.
    // Untuk sekarang, kita isi dengan data dummy.
    fetchChats();
  }

  // --- GETTERS UNTUK FILTERING ---
  // GetX akan secara otomatis memperbarui UI yang menggunakan getter ini
  // setiap kali `allChats` berubah.

  /// Mengembalikan list chat yang belum dibaca.
  List<ChatModel> get unreadChats => allChats.where((chat) => chat.unreadCount > 0).toList();

  /// Mengembalikan list chat grup.
  List<ChatModel> get groupChats => allChats.where((chat) => chat.isGroup).toList();


  void fetchChats() {
    // Simulasi pengambilan data dari API
    var dummyData = [
      ChatModel(name: 'Jeremy Owen', unreadCount: 2),
      ChatModel(name: 'Olympiad Bus', isGroup: true, unreadCount: 5),
      ChatModel(name: 'Classtell', unreadCount: 0),
      ChatModel(name: 'Olympiad Mace', isGroup: true, unreadCount: 0),
      ChatModel(name: 'Dian Puspita', unreadCount: 1),
      ChatModel(name: 'Projek Internal', isGroup: true, unreadCount: 1),
    ];
    allChats.assignAll(dummyData);
  }
}