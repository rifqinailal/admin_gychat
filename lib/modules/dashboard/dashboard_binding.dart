// lib/app/modules/dashboard/dashboard_binding.dart
import 'package:admin_gychat/modules/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';
import '../chat_list/chat_list_controller.dart';
import '../setting/setting_controller.dart';


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController()); 
    Get.lazyPut<ChatListController>(() => ChatListController()); 
    Get.lazyPut<SettingController>(() => SettingController());
  }
}