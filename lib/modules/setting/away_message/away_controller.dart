// lib/app/modules/setting/away_message/away_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'away_screen.dart';

enum ScheduleOption { always, custom }

class AwayController extends GetxController {
  final isAwayEnabled = false.obs;
  final scheduleOption = ScheduleOption.custom.obs;
  final message = 'Thank You'.obs;
  final startTime = Rx<DateTime?>(null);
  final endTime = Rx<DateTime?>(null);

  late TextEditingController messageEditController; 
  // Untuk melacak picker mana yang sedang aktif: 'start', 'end', atau null (tidak ada)
  final Rx<String?> activePicker = Rx<String?>(null);

  // Untuk menyimpan tanggal/waktu yang sedang dipilih di picker sebelum disimpan
  final Rx<DateTime> tempSelectedDate = DateTime.now().obs;

  // Untuk toggle antara tampilan kalender dan tampilan jam
  final isCalendarView = true.obs;

  @override
  void onInit() {
    super.onInit();
    messageEditController = TextEditingController(text: message.value);
  }

  @override
  void onClose() {
    messageEditController.dispose();
    super.onClose();
  }
  
  /// Toggles the away message setting.
  void toggleAway(bool value) {
    isAwayEnabled.value = value;
  }


  // Dipanggil saat ListTile 'Start Time' atau 'End Time' ditekan
  void openPicker(String pickerType) { 
    if (activePicker.value == pickerType) {
      activePicker.value = null;
      return;
    }

    activePicker.value = pickerType;
    isCalendarView.value = true;

    // Set tanggal awal di picker
    if (pickerType == 'start') {
      tempSelectedDate.value = startTime.value ?? DateTime.now();
    } else if (pickerType == 'end') {
      tempSelectedDate.value = endTime.value ?? startTime.value ?? DateTime.now();
    }
  }

  // Menyimpan tanggal/waktu dari picker ke state utama (startTime atau endTime)
  void savePickedDate() {
    final now = DateTime.now();

    if (activePicker.value == 'start') {
      if (tempSelectedDate.value.isBefore(now.subtract(const Duration(minutes: 1)))) {
        Get.snackbar(
          'Invalid Time',
          'Start time cannot be in the past.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // Hentikan proses simpan
      }

      startTime.value = tempSelectedDate.value;

      if (endTime.value != null && startTime.value!.isAfter(endTime.value!)) {
        endTime.value = null;
      }

    } else if (activePicker.value == 'end') {
      if (startTime.value == null) {
        Get.snackbar(
          'Invalid Order',
          'Please set the start time first.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (!tempSelectedDate.value.isAfter(startTime.value!)) {
        Get.snackbar(
          'Invalid Time',
          'End time must be after the start time.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      endTime.value = tempSelectedDate.value;
    }

    activePicker.value = null;
  }

  void selectScheduleOption(ScheduleOption option) { 
    scheduleOption.value = option;
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) {
      return 'Select time';
    }
    return DateFormat('dd/MM/yy, HH:mm').format(dt);
  }

  void showMessageEditPopup() {
    messageEditController.text = message.value;
    Get.to(
      () => const EditMessageScreen(),
      transition: Transition.downToUp,
    );
  }
}