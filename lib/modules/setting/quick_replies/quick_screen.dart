// lib/modules/setting/quick_replies/quick_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quick_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart'; 

class QuickScreen extends GetView<QuickController> {
  const QuickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      appBar: AppBar(
        backgroundColor: ThemeColor.lightGrey1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColor.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Quick Replies',
          style: TextStyle(
            color: ThemeColor.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: ThemeColor.black, size: 30),
            onPressed: () => controller.goToAddScreen(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Obx(() {
            if (controller.quickReplies.isEmpty) { 
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 230.0), // Beri jarak dari atas
                  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flash_on, size: 60, color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Quick Reply',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Press the '+' button to add.",
                        style: TextStyle(
                          fontFamily: 'Poppins', 
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else { 
              return Container( 
                decoration: BoxDecoration(
                  color: ThemeColor.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColor.black.withOpacity(0.03),
                      spreadRadius: 2,
                      blurRadius: 20,
                      offset: const Offset(0,5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: controller.quickReplies.length, 
                    separatorBuilder: (context, index) => const Divider(
                      color: ThemeColor.mediumGrey5,
                      height: 1,
                      thickness: 0.5,
                      // Indent divider tetap, dimulai setelah kotak nomor
                      indent: 0,
                    ),
                    itemBuilder: (context, index) {
                    final reply = controller.quickReplies[index];
                    final bool hasImage =
                    reply.imageFile != null || reply.imagePath != null;
                    
                    return InkWell(
                      onTap: () => controller.goToEditScreen(reply),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Kotak Nomor(Shortcut)
                            Container(
                              width: 45,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ThemeColor.lightGrey1,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                reply.shortcut,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: ThemeColor.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Gambar (Attach Media)
                            if (hasImage)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                // Ukuran gambar
                                width: 60, 
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeColor.lightGrey1.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: reply.imageFile != null
                                  ? Image.file(reply.imageFile!,
                                  fit: BoxFit.cover)
                                  : Image.asset(reply.imagePath!,
                                  fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            
                            // Message
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  reply.message,
                                  maxLines: 2, // Batasi 2 baris
                                  overflow: TextOverflow.ellipsis, // Tampilkan '...' jika lebih
                                  style: const TextStyle(
                                    color: ThemeColor.black,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              );
            }
          }),
        ),
      ),
    );
  }
}