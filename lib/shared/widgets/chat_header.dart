import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:admin_gychat/shared/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
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
                Get.toNamed(AppRoutes.GrupBaru);
                break;
              case MainMenuAction.berbintang:
                Get.toNamed(AppRoutes.DetailStar);
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
              onPressed: () => controller.archiveSelectedChats(),
              icon: const Icon(
                Ionicons.md_archive_outline,
                size: 30,
                color: Color(0xFF353435),
              ),
            ),
            IconButton(
              onPressed: () {
                controller.pinSelectedChats();
              },
              icon: Transform.rotate(
                angle: 1.5,
                child: Icon(Octicons.pin, color: Color(0xFF353435)),
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
              icon: const Icon(
                FontAwesome5Regular.trash_alt,
                color: Color(0xFF353435),
              ),
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
              hintStyle: TextStyle(color:  Color(0xFF9A9696)),
              // Buat ikon menjadi dinamis
              prefixIcon: Obx(
                () =>
                    controller
                            .isSearching
                            .value // TANYA: Apakah sedang mencari?
                        // JIKA YA: Tampilkan IconButton untuk kembali/batal
                        ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                           color:  Color(0xFF9A9696),
                          ),
                          onPressed: () => controller.clearSearch(),
                        )
                        // JIKA TIDAK: Tampilkan ikon search biasa
                        : Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 1,
                          ), // Ubah sesuai kebutuhan
                          child: Transform.rotate(
                            angle: 1.5,
                            child: const Icon(
                              Icons.search_rounded,
                              color:  Color(0xFF9A9696),
                            ),
                          ),
                        ),
              ),
              // Tambahkan tombol clear di kanan saat mencari

              // KEMBALIKAN fillColor
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              // PASTIKAN borderSide ADALAH none
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              // Hilangkan fokus border juga agar sama
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
