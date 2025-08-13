import 'package:admin_gychat/models/chat_model.dart';
import 'package:get/get.dart';

class ChatListController extends GetxController {
  var _allChats = <ChatModel>[].obs;
  var isSelectionMode = false.obs;
  var selectedChats = <ChatModel>{}.obs;
  int get archivedChatsCount => _allChats.where((chat) => chat.isArchived).length;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  List<ChatModel> get allChatsInternal => _allChats;
  List<ChatModel> get allChats =>
      _allChats.where((chat) => !chat.isArchived).toList();
  List<ChatModel> get unreadChats =>
      allChats.where((chat) => chat.unreadCount > 0).toList();
  List<ChatModel> get groupChats =>
      allChats.where((chat) => chat.isGroup).toList();

  void archiveSelectedChats() {
    for (var chat in selectedChats) {
      chat.isArchived = true;
    }
    _allChats.refresh();
    clearSelection();
  }

  void deleteSelectedChats() {
    print('Menghapus ${selectedChats.length} chat...');
    allChats.removeWhere((chat) => selectedChats.contains(chat));
    Get.back();
    clearSelection();
  }

  void startSelection(ChatModel chat) {
    isSelectionMode.value = true;
    selectedChats.add(chat);
  }

  void toggleSelection(ChatModel chat) {
    if (selectedChats.contains(chat)) {
      selectedChats.remove(chat);
    } else {
      selectedChats.add(chat);
    }
    if (selectedChats.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void clearSelection() {
    selectedChats.clear();
    isSelectionMode.value = false;
  }

  void refreshChatList() {
    _allChats.refresh();
  }

  void fetchChats() {
    var dummyData = [
      ChatModel(id: 1, name: 'Jeremy Owen', unreadCount: 2),
      ChatModel(id: 2, name: 'Olympiad Bus', isGroup: true, unreadCount: 5),
      ChatModel(id: 3, name: 'Classtell', unreadCount: 0),
      ChatModel(id: 7, name: 'Projek Selesai', isArchived: true),
    ];
    _allChats.assignAll(dummyData);
  }
}
