// lib/modules/grup/detail_grup/grup_media_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

class GrupMediaScreen extends GetView<DetailGrupController> {
  const GrupMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0, // Mencegah perubahan warna saat scroll
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        // Menggunakan Obx untuk membangun title agar reaktif
        title: Obx(() {
          return CupertinoSlidingSegmentedControl<int>(
            groupValue: controller.selectedMediaTabIndex.value,
            // [UBAH DI SINI] Warna background container menjadi abu-abu
            backgroundColor: Colors.grey.shade200, 
            // [UBAH DI SINI] Warna item yang aktif menjadi putih
            thumbColor: Colors.white,
            onValueChanged: (int? newValue) {
              if (newValue != null) {
                controller.changeMediaTab(newValue);
              }
            },
            children: {
              // Menggunakan widget Builder untuk text agar lebih rapi
              0: _buildSegment("Media"),
              1: _buildSegment("Links"),
              2: _buildSegment("Docs"),
            },
          );
        }),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement select functionality
            },
            child: const Text(
              'Select',
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Tampilkan konten berdasarkan tab yang dipilih
        switch (controller.selectedMediaTabIndex.value) {
          case 0:
            return _buildEmptyState('No Media');
          case 1:
            return _buildEmptyState('No Links');
          case 2:
            return _buildDocsList();
          default:
            return const Center(child: Text('Select a tab'));
        }
      }),
    );
  }

  // [BARU] Helper widget untuk membuat segmen agar kode lebih bersih
  Widget _buildSegment(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // Widget untuk membangun daftar dokumen
  Widget _buildDocsList() {
    return Obx(() {
      if (controller.docsList.isEmpty) {
        return _buildEmptyState('No Documents');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.docsList.length,
        itemBuilder: (context, index) {
          final doc = controller.docsList[index];
          final isPdf = doc['type'] == 'pdf';
          return _buildDocListItem(
            icon: isPdf ? Icons.picture_as_pdf : Icons.description,
            iconColor: isPdf ? Colors.red.shade600 : Colors.blue.shade600,
            title: doc['name'],
          );
        },
      );
    });
  }

  // Widget untuk setiap item dalam daftar dokumen
  Widget _buildDocListItem({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
    );
  }
  
  // Widget untuk menampilkan state kosong
  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
      ),
    );
  }
}