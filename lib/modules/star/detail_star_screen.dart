// lib/modules/star/detail_star_screen.dart
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_star_controller.dart';

class DetailStarScreen extends GetView<DetailStarsController> {
  const DetailStarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sekarang dibangun berdasarkan state dari controller
      appBar: _buildAppBar(), // _buildAppBar() already returns Obx, which wraps an AppBar
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

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: controller.filteredMessages.length,
            itemBuilder: (context, index) {
              final message = controller.filteredMessages[index];
              return _buildMessageItem(message, context);
            },
          );
        }),
      ),
    );
  }

  /// AppBar Switcher
  /// Memilih AppBar yang akan ditampilkan berdasarkan state
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      // Menentukan tinggi standar AppBar
      preferredSize: const Size.fromHeight(kToolbarHeight), 
      child: Obx(() {
        if (controller.isSearchActive.value) {
          return _buildSearchAppBar();
        } else if (controller.isSelectionMode.value) {
          return _buildSelectionAppBar();
        } else {
          return _buildDefaultAppBar();
        }
      }),
    );
  }

  /// AppBar untuk tampilan default (tidak sedang search atau selection)
  AppBar _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColor.darkGrey2),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Berbintang',
        style: TextStyle(color: ThemeColor.darkGrey2, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: ThemeColor.darkGrey2),
          onPressed: () => controller.toggleSearch(),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: ThemeColor.darkGrey2),
          onPressed: () => controller.confirmDeleteAll(),
        ),
      ],
    );
  }

  /// AppBar untuk tampilan ketika mode pencarian aktif
  /// AppBar untuk tampilan ketika mode pencarian aktif
  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      
      // TAMBAHKAN BARIS INI
      // Menambahkan spasi 16 pixel di kiri dan kanan search bar
      titleSpacing: 16.0, 

      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
              onPressed: () => controller.toggleSearch(),
            ),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AppBar untuk tampilan ketika mode seleksi pesan aktif
  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () => controller.exitSelectionMode(),
      ),
      title: Obx(() => Text(
        '${controller.selectedMessages.length} dipilih',
        style: const TextStyle(color: Colors.black, fontSize: 18),
      )),
      actions: [
        IconButton(
          // Mengganti ikon menjadi hapus, lebih sesuai dengan fungsinya
          icon: const Icon(Icons.delete_outline, color: Colors.black),
          onPressed: () => controller.confirmDeleteSelected(),
        ),
      ],
    );
  }
  
  // Kode _buildMessageItem tidak diubah, tetap sama
  Widget _buildMessageItem(DetailStar message, BuildContext context) {
    // ... (kode Anda yang sudah ada di sini)
     return GestureDetector(
      onTap: () => controller.handleMessageTap(message),
      onLongPress: () => controller.handleMessageLongPress(message),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color:
              message.isSelected.value
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  message.avatarUrl ?? 'assets/images/default_avatar.png',
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  const Icon(Icons.person, color: Colors.white);
                },
                backgroundColor: const Color.fromARGB(255, 192, 186, 186),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          message.sender ?? 'No Sender',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            '▸',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            message.context ?? 'No Context',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message.date ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.66,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text ?? 'No message text',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Spacer(),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  message.time ?? '',
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
            ],
          ),
        ),
      ),
    );
  }
}