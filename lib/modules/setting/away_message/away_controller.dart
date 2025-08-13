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
  
  // --- METHOD BARU UNTUK CUSTOM PICKER ---

  // Dipanggil saat ListTile 'Start Time' atau 'End Time' ditekan
  void openPicker(String pickerType) {
    // Jika menekan picker yang sudah aktif, tutup picker tersebut
    if (activePicker.value == pickerType) {
      activePicker.value = null;
      return;
    }

    activePicker.value = pickerType;
    isCalendarView.value = true; // Selalu mulai dengan tampilan kalender

    // Set tanggal awal di picker sesuai dengan nilai yang sudah ada
    if (pickerType == 'start' && startTime.value != null) {
      tempSelectedDate.value = startTime.value!;
    } else if (pickerType == 'end' && endTime.value != null) {
      tempSelectedDate.value = endTime.value!;
    } else {
      tempSelectedDate.value = DateTime.now();
    }
  }

  // Menyimpan tanggal/waktu dari picker ke state utama (startTime atau endTime)
  void savePickedDate() {
    if (activePicker.value == 'start') {
      startTime.value = tempSelectedDate.value;
    } else if (activePicker.value == 'end') {
      endTime.value = tempSelectedDate.value;
    }
    // Tutup picker setelah menyimpan
    activePicker.value = null;
  }

  // Future<void> pickDateTime(...) { ... }
  
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