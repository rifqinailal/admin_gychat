// lib/app/modules/room_chat/widgets/message_input_bar.dart
import 'dart:io';

import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import '../room_chat_controller.dart';

class MessageInputBar extends GetView<RoomChatController> {
  const MessageInputBar({super.key});

  // Method-method build dipindahkan ke sini dari Screen
  Widget _buildEditPreview() {
    return Obx(() {
      final message = controller.editingMessage.value;
      if (message == null) {
        return const SizedBox.shrink();
      }

      // Tentukan widget pratinjau berdasarkan tipe pesan
      Widget previewContent;
      if (message.type == MessageType.image && message.imagePath != null) {
        // Jika gambar, tampilkan gambar kecil (thumbnail)
        previewContent = Row(
          children: [
            const Text(
              'Edit Pesan untuk',
              style: TextStyle(
                color: ThemeColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(message.imagePath!),
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      } else {
        // Jika teks, tampilkan teksnya (logika lama)
        previewContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Pesan',
              style: TextStyle(
                color: ThemeColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              message.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        );
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        color: Colors.white,
        child: Row(
          children: [
            const Icon(Icons.edit, color: ThemeColor.primary),
            const SizedBox(width: 8),
            Expanded(
              child: previewContent,
            ), // Tampilkan konten pratinjau di sini
            IconButton(
              onPressed: () => controller.cancelEdit(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildReplyPreview() {
    return Obx(() {
      // Jika tidak ada pesan yang di-reply, tampilkan widget kosong.
      if (controller.replyMessage.value == null) {
        return const SizedBox.shrink();
      }

      final message = controller.replyMessage.value!;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        color: Colors.white,
        child: Row(
          children: [
            // Baris vertikal
            Container(width: 4, height: 40, color: const Color(0xFF1D2C86)),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: const TextStyle(
                     color: ThemeColor.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message.text ?? 'Gambar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => controller.cancelReply(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
    });
  }
 Widget _buildQuickReplyList() {
    return Obx(() {
      if (!controller.showQuickReplies.value) {
        return const SizedBox.shrink();
      }
      final bool isEmpty = controller.filteredQuickReplies.isEmpty;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isEmpty ? 100 : 250,

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick replies',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.QuickReplies);
                    },

                    child: Obx(
                      () => Text(
                        controller.quickController.quickReplies.isEmpty
                            ? 'Setting'
                            : 'Edit',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.filteredQuickReplies.length,
                itemBuilder: (context, index) {
                  final reply = controller.filteredQuickReplies[index];
                  return ListTile(
                    leading: Text(
                      '/${reply.shortcut}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(reply.message),
                    onTap: () => controller.selectQuickReply(reply),
                  );
                },

                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16, // Jarak garis dari kiri
                    endIndent: 16, // Jarak garis dari kanan
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
 Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller.showAttachmentOptions(),
            icon: const Icon(
              Icons.insert_drive_file_outlined,
              color: ThemeColor.primary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'write down the answer',
                hintStyle: TextStyle(color: ThemeColor.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                   color: ThemeColor.primary,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                   color: ThemeColor.primary,
                    width: 2,
                  ),
                ),
                // Tombol di belakang teks
                suffixIcon: IconButton(
                  onPressed: () => controller.takePicture(),
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                   color: ThemeColor.primary,
                  ),
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: controller.sendMessage,
            icon: Transform.rotate(
              angle: 0.8,
              child: Icon(FontAwesome5Solid.location_arrow, color: ThemeColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEditPreview(),
        _buildReplyPreview(),
        _buildQuickReplyList(),
        _buildMessageInputBar(),
      ],
    );
  }
}