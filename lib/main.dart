import 'package:admin_gychat/routes/app_pages.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
//import 'package:admin_gychat/services/chat_service.dart.txt';
//import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  //await Get.putAsync(() async => ChatService());

 // sembunyikan navbar & status bar
  //SystemChrome.setEnabledSystemUIMode(
    //SystemUiMode.immersiveSticky, 
  //);

  
  final box = GetStorage();
  final bool isLoggedIn = box.read('isLoggedIn') ?? false;
  
  runApp( 
    GetMaterialApp(
      title: "Admin Chat",
      initialRoute: isLoggedIn ? AppRoutes.Dashboard : AppRoutes.Auth,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}