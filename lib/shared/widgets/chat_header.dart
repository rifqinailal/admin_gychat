import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:admin_gychat/shared/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

enum MainMenuAction { groupBaru, berbintang, pengaturan }

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});
  Widget _buildTitleBar() {
    return Row(
      key: const ValueKey('normalHeader'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'GyChat',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ThemeColor.primary,
            fontWeight: FontWeight.w600,
            fontSize: 32,
          ),
        ),
        PopupMenuButton<MainMenuAction>(
          color: Colors.white, 
          icon: const Icon(Icons.more_vert, color: ThemeColor.primary), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), 
          onSelected: (MainMenuAction action) {
            final dashboardController = Get.find<DashboardController>(); 
            switch (action) {
              case MainMenuAction.groupBaru:
                Get.toNamed(AppRoutes.GrupBaru);
                break;
              case MainMenuAction.berbintang:
                Get.toNamed(AppRoutes.GlobalStar);
                break;
              case MainMenuAction.pengaturan:
                dashboardController.changeTabIndex(3);
                break;
            }
          },

          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<MainMenuAction>>[
                PopupMenuItem<MainMenuAction>(
                  value: MainMenuAction.groupBaru,
                  child: Row(
                    children: const [
                      Icon(Icons.group_add_outlined, color: Colors.black54),
                      SizedBox(width: 12),
                      Text('Group Baru'),
                    ],
                  ),
                ),
                PopupMenuItem<MainMenuAction>(
                  value: MainMenuAction.berbintang,
                  child: Row(
                    children: const [
                      Icon(Icons.star_border, color: Colors.black54),
                      SizedBox(width: 12),
                      Text('Berbintang'),
                    ],
                  ),
                ),
                PopupMenuItem<MainMenuAction>(
                  value: MainMenuAction.pengaturan,
                  child: Row(
                    children: const [
                      Icon(
                        Ionicons.ios_settings_outline,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 12),
                      Text('Pengaturan'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildSelectionBar(ChatListController controller) { 
    return Row(
      key: const ValueKey('selectionHeader'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => controller.clearSelection(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF353435)),
        ),
        // Obx(
        //   () => Text(
        //     '${controller.selectedChats.length} dipilih',
        //     style: const TextStyle(
        //       color: ThemeColor.primary,
        //       fontSize: 18,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        Row(
          children: [
            IconButton(
              onPressed: () => controller.archiveSelectedChats(),
              icon: SvgPicture.asset(
                'assets/icons/Arhive_load_duotone_line.svg',
                width: 25,
                height: 25,
                // Atur warna untuk ikon tidak aktif
                colorFilter: const ColorFilter.mode(
                  Color(0xFF353435),
                  BlendMode.srcIn,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                controller.pinSelectedChats();
              },
              icon: Obx(() {
                // <-- 1. Bungkus Stack dengan Obx
                // 2. Cek apakah ada chat yang dipilih DAN chat pertama itu sudah di-pin
                final bool isAlreadyPinned =
                    controller.selectedChats.isNotEmpty &&
                    controller.selectedChats.first.isPinned;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: 1.5,
                      child: const Icon(Octicons.pin, color: Color(0xFF353435)),
                    ),

                    // 3. Tampilkan garis miring HANYA JIKA isAlreadyPinned bernilai true
                    if (isAlreadyPinned)
                      Positioned.fill(
                        child: CustomPaint(painter: SlashPainter()),
                      ),
                  ],
                );
              }),
            ),

            Obx(() {
              if (controller.canDeleteSelectedChats) {
                return IconButton(
                  onPressed: () {
                    Get.dialog(
                      DeleteConfirmationDialog(
                        chatCount: controller.selectedChats.length,
                        onConfirm: () => controller.deleteSelectedChats(),
                      ),
                    );
                  },
                  icon: const Icon(
                    FontAwesome5Regular.trash_alt,
                    color: Color(0xFF353435),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) { 
    final controller = Get.find<ChatListController>();
    return Column( 
      children: [ 
        SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          child: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  controller.isSelectionMode.value
                      ? _buildSelectionBar(controller)
                      : _buildTitleBar(),
            ),
          ),
        ),

        // Bagian bawah yang statis (selalu ada)
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            // Hubungkan controller
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search Here',
              hintStyle: TextStyle(color: Color(0xFF9A9696)),
              // Buat ikon menjadi dinamis
              prefixIcon: Obx(
                () => controller.isSearching.value ? Padding(
                  padding: const EdgeInsets.only(left: 25, right: 8),
                  child: GestureDetector(
                    onTap: () => controller.clearSearch(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                      color: Color(0xFF9A9696),
                    ),
                  ),
                ) : Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 8,
                  ),
                  child: Transform.rotate( 
                    angle: 1.5,
                    child: const Icon(
                      Ionicons.ios_search_outline,
                      size: 22,
                      color: Color(0xFF9A9696),
                    ),
                  ),
                ),
              ), 
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              contentPadding: const EdgeInsets.symmetric(vertical: 10), 
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder( 
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint() ..color = const Color(0xFF353435) ..strokeWidth = 1.9 ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
