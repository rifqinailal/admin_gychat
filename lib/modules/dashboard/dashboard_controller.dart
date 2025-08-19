// lib/app/modules/dashboard/dashboard_controller.dart

import 'package:get/get.dart';

class DashboardController extends GetxController { 
  var tabIndex = 0.obs;
  
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}