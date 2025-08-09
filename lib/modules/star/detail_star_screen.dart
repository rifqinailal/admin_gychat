// lib/modules/starred_messages/starred_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_star_controller.dart';

class DetailStarScreen extends GetView<DetailStarsController> {
  const DetailStarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      // Body utama dengan background gambar
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bgchatadmin.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() {
          if (controller.filteredMessages.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada pesan berbintang',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          // Tampilkan list pesan
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: controller.filteredMessages.length,
            itemBuilder: (context, index) {
              final message = controller.filteredMessages[index];
              return _buildMessageItem(message);
            },
          );
        }),
      ),
    );
  }

  // Widget untuk membangun AppBar yang dinamis
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: Obx(
        () =>
            controller.isSelectionMode.value
                ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => controller.exitSelectionMode(),
                )
                : IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                  onPressed: () => Get.back(),
                ),
      ),
      title: Obx(() {
        if (controller.isSearchActive.value) {
          // AppBar mode pencarian
          return TextField(
            controller: controller.searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search here...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
          );
        }
        if (controller.isSelectionMode.value) {
          // AppBar mode seleksi
          return Text(
            '${controller.selectedMessages.length} dipilih',
            style: const TextStyle(color: Colors.black, fontSize: 18),
          );
        }
        // AppBar default
        return const Text(
          'Berbintang',
          style: TextStyle(color: Colors.black, fontSize: 18),
        );
      }),
      actions: [
        Obx(() {
          if (controller.isSelectionMode.value) {
            // Aksi untuk mode seleksi
            return IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black),
              onPressed: () => controller.confirmDeleteSelected(),
            );
          } else if (controller.isSearchActive.value) {
            // Aksi untuk mode pencarian (tombol clear)
            return IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => controller.toggleSearch(),
            );
          } else {
            // Aksi default
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () => controller.toggleSearch(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  onPressed: () => controller.confirmDeleteAll(),
                ),
              ],
            );
          }
        }),
      ],
    );
  }

  // Widget untuk membangun satu item pesan
  Widget _buildMessageItem(DetailStar message) {
    return GestureDetector(
      onTap: () => controller.handleMessageTap(message),
      onLongPress: () => controller.handleMessageLongPress(message),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Beri warna latar belakang jika pesan dipilih
          color:
              message.isSelected.value
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(
                  message.sender[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              // Bubble chat
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas: Pengirim, Konteks, Tanggal
                      Row(
                        children: [
                          Text(
                            message.sender,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            ' ▸ ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              message.context,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            message.date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Isi pesan
                      Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Waktu pesan di pojok kanan bawah
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            message.time,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
