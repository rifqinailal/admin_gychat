import 'package:admin_gychat/routes/app_pages.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  runApp(
    GetMaterialApp(
      title: "Admin Chat",
      initialRoute: AppRoutes.Dashboard,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}