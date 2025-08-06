// lib/app/modules/dashboard/dashboard_controller.dart

import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Gunakan .obs agar GetX bisa "mengamati" perubahan pada variabel ini.
  // Nilai awalnya 0, yang berarti tab pertama (Chats) akan aktif saat aplikasi dibuka.
  var tabIndex = 0.obs;

  // Fungsi ini akan dipanggil ketika user menekan item di BottomNavigationBar.
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}