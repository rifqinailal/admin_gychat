// lib/features/quick_replies/quick_replies_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quick_controller.dart';

class QuickScreen extends GetView<QuickController> {
  const QuickScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Quick Replies',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 30),
            onPressed: () => controller.goToAddScreen(),
          ),
        ],
      ),
      body: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.quickReplies.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final reply = controller.quickReplies[index];
            // --- MODIFIED WIDGET START ---
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => controller.goToEditScreen(reply),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF3F51B5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        reply.shortcut,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display image if it exists
                          if (reply.imagePath != null || reply.imageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: reply.imageFile != null
                                  ? Image.file(
                                      reply.imageFile!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      reply.imagePath!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          // Spacer between image and message
                          if (reply.imagePath != null || reply.imageFile != null)
                            const SizedBox(height: 12),
                          // The message text
                          Text(
                            reply.message,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}