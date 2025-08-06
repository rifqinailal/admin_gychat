// lib/app/modules/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat_list/chat_list_view.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> bodyContent = [
      const ChatListView(listType: ChatListType.all),
      const ChatListView(listType: ChatListType.unread),
      const ChatListView(listType: ChatListType.group),
      const Center(child: Text('Halaman Pengaturan')),
    ];

    return Scaffold(
      // ==========================================================
      // BAGIAN YANG HILANG & DIPERBAIKI ADA DI BAWAH INI
      // ==========================================================

      body: Obx(
        () => IndexedStack(
          // index akan menentukan widget mana dari `children` yang ditampilkan
          index: controller.tabIndex.value,
          // `children` diisi dengan list widget yang sudah kita siapkan
          children: bodyContent,
        ),
      ),

      // ==========================================================
      // Bagian bottomNavigationBar Anda sudah benar.
      // ==========================================================
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_chat_unread),
              label: 'Unread',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Group',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}