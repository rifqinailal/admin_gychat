// lib/app/routes/app_pages.dart
import 'package:admin_gychat/modules/dashboard/dashboard_binding.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.Dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    // ... GetPage lainnya nanti
  ];
}