// lib/app/modules/room_chat/room_chat_controller.dart

import 'package:admin_gychat/data/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import model yang baru kita buat


class RoomChatController extends GetxController {
  // `TextEditingController` adalah cara standar Flutter untuk mengelola
  // input pada sebuah `TextField`.
  late TextEditingController messageController;
   late TextEditingController searchController;

  // Variabel untuk menyimpan semua pesan dalam chat room ini.
  // Kita bungkus dengan .obs agar UI bisa reaktif.
  var messages = <MessageModel>[].obs;
  final String currentUserId = "admin_01";
  var chatRoomInfo = {}.obs;

   // Penanda apakah mode search sedang aktif atau tidak.
  var isSearchMode = false.obs;
  // Menyimpan kata kunci yang sedang dicari.
  var searchQuery = ''.obs;

  List<MessageModel> get filteredMessages {
    // Jika kata kunci pencarian kosong...
    if (searchQuery.isEmpty) {
      // ...maka kembalikan semua pesan.
      return messages;
    } else {
      // ...jika tidak, kembalikan hanya pesan yang teksnya
      // mengandung kata kunci (tidak case-sensitive).
      return messages.where((msg) => 
        msg.text.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller untuk text field.
    messageController = TextEditingController();
    searchController = TextEditingController();
    // Panggil data pesan saat halaman pertama kali dibuka.
    if (Get.arguments != null) {
      chatRoomInfo.value = Get.arguments as Map<String, dynamic>;
    }
    fetchMessages();
  }

  @override
  void onClose() {
    // Penting! Selalu dispose controller untuk mencegah memory leak.
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Fungsi untuk masuk/keluar dari mode search.
  void toggleSearchMode() {
    // Balikkan nilainya (true jadi false, false jadi true).
    isSearchMode.value = !isSearchMode.value;
    // Jika kita keluar dari mode search, pastikan kata kunci dikosongkan.
    if (!isSearchMode.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  // Fungsi untuk memperbarui kata kunci pencarian setiap kali user mengetik.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Fungsi untuk mengambil data pesan (simulasi dari API)
  void fetchMessages() {
    // Kita isi dengan data dummy
    var dummyMessages = [
      MessageModel(senderId: "user_02", text: "Hi, I have a problem with....", timestamp: DateTime.now().subtract(const Duration(minutes: 5)), isSender: false),
      MessageModel(senderId: currentUserId, text: "Okay, what is the problem?", timestamp: DateTime.now().subtract(const Duration(minutes: 4)), isSender: true),
      MessageModel(senderId: "user_02", text: "My account cannot login", timestamp: DateTime.now().subtract(const Duration(minutes: 3)), isSender: false),
      MessageModel(senderId: currentUserId, text: "Let me check it for you.", timestamp: DateTime.now().subtract(const Duration(minutes: 2)), isSender: true),
      MessageModel(senderId: "user_02", text: "My account cannot login", timestamp: DateTime.now().subtract(const Duration(minutes: 3)), isSender: false),      
    ];
    messages.assignAll(dummyMessages);
  }

  // Fungsi untuk mengirim pesan baru
  void sendMessage() {
    // 1. Ambil teks dari inputan. `trim()` untuk menghapus spasi di awal/akhir.
    final text = messageController.text.trim();

    // 2. Jika inputan tidak kosong, lanjutkan.
    if (text.isNotEmpty) {
      // 3. Buat objek pesan baru.
      final newMessage = MessageModel(
        senderId: currentUserId, // Pengirimnya adalah admin
        text: text,
        timestamp: DateTime.now(),
        isSender: true, // Pesan yang dikirim admin selalu `isSender`.
      );

      // 4. Tambahkan pesan baru ke AWAL daftar.
      //    Karena `ListView` kita `reverse: true`, item pertama di list
      //    akan muncul di paling bawah layar.
      messages.insert(0, newMessage);

      // 5. Kosongkan kembali inputan setelah pesan terkirim.
      messageController.clear();
    }
  }
}