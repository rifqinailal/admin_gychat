// lib/modules/starred_messages/detail_star_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_star_controller.dart';

class DetailStarScreen extends GetView<DetailStarsController> {
  const DetailStarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

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
          return Text(
            '${controller.selectedMessages.length} dipilih',
            style: const TextStyle(color: Colors.black, fontSize: 18),
          );
        }

        return const Text(
          'Berbintang',
          style: TextStyle(color: Colors.black, fontSize: 18),
        );
      }),
      actions: [
        Obx(() {
          if (controller.isSelectionMode.value) {
            return IconButton(
              icon: const Icon(Icons.star_border, color: Colors.black, size: 22),
              onPressed: () => controller.confirmDeleteSelected(),
            );
          } else if (controller.isSearchActive.value) {
            return IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => controller.toggleSearch(),
            );
          } else {
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

  Widget _buildMessageItem(DetailStar message, BuildContext context) {
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
                // Pastikan path avatarUrl benar atau tangani jika null
                backgroundImage: AssetImage(
                  message.avatarUrl ?? 'assets/images/default_avatar.png',
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  const Icon(Icons.person, color: Colors.white);
                },
                backgroundColor: const Color.fromARGB(255, 192, 186, 186),
              ),
              const SizedBox(width: 12),
              // DITAMBAHKAN: Expanded untuk memberi batasan lebar pada Column di bawah ini.
              // Ini adalah perbaikan utama untuk error layout.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          // Penanganan null untuk keamanan
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
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
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
