// lib/app/modules/dashboard/dashboard_screen.dart
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          index: controller.tabIndex.value,

          children: bodyContent,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 240, 240, 240),
          // selectedItemColor: ThemeColor.primary,
          // unselectedItemColor: const Color(0xFF646164),
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/Chat_alt_2_light.svg',
                width: 50,
                height: 50,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/Subtract.svg',
                width: 40,
                height: 40,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  ThemeColor.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/Chat_alt_3_light.svg',
                width: 50,
                height: 50,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/Subtract2.svg',
                width: 40,
                height: 40,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  ThemeColor.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Unread',
            ),
             BottomNavigationBarItem(
              activeIcon: SvgPicture.asset(
                'assets/icons/Group_fill.svg',
                width: 50,
                height: 50,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  ThemeColor.primary, 
                  BlendMode.srcIn,
                ),
              ),
              icon: SvgPicture.asset(
                'assets/icons/Group_light.svg',
                width: 50,
                height: 50,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Group',
            ),
             BottomNavigationBarItem(
              activeIcon: SvgPicture.asset(
                'assets/icons/Setting_fill.svg',
                width: 45,
                height: 45,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  ThemeColor.primary,
                  BlendMode.srcIn,
                ),
              ),
              icon: SvgPicture.asset(
                'assets/icons/Setting_line_light.svg',
                width: 45,
                height: 45,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
