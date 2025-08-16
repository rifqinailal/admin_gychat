// lib/app/modules/dashboard/dashboard_screen.dart
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import '../chat_list/chat_list_view.dart';
import '../setting/setting_screen.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> bodyContent = [
      const ChatListView(listType: ChatListType.all),
      const ChatListView(listType: ChatListType.unread),
      const ChatListView(listType: ChatListType.group),
      const SettingScreen(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          // index akan menentukan widget mana dari `children` yang ditampilkan
          index: controller.tabIndex.value,

          // `children` diisi dengan list widget yang sudah kita siapkan
          children: bodyContent,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          selectedItemColor: ThemeColor.primary,
          unselectedItemColor: const Color(0xFF646164),
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.message_text_outline, size: 32,),
              activeIcon: Icon(MaterialIcons.chat, size: 32),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.ios_chatbox_ellipses_outline, size: 32),
              activeIcon:Icon(Ionicons.ios_chatbox_ellipses_sharp, size: 32),
              label: 'Unread',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(MaterialCommunityIcons.account_group, size: 32),
              icon: Icon(MaterialCommunityIcons.account_group_outline, size: 32),
               label: 'Group'),
            BottomNavigationBarItem(
              activeIcon: Icon(Ionicons.ios_settings_sharp, size: 32),
              icon: Icon(Ionicons.ios_settings_outline, size: 32),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
