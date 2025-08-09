// views/away_message_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/away_message_controller.dart';
import '../models/away_message_model.dart';

class AwayMessageView extends GetView<AwayMessageController> {
  const AwayMessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Away Message',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildToggleCard(),
            const SizedBox(height: 20),
            // Widget lainnya akan muncul berdasarkan state dari toggle
            Obx(() {
              if (controller.awayMessage.value.isEnabled) {
                return Column(
                  children: [
                    _buildScheduleCard(),
                    const SizedBox(height: 20),
                    _buildMessageCard(),
                  ],
                );
              }
              return Container(); // Tampilkan container kosong jika disabled
            }),
          ],
        ),
      ),
    );
  }

  // Card untuk toggle "Send Away Message"
  Widget _buildToggleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => SwitchListTile.adaptive(
          title: const Text('Send Away Message', style: TextStyle(fontSize: 16)),
          value: controller.awayMessage.value.isEnabled,
          onChanged: controller.toggleEnabled,
          activeColor: Colors.blue,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }

  // Card untuk bagian "Schedule"
  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Schedule', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Obx(
            () => CupertinoSegmentedControl<ScheduleType>(
              children: const {
                ScheduleType.always: Padding(padding: EdgeInsets.all(8), child: Text('Always Send')),
                ScheduleType.custom: Padding(padding: EdgeInsets.all(8), child: Text('Custom Schedule')),
              },
              onValueChanged: (type) => controller.setScheduleType(type),
              groupValue: controller.awayMessage.value.scheduleType,
              padding: EdgeInsets.zero,
            ),
          ),
          // Tampilkan pilihan waktu jika "Custom Schedule" dipilih
          Obx(() {
            if (controller.awayMessage.value.scheduleType == ScheduleType.custom) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  const Divider(),
                  _buildTimeRow(
                    label: 'Start Time',
                    time: controller.formattedStartTime,
                    onTap: () => controller.selectDateTime(Get.context!, isStartTime: true),
                  ),
                  const Divider(),
                  _buildTimeRow(
                    label: 'End Time',
                    time: controller.formattedEndTime,
                    onTap: () => controller.selectDateTime(Get.context!, isStartTime: false),
                  ),
                ],
              );
            }
            return Container();
          }),
        ],
      ),
    );
  }

  // Card untuk bagian "Message"
  Widget _buildMessageCard() {
    return GestureDetector(
      onTap: controller.navigateToEditMessage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Message', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.awayMessage.value.message,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris Start Time dan End Time
  Widget _buildTimeRow({required String label, required String time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(time, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}