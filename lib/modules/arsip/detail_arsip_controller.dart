import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:get/get.dart';


class DetailArsipController extends GetxController {
  
  // 1. Buat sebuah list reaktif untuk menampung chat yang diarsipkan.
  var archivedChats = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 2. Panggil fungsi untuk mengisi list saat controller pertama kali dijalankan.
    fetchArchivedChats();
  }
 
  // 3. Buat fungsi untuk mengisi data (untuk sekarang kita pakai data dummy).
  void fetchArchivedChats() {
    // Nanti, data ini akan diambil dari API atau local storage.
    var dummyData = [
      ChatModel(id:1, name: 'rifqi', unreadCount: 2),
      ChatModel(id:2,name: 'Olympiad Bus', isGroup: true, unreadCount: 5),
      ChatModel(id:3,name: 'Classtell', unreadCount: 0),
      ChatModel(id:4,name: 'Olympiad Mace', isGroup: true, unreadCount: 0),
      ChatModel(id:5,name: 'faizin', unreadCount: 1),
      ChatModel(id:6,name: 'nailal', isGroup: true, unreadCount: 1),
    ];

    archivedChats.assignAll(dummyData);
  }
}