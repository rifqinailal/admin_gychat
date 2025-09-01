import 'package:admin_gychat/shared/theme/colors.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; 
import 'package:admin_gychat/modules/chat_list/chat_list_view.dart';
import 'package:admin_gychat/modules/setting/setting_screen.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of pages to be displayed.
    final List<Widget> bodyContent = [
      const ChatListView(listType: ChatListType.all),
      const ChatListView(listType: ChatListType.unread),
      const ChatListView(listType: ChatListType.group),
      const SettingScreen(),
    ];

    // Lebar layar perangkat.
    final screenWidth = MediaQuery.of(context).size.width;

    // Ukuran ikon sebagai persentase dari lebar layar.
    // Menggunakan 10% dari lebar layar.
    // .clamp() digunakan untuk memberi batas ukuran minimum dan maksimum.
    final double iconSize = (screenWidth * 0.10).clamp(30.0, 35.0);

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: bodyContent, 
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: ThemeColor.lightGrey3,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          unselectedItemColor: ThemeColor.darkGrey1,
          selectedItemColor: ThemeColor.primary,
          selectedFontSize: 16.0,
          unselectedFontSize: 16.0,
          items: [
            _buildNavItem(
              activeIconPath: 'assets/icons/Subtract.svg',
              iconPath: 'assets/icons/Chat_alt_2_light.svg',
              label: 'Chats',
              size: iconSize,
            ),
            _buildNavItem(
              activeIconPath: 'assets/icons/Subtract2.svg',
              iconPath: 'assets/icons/Chat_alt_3_light.svg',
              label: 'Unread',
              size: iconSize,
            ),
            _buildNavItem(
              activeIconPath: 'assets/icons/Group_fill.svg',
              iconPath: 'assets/icons/Group_light.svg',
              label: 'Group',
              size: iconSize,
            ),
            _buildNavItem(
              activeIconPath: 'assets/icons/Setting_fill.svg',
              iconPath: 'assets/icons/Setting_line_light.svg',
              label: 'Setting',
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to create a [BottomNavigationBarItem] with responsive icons.
  /// This helps to avoid code repetition (DRY Principle).
  BottomNavigationBarItem _buildNavItem({
    required String iconPath,
    required String activeIconPath,
    required String label,
    required double size,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        activeIconPath,
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(
          ThemeColor.primary,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }
}
