// lib/app/modules/setting/away_message/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'away_controller.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AwayController controller = Get.find<AwayController>();

    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      appBar: AppBar(
        backgroundColor: ThemeColor.lightGrey1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ThemeColor.black),
          onPressed: () {
            // Pastikan picker tertutup saat kembali
            controller.activePicker.value = null;
            Get.back();
          },
        ),
        title: const Text(
          'Away Message',
          style: TextStyle(fontFamily: 'Poppins', color: ThemeColor.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Obx(
          () => Column(
            children: [
              // --- Card Pilihan Jadwal ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: ThemeColor.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    _buildScheduleOptionTile(controller, 'Always Send', 'Send automated message at all times.', ScheduleOption.always),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildScheduleOptionTile(controller, 'Custom Schedule', 'Only send automated message during the specified times.', ScheduleOption.custom),
                  ],
                ),
              ),

              // --- Card Pemilih Waktu (Start & End Time) ---
              if (controller.scheduleOption.value == ScheduleOption.custom) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      // --- Start Time ---
                      _buildTimePickerTile(controller, 'Start Time', controller.startTime),
                      // Tampilkan picker kustom jika 'start' aktif
                      if (controller.activePicker.value == 'start')
                        _buildCustomPicker(controller),
                      
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // --- End Time ---
                      _buildTimePickerTile(controller, 'End Time', controller.endTime),
                      // Tampilkan picker kustom jika 'end' aktif
                      if (controller.activePicker.value == 'end')
                        _buildCustomPicker(controller),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleOptionTile(AwayController controller, String title, String subtitle, ScheduleOption value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600])),
      trailing: controller.scheduleOption.value == value
          ? const Icon(Icons.check, color:  ThemeColor.primary)
          : null,
      onTap: () => controller.selectScheduleOption(value),
    );
  }

  Widget _buildTimePickerTile(AwayController controller, String label, Rx<DateTime?> timeValue) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        controller.formatDateTime(timeValue.value),
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
      ),
      // Mengubah cara kerja onTap
      onTap: () => controller.openPicker(label == 'Start Time' ? 'start' : 'end'),
    );
  }

  Widget _buildCustomPicker(AwayController controller) { 
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Tombol untuk switch antara Tampilan Tanggal dan Waktu
          _buildDateTimeSelector(controller),
          const SizedBox(height: 12),
          // Tampilan Kalender atau Jam
          Obx(() => controller.isCalendarView.value
              ? _buildCalendarView(controller)
              : _buildTimeScrollerView(controller)),
          const SizedBox(height: 8),
          // Tombol Save
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.savePickedDate(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Poppins', color: ThemeColor.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector(AwayController controller) {
    return Obx(() => Row(
      children: [
        // Tombol Tanggal
        Expanded(
          child: InkWell(
            onTap: () => controller.isCalendarView.value = true,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: controller.isCalendarView.value ? ThemeColor.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  DateFormat('d MMM yyyy').format(controller.tempSelectedDate.value),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: controller.isCalendarView.value ? ThemeColor.primary : Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tombol Waktu
        Expanded(
          child: InkWell(
            onTap: () => controller.isCalendarView.value = false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !controller.isCalendarView.value ? ThemeColor.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  DateFormat('HH:mm').format(controller.tempSelectedDate.value),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: !controller.isCalendarView.value ? ThemeColor.primary : Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildCalendarView(AwayController controller) {
    // Tentukan tanggal pertama yang bisa dipilih berdasarkan picker yang aktif
    DateTime firstAvailableDay;
    // Tentukan hari apa saja yang bisa di-tap
    bool enabledDayPredicate(DateTime day) {
        // Normalisasi tanggal agar perbandingan tidak terpengaruh oleh jam/menit
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (controller.activePicker.value == 'start') {
            // Untuk start time, tidak boleh memilih hari sebelum hari ini
            return !day.isBefore(todayDate);
        } else if (controller.activePicker.value == 'end') {
            // Untuk end time, tidak boleh memilih hari sebelum start time
            if (controller.startTime.value == null) return true; // Jika start time belum ada, semua boleh dipilih
            final startDate = controller.startTime.value!;
            final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
            return !day.isBefore(startDateOnly);
        }
        return true;
    }

    if (controller.activePicker.value == 'end' && controller.startTime.value != null) {
      firstAvailableDay = controller.startTime.value!;
    } else {
      firstAvailableDay = DateTime.now();
    }


    return Obx(() => TableCalendar(
      focusedDay: controller.tempSelectedDate.value,
      // Atur tanggal paling awal yang bisa ditampilkan di kalender
      firstDay: firstAvailableDay.subtract(const Duration(days: 1)),
      lastDay: DateTime.utc(2040, 12, 31),
      // Gunakan predicate untuk menonaktifkan hari yang tidak valid
      enabledDayPredicate: enabledDayPredicate,

      selectedDayPredicate: (day) => isSameDay(controller.tempSelectedDate.value, day),
      onDaySelected: (selectedDay, focusedDay) {
        // Update hanya tanggal, pertahankan waktu yang sudah ada
        final current = controller.tempSelectedDate.value;
        controller.tempSelectedDate.value = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          current.hour,
          current.minute,
        );
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
      ),
      calendarStyle: CalendarStyle(
        // Gaya untuk hari yang tidak bisa dipilih
        disabledTextStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400),
        selectedDecoration: const BoxDecoration(
          color:  ThemeColor.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: ThemeColor.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
    ));
  }
  
  Widget _buildTimeScrollerView(AwayController controller) {
    final currentTime = controller.tempSelectedDate.value;
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scroller Jam
          _timeWheel(
            itemCount: 24,
            initialItem: currentTime.hour,
            onSelectedItemChanged: (hour) {
              final current = controller.tempSelectedDate.value;
              controller.tempSelectedDate.value = DateTime(current.year, current.month, current.day, hour, current.minute);
            }
          ),
          const Text(":", style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold)),
          
          _timeWheel(
            itemCount: 60,
            initialItem: currentTime.minute,
            isMinute: true,
            onSelectedItemChanged: (minute) {
              final current = controller.tempSelectedDate.value;
              controller.tempSelectedDate.value = DateTime(current.year, current.month, current.day, current.hour, minute);
            }
          ),
        ],
      ),
    );
  }

  Widget _timeWheel({
    required int itemCount,
    required int initialItem,
    required ValueChanged<int> onSelectedItemChanged,
    bool isMinute = false,
  }) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return Center(
              child: Text(
                isMinute ? index.toString().padLeft(2, '0') : index.toString(),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 20),
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}