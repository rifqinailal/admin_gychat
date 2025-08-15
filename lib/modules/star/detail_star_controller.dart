// lib/modules/star/detail_star_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Model untuk pesan berbintang
class DetailStar {
  final int id;
  final String sender;
  final String avatarUrl;
  final String context;
  final String text;
  final String time;
  final String date;
  var isSelected = false.obs;

  DetailStar({
    required this.id,
    required this.sender,
    required this.avatarUrl,
    required this.context,
    required this.text,
    required this.time,
    required this.date,
  });
}

class DetailStarsController extends GetxController {
  
  var DetailStars = <DetailStar>[].obs;
  var filteredMessages = <DetailStar>[].obs;
  
  var isSelectionMode = false.obs;
  var selectedMessages = <DetailStar>[].obs;
  
  var isSearchActive = false.obs;
  final TextEditingController searchController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    
    loadDummyData();
    
    searchController.addListener(() {
      filterMessages(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  void loadDummyData() {

    DetailStars.assignAll([
      DetailStar(id: 1, sender: 'Jeremy', avatarUrl: 'assets/images/pp1.jpg', context: 'Class All', text: 'Lorem Ipsum is simply dummy text', time: '10:15', date: '12/01/26'),
      DetailStar(id: 2, sender: 'Owen', avatarUrl: 'assets/images/pp1.jpg', context: 'Class All', text: 'Lorem Ipsum is simply dummy text', time: '10:16', date: '12/01/26'),
      DetailStar(id: 3, sender: 'Indra', avatarUrl: '-', context: 'Anda', text: 'Lorem Ipsum is simply dummy text', time: '10:18', date: '12/01/26'),
      DetailStar(id: 4, sender: 'Yulian', avatarUrl: 'assets/images/pp2.jpg', context: 'Class Benang Ma...', text: 'Lorem Ipsum is simply dummy text', time: '10:20', date: '12/01/26'),
      DetailStar(id: 5, sender: 'Jeremy', avatarUrl: 'assets/images/pp2.jpg', context: 'Class All', text: 'Pesan panjang untuk tes tampilan multiline. Semoga tampilannya tidak rusak dan tetap rapi.', time: '10:25', date: '12/01/26'),
    ]);
    // Awalnya, filteredMessages sama dengan semua pesan
    filteredMessages.assignAll(DetailStars);
  }

  // Mengaktifkan/menonaktifkan mode pencarian
  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchController.clear();
    }
  }

  // Memfilter pesan berdasarkan query pencarian
  void filterMessages(String query) {
    if (query.isEmpty) {
      filteredMessages.assignAll(DetailStars);
    } else {
      filteredMessages.assignAll(DetailStars.where((message) =>
          message.sender.toLowerCase().contains(query.toLowerCase()) ||
          message.text.toLowerCase().contains(query.toLowerCase())));
    }
  }

  // Meng-handle tap pada pesan
  void handleMessageTap(DetailStar message) {
    if (isSelectionMode.value) {
      toggleMessageSelection(message);
    }
  }

  // Meng-handle long press pada pesan untuk masuk ke mode seleksi
  void handleMessageLongPress(DetailStar message) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
    toggleMessageSelection(message);
  }

  // Memilih atau batal memilih pesan
  void toggleMessageSelection(DetailStar message) {
    message.isSelected.toggle();
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }

    // Jika tidak ada lagi pesan yang dipilih, keluar dari mode seleksi
    if (selectedMessages.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  // Keluar dari mode seleksi dan batalkan semua pilihan
  void exitSelectionMode() {
    isSelectionMode.value = false;
    for (var msg in selectedMessages) {
      msg.isSelected.value = false;
    }
    selectedMessages.clear();
  }

  // Menghapus semua pesan berbintang
  void confirmDeleteAll() {
    if (DetailStars.isEmpty) return;
    _showDeleteDialog(
      title: 'Hapus Semua Bintang?',
      onConfirm: () {
        DetailStars.clear();
        filteredMessages.clear();
        Get.back(); // Tutup dialog
      },
    );
  }

  // Menghapus pesan yang dipilih
  void confirmDeleteSelected() {
    if (selectedMessages.isEmpty) return;
    _showDeleteDialog(
      title: 'Hapus ${selectedMessages.length} Bintang?',
      onConfirm: () {
        DetailStars.removeWhere((msg) => selectedMessages.contains(msg));
        filteredMessages.removeWhere((msg) => selectedMessages.contains(msg));
        exitSelectionMode();
        Get.back(); // Tutup dialog
      },
    );
  }

  // Helper konfirmasi
  void _showDeleteDialog({required String title, required VoidCallback onConfirm}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Tombol Batal
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onConfirm,
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
