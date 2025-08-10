// // controllers/away_message_controller.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../models/away_message_model.dart';
// import '../routes/app_routes.dart'; // Sesuaikan dengan path routes Anda

// class AwayMessageController extends GetxController {
//   // --- STATE ---
//   // Membuat instance AwayMessage menjadi reaktif dengan .obs
//   var awayMessage = AwayMessage(
//     startTime: DateTime.now(),
//     endTime: DateTime.now().add(const Duration(hours: 8)),
//   ).obs;

//   // Controller untuk text field di halaman edit pesan
//   late TextEditingController messageController;

//   // --- LIFECYCLE ---
//   @override
//   void onInit() {
//     super.onInit();
//     messageController = TextEditingController(text: awayMessage.value.message);
//   }

//   @override
//   void onClose() {
//     messageController.dispose();
//     super.onClose();
//   }

//   // --- GETTERS (Untuk memformat tampilan di UI) ---
//   String get formattedStartTime => DateFormat('MM/dd/yy, h:mm a').format(awayMessage.value.startTime!);
//   String get formattedEndTime => DateFormat('MM/dd/yy, h:mm a').format(awayMessage.value.endTime!);

//   // --- ACTIONS ---
//   // Mengaktifkan atau menonaktifkan away message
//   void toggleEnabled(bool value) {
//     awayMessage.update((val) {
//       val!.isEnabled = value;
//     });
//   }

//   // Mengubah tipe jadwal (Always Send / Custom)
//   void setScheduleType(ScheduleType type) {
//     awayMessage.update((val) {
//       val!.scheduleType = type;
//     });
//   }

//   // Menavigasi ke halaman edit pesan
//   void navigateToEditMessage() {
//     messageController.text = awayMessage.value.message; // Pastikan text field update
//     Get.toNamed(AppRoutes.EditAwayMessage);
//   }

//   // Menyimpan pesan yang telah diubah
//   void saveMessage() {
//     if (messageController.text.isNotEmpty) {
//       awayMessage.update((val) {
//         val!.message = messageController.text;
//       });
//       Get.back(); // Kembali ke halaman sebelumnya
//       Get.snackbar('Saved', 'Away message has been updated.');
//     }
//   }

//   // Logika untuk memilih tanggal dan waktu
//   Future<void> selectDateTime(BuildContext context, {required bool isStartTime}) async {
//     final initialDate = isStartTime ? awayMessage.value.startTime! : awayMessage.value.endTime!;

//     // 1. Tampilkan Date Picker
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );

//     if (pickedDate == null) return; // User menekan cancel

//     // 2. Tampilkan Time Picker (menggunakan bottom sheet dengan Cupertino style)
//     DateTime tempTime = initialDate;
//     Get.bottomSheet(
//       Container(
//         height: 300,
//         color: Colors.white,
//         child: Column(
//           children: [
//             Expanded(
//               child: CupertinoDatePicker(
//                 mode: CupertinoDatePickerMode.time,
//                 initialDateTime: initialDate,
//                 onDateTimeChanged: (DateTime newTime) {
//                   tempTime = newTime;
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: CupertinoButton.filled(
//                   child: const Text('Set'),
//                   onPressed: () {
//                     // Gabungkan tanggal dari date picker dan waktu dari time picker
//                     final finalDateTime = DateTime(
//                       pickedDate.year,
//                       pickedDate.month,
//                       pickedDate.day,
//                       tempTime.hour,
//                       tempTime.minute,
//                     );

//                     // Update state
//                     awayMessage.update((val) {
//                       if (isStartTime) {
//                         val!.startTime = finalDateTime;
//                       } else {
//                         val!.endTime = finalDateTime;
//                       }
//                     });
//                     Get.back(); // Tutup bottom sheet
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }