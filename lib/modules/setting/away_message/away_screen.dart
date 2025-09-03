// lib/app/modules/setting/away_message/away_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:admin_gychat/routes/app_routes.dart';
//import 'package:get/get_connect/http/src/utils/utils.dart';
import 'edit_message_screen.dart'; 
import 'away_controller.dart';

class AwayScreen extends GetView<AwayController> {
  const AwayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      appBar: AppBar(
        backgroundColor: ThemeColor.lightGrey1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ThemeColor.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Away Message',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ThemeColor.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
        child: Column(
          children: [
            _buildCard([_buildToggleSwitch()]),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.isAwayEnabled.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card untuk Schedule
                    _buildCard([_buildScheduleTile()]),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 8.0),
                      child: Text(
                        'Message',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: ThemeColor.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildMessageCard(),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: ThemeColor.white, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleSwitch() {
    return ListTile(
      title: const Text(
        'Send Away Message',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
      trailing: Obx(
        () => CupertinoSwitch(
          value: controller.isAwayEnabled.value,
          onChanged: (value) => controller.toggleAway(value),
          activeColor: ThemeColor.primary,
        ),
      ),
    );
  }

  Widget _buildScheduleTile() {
    return ListTile(
      title: const Text(
        'Schedule',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Text(
              controller.scheduleOption.value == ScheduleOption.always
                  ? 'Always Send'
                  : 'Custom Schedule',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      onTap: () => Get.toNamed(AppRoutes.Schedule),
    );
  }

  Widget _buildMessageCard() {
    return GestureDetector(
      // Mengubah onTap untuk menampilkan bottom sheet
      onTap: () {
        Get.bottomSheet(
          const EditMessageScreen(), // Panggil screen baru kita
          // Styling agar sudutnya melengkung
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          isScrollControlled: true, // Agar tidak tertutup keyboard
        );
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
        decoration: BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Obx(
                  () => Text(
                    controller.message.value,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: ThemeColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
