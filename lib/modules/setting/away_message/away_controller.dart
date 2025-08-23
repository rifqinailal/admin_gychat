// lib/app/modules/setting/away_message/away_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
//import 'edit_message_screen.dart';

enum ScheduleOption { always, custom }

class AwayController extends GetxController {
  // GetStorage
  final box = GetStorage();
  static const String _isAwayEnabledKey = 'isAwayEnabled';
  static const String _scheduleOptionKey = 'scheduleOption';
  static const String _messageKey = 'message';
  static const String _startTimeKey = 'startTime';
  static const String _endTimeKey = 'endTime';

  final isAwayEnabled = false.obs;
  final scheduleOption = ScheduleOption.custom.obs;
  final message = 'Thank You'.obs;
  final startTime = Rx<DateTime?>(null);
  final endTime = Rx<DateTime?>(null);

  //late TextEditingController messageEditController; 
  final Rx<String?> activePicker = Rx<String?>(null);
  final Rx<DateTime> tempSelectedDate = DateTime.now().obs;
  final isCalendarView = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAwaySettings();
    //messageEditController = TextEditingController(text: message.value);
  }

  //@override
  //void onClose() {
    //messageEditController.dispose();
    //super.onClose();
  //}

  void _loadAwaySettings() {
    isAwayEnabled.value = box.read(_isAwayEnabledKey) ?? false;
    message.value = box.read(_messageKey) ?? 'Thank You';

    // Memuat schedule option, defaultnya custom
    final storedOption = box.read<String>(_scheduleOptionKey);
    if (storedOption == ScheduleOption.always.name) {
      scheduleOption.value = ScheduleOption.always;
    } else {
      scheduleOption.value = ScheduleOption.custom;
    }

    // Memuat start time (disimpan sebagai string ISO 8601)
    final storedStartTime = box.read<String>(_startTimeKey);
    if (storedStartTime != null) {
      startTime.value = DateTime.parse(storedStartTime);
    }

    // Memuat end time
    final storedEndTime = box.read<String>(_endTimeKey);
    if (storedEndTime != null) {
      endTime.value = DateTime.parse(storedEndTime);
    }
  }
  
  // Toggles the away message setting.
  void toggleAway(bool value) {
    isAwayEnabled.value = value;
    box.write(_isAwayEnabledKey, value);
  }

  // Selects schedule option and saves it.
  void selectScheduleOption(ScheduleOption option) {
    scheduleOption.value = option;
    box.write(_scheduleOptionKey, option.name);
  }

  // Saves the message and writes to storage.
  bool saveMessage(String newMessage) {
    if (newMessage.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Message cannot be empty.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.Red1.withOpacity(0.6),
        colorText: ThemeColor.white,
      );
      return false;
    }
    message.value = newMessage;
    box.write(_messageKey, newMessage);
    
    Get.back();

    Get.snackbar(
      'Success',
      'Away message has been saved.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: ThemeColor.primary.withOpacity(0.6),
      colorText: ThemeColor.white,
    );
    return true;
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
    String pickerType = activePicker.value ?? '';

    if (activePicker.value == 'start') {
      if (tempSelectedDate.value.isBefore(now.subtract(const Duration(minutes: 1)))) {
        Get.snackbar(
          'Invalid Time',
          'Start time cannot be in the past.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: ThemeColor.Red1.withOpacity(0.6),
          colorText: ThemeColor.white,
        );
        return;
      }

      startTime.value = tempSelectedDate.value;
      box.write(_startTimeKey, startTime.value?.toIso8601String());

      if (endTime.value != null && startTime.value!.isAfter(endTime.value!)) {
        endTime.value = null;
      }

    } else if (activePicker.value == 'end') {
      if (startTime.value == null) {
        Get.snackbar(
          'Invalid Order',
          'Please set the start time first.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: ThemeColor.yelow.withOpacity(0.8),
          colorText: ThemeColor.white,
        );
        return;
      }

      if (!tempSelectedDate.value.isAfter(startTime.value!)) {
        Get.snackbar(
          'Invalid Time',
          'End time must be after the start time.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: ThemeColor.Red1.withOpacity(0.6),
          colorText: ThemeColor.white,
        );
        return;
      }
      endTime.value = tempSelectedDate.value;
      box.write(_endTimeKey, endTime.value?.toIso8601String());
    }

    activePicker.value = null; 

    Get.snackbar(
      'Success',
      '${pickerType == 'start' ? 'Start time' : 'End time'} has been saved successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: ThemeColor.primary.withOpacity(0.6),
      colorText: ThemeColor.white,
    );
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) return 'Select time';
    return DateFormat('dd/MM/yy, HH:mm').format(dt);
  }

  //void showMessageEditPopup() {
    //messageEditController.text = message.value;
    //Get.to(
      //() => const EditMessageScreen(),
      //transition: Transition.downToUp,
    //);
  //}
}