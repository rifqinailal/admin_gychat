// lib/app/modules/dashboard/dashboard_binding.dart
import 'package:admin_gychat/modules/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/setting/profile/profile_controller.dart';
import 'package:admin_gychat/modules/setting/setting_controller.dart';


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController()); 
    Get.lazyPut<ChatListController>(() => ChatListController(), fenix: true); 
    Get.lazyPut<SettingController>(() => SettingController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}