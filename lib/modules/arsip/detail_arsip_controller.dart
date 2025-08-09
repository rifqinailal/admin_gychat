// lib/modules/arsip/detail_arsip_controller.dart

import 'package:get/get.dart';

class DetailArsip {
  final String senderName;
  final String messagePreview;
  final String avatarUrl;
  final String timestamp;
  final int unreadCount;
  final bool isTyping;
  final bool isSelected;
  final bool hasMention; // Untuk titik merah

  DetailArsip({
    required this.senderName,
    required this.messagePreview,
    required this.avatarUrl,
    required this.timestamp,
    this.unreadCount = 0,
    this.isTyping = false,
    this.isSelected = false,
    this.hasMention = false,
  });
}

class DetailArsipController extends GetxController {
  // Daftar chat yang diarsipkan, dibuat reaktif dengan .obs
  var detailArsip = <DetailArsip>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Memuat data dummy saat controller diinisialisasi
    loadDummyData();
  }

  // Metode untuk mengisi daftar dengan data yang sesuai dengan screenshot
  void loadDummyData() {
    detailArsip.assignAll([
      DetailArsip(
        senderName: 'ClassAll',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/class_avatar.png',
        timestamp: '10.16',
        unreadCount: 20,
      ),
      DetailArsip(
        senderName: 'ClassAll',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/class_avatar.png',
        timestamp: '10.16',
        unreadCount: 20,
      ),
      DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: '10.16',
        unreadCount: 1,
      ),
      DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: '10.16',
        unreadCount: 1,
        isSelected: false, // Item ini yang di-highlight biru
      ),
      DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'mengetik....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: '10.16',
        isTyping: true,
      ),
      DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'mengetik....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: '10.16',
        isTyping: true,
      ),
      DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: 'yesterday',
      ),
       DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: 'yesterday',
      ),
      DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: 'senin',
        hasMention: false, // Item ini punya titik merah
      ),
       DetailArsip(
        senderName: 'Jeremy Owen',
        messagePreview: 'Hi, i have a problem with....',
        avatarUrl: 'assets/images/jeremy_avatar.png',
        timestamp: '12/06/25',
      ),
    ]);
  }
}