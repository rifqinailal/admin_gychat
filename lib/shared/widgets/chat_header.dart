import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_controller.dart';
import 'package:admin_gychat/modules/star/detail_star_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:admin_gychat/shared/widgets/delete_confirmation_dialog.dart';
import 'package:admin_gychat/shared/widgets/pin_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MainMenuAction { groupBaru, berbintang, pengaturan }

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  // Method ini SEKARANG HANYA membuat baris judul "Gychat" dan menu titik tiga.
  Widget _buildTitleBar() {
    return Row(
      key: const ValueKey('normalHeader'), // Key untuk animasi
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Gychat',
          style: TextStyle(
            color: ThemeColor.primary,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        PopupMenuButton<MainMenuAction>(
          // Mengatur warna latar belakang dari menu popup yang muncul.
          color: Colors.white,

          // Mengatur ikon yang menjadi tombolnya (ikon titik tiga).
          icon: const Icon(Icons.more_vert, color: ThemeColor.primary),

          // Mengatur bentuk dari menu popup agar memiliki sudut melengkung.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // Fungsi yang dijalankan saat salah satu item menu dipilih.
          onSelected: (MainMenuAction action) {
            final dashboardController = Get.find<DashboardController>();
            // Menggunakan switch untuk menentukan aksi berdasarkan pilihan user.
            switch (action) {
              case MainMenuAction.groupBaru:
                print('User memilih Group Baru');
                break;
              case MainMenuAction.berbintang:
                Get.toNamed(AppRoutes.DetailStar);
                break;
              case MainMenuAction.pengaturan:
                dashboardController.changeTabIndex(3);
                break;
            }
          },

          // Fungsi yang membangun (membuat) daftar item di dalam menu.
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<MainMenuAction>>[
                // ITEM MENU 1: Group Baru
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

                // ITEM MENU 2: Berbintang
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

                // ITEM MENU 3: Pengaturan
                PopupMenuItem<MainMenuAction>(
                  value: MainMenuAction.pengaturan,
                  child: Row(
                    children: const [
                      Icon(Icons.settings_outlined, color: Colors.black54),
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

  // Method ini HANYA membuat baris aksi untuk mode seleksi.
  Widget _buildSelectionBar(ChatListController controller) {
    return Row(
      key: const ValueKey('selectionHeader'), // Key untuk animasi
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
              onPressed: () {},
              icon: const Icon(
                Icons.archive_outlined,
                color: Color(0xFF353435),
              ),
            ),
            IconButton(
              onPressed: () {
                if (controller.selectedChats.length >= 5)
                  Get.dialog(
                    PinConfirmationDialog(
                      chatCount: controller.selectedChats.length,
                    ),
                  );
              },
              icon: Transform.rotate(
                angle: 1, // dalam radian,
                child: Icon(Icons.push_pin_outlined, color: Color(0xFF353435)),
              ),
            ),
            IconButton(
              onPressed: () {
                Get.dialog(
                  DeleteConfirmationDialog(
                    chatCount: controller.selectedChats.length,
                    onConfirm: () => controller.deleteSelectedChats(),
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFF353435)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil instance controller yang sudah ada di memori.
    final controller = Get.find<ChatListController>();

    // Widget Column sekarang menjadi pembungkus UTAMA untuk SEMUA elemen header.
    return Column(
      children: [
        // Bagian atas yang dinamis (bisa berubah)
        SizedBox(height: 40),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Here',
              hintStyle: TextStyle(color: ThemeColor.gray),
              prefixIcon: Icon(Icons.search_rounded, color: ThemeColor.gray),
              filled: true,
              fillColor: Color.fromRGBO(240, 240, 240, 1),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 36,
          ), // Disesuaikan paddingnya
          child: InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.DetailArsip);
            },
              child: Row(
                children: [
                  const Icon(Icons.archive_outlined, color: ThemeColor.gray),
                  const SizedBox(width: 12),
                  const Text(
                    'Diarsipkan',
                    style: TextStyle(color: ThemeColor.gray, fontSize: 16),
                  ),
                  const Spacer(),
                  const Text(
                    '13',
                    style: TextStyle(color: ThemeColor.gray, fontSize: 16),
                  ),
                ],
              ),
            
          ),
        ),
      ],
    );
  }
}
