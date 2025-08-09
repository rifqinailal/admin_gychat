// lib/app/routes/app_pages.dart
import 'package:admin_gychat/modules/auth/auth_binding.dart';
import 'package:admin_gychat/modules/auth/auth_screen.dart';
import 'package:admin_gychat/modules/auth/forgot_password/forgot_password_binding.dart';
import 'package:admin_gychat/modules/auth/forgot_password/forgot_password_screen.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_binding.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_screen.dart';
import 'package:admin_gychat/modules/star/detail_star_binding.dart';
import 'package:admin_gychat/modules/star/detail_star_screen.dart';
import 'package:admin_gychat/modules/arsip/detail_arsip_binding.dart';
import 'package:admin_gychat/modules/arsip/detail_arsip_screen.dart';
import 'package:admin_gychat/modules/setting/profile/profile_binding.dart';
import 'package:admin_gychat/modules/setting/profile/profile_screen.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_binding.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    // Auth
    GetPage(
      name: AppRoutes.Auth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    // Forgot Password
    GetPage(
      name: AppRoutes.ForgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    // Dashboard
    GetPage(
      name: AppRoutes.Dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    // Detail Star
    GetPage(
      name: AppRoutes.DetailStar,
      page: () => const DetailStarScreen(),
      binding: DetailStarBinding(),
    ),
    // Detail Arsip
    GetPage(
      name: AppRoutes.DetailArsip,
      page: () => const DetailArsipScreen(),
      binding: DetailArsipBinding(),
    ),
    // Profile
    GetPage(
      name: AppRoutes.Profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    // Quick Replies
    GetPage(
      name: AppRoutes.QuickReplies,
      page: () => const QuickScreen(),
      binding: QuickBinding(),
    ),
  ];
}