import 'package:admin_gychat/modules/auth/auth_binding.dart';
import 'package:admin_gychat/modules/auth/auth_screen.dart';
import 'package:admin_gychat/modules/auth/forgot_password/forgot_password_binding.dart';
import 'package:admin_gychat/modules/auth/forgot_password/forgot_password_screen.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_binding.dart';
import 'package:admin_gychat/modules/dashboard/dashboard_screen.dart';
//import 'package:admin_gychat/modules/setting/setting_binding.dart.txt';
import 'package:admin_gychat/modules/setting/setting_screen.dart';
import 'package:admin_gychat/modules/grup/detail_grup/detail_grup_binding.dart';
import 'package:admin_gychat/modules/grup/detail_grup/detail_grup_screen.dart';
import 'package:admin_gychat/modules/grup/grup_baru/grup_baru_binding.dart';
import 'package:admin_gychat/modules/grup/grup_baru/grup_baru_screen.dart';
import 'package:admin_gychat/modules/star/detail_star_binding.dart';
import 'package:admin_gychat/modules/star/detail_star_screen.dart';
import 'package:admin_gychat/modules/arsip/detail_arsip_binding.dart';
import 'package:admin_gychat/modules/arsip/detail_arsip_screen.dart';
//import 'package:admin_gychat/modules/setting/profile/profile_binding.dart.txt';
import 'package:admin_gychat/modules/setting/profile/profile_screen.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_binding.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_screen.dart';
import 'package:admin_gychat/modules/setting/quick_replies/edit_quick_reply_screen.dart';
import 'package:admin_gychat/modules/setting/away_message/away_binding.dart';
import 'package:admin_gychat/modules/setting/away_message/away_screen.dart';
import 'package:admin_gychat/modules/setting/away_message/schedule_screen.dart';
import 'package:admin_gychat/modules/setting/away_message/edit_message_screen.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_binding.dart';
import 'package:admin_gychat/modules/room_chat/room_chat_screen.dart';
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
    // Grup Baru
    GetPage(
      name: AppRoutes.GrupBaru,
      page: () => const GrupBaruScreen(),
      binding: GrupBaruBinding(),
    ),
    // Detail Grup
    GetPage(
      name: AppRoutes.DetailGrup,
      page: () => const DetailGrupScreen(),
      binding: DetailGrupBinding(),
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
      page: () =>  DetailArsipScreen(),
      binding: DetailArsipBinding(),
    ),
    // Profile
    GetPage(
      name: AppRoutes.Profile,
      page: () => const ProfileScreen(),
      //binding: ProfileBinding(),
    ),
    // Quick Replies
    GetPage(
      name: AppRoutes.QuickReplies,
      page: () => const QuickScreen(),
      binding: QuickBinding(),
    ),
    // Edit Quick Reply
    GetPage(
      name: AppRoutes.EditQuickReply,
      page: () => const EditQuickReplyScreen(),
      binding: QuickBinding(),
    ),
    // Away Message
    GetPage(
      name: AppRoutes.AwayMessage,
      page: () => const AwayScreen(),
      binding: AwayBinding(),
    ),
    // Schedule
    GetPage(
      name: AppRoutes.Schedule,
      page: () => const ScheduleScreen(),
    ),
    // Edit Message
    GetPage(
      name: AppRoutes.EditMessage,
      page: () => const EditMessageScreen(),
    ),
    // Room Chat
    GetPage(
      name: AppRoutes.ROOM_CHAT, 
      page: () => const RoomChatScreen(),
      binding: RoomChatBinding(),
    ),
    // Setting
    GetPage(
      name:AppRoutes.Setting,
      page: () => SettingScreen(),
      //binding: SettingBinding()
    )
  ];
}