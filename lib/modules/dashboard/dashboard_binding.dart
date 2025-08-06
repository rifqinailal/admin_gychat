// lib/app/modules/dashboard/dashboard_binding.dart
import 'package:admin_gychat/modules/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';
import '../chat_list/chat_list_controller.dart'; // <-- IMPORT


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Daftarkan juga ChatListController di sini agar bisa diakses oleh ChatListView
    Get.lazyPut<ChatListController>(() => ChatListController());
  }
}