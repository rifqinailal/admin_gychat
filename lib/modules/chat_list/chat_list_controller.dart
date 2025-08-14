import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/shared/widgets/pin_confirmation_dialog.dart';
import 'package:get/get.dart';

class ChatListController extends GetxController {
  var _allChats = <ChatModel>[].obs;
  var isSelectionMode = false.obs;
  var selectedChats = <ChatModel>{}.obs;
  int get archivedChatsCount =>
      _allChats.where((chat) => chat.isArchived).length;
  final int pinLimit = 2;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  List<ChatModel> get allChatsInternal => _allChats;
  List<ChatModel> get allChats {
    final chats = _allChats.where((chat) => !chat.isArchived).toList();
    chats.sort((a, b) {
      // Jika a di-pin dan b tidak, maka a harus di atas (return -1)
      if (a.isPinned && !b.isPinned) return -1;
      // Jika b di-pin dan a tidak, maka b harus di atas (return 1)
      if (!a.isPinned && b.isPinned) return 1;
      // Jika keduanya sama (sama-sama di-pin atau tidak), biarkan urutan aslinya
      return 0;
    });
    return chats;
  }

  List<ChatModel> get unreadChats =>
      allChats.where((chat) => chat.unreadCount > 0).toList();
  List<ChatModel> get groupChats =>
      allChats.where((chat) => chat.isGroup).toList();

  void pinSelectedChats() {
    int currentPinnedCount = _allChats.where((c) => c.isPinned).length;
    int newPinsCount = selectedChats.where((c) => !c.isPinned).length;
    if (currentPinnedCount + newPinsCount > pinLimit) {
      Get.dialog(PinConfirmationDialog(chatCount: pinLimit));
      return;
    }
    for (var chat in selectedChats) {
      chat.isPinned = !chat.isPinned;
    }

    _allChats.refresh();
    clearSelection();
  }

  void archiveSelectedChats() {
    for (var chat in selectedChats) {
      chat.isArchived = true;
    }
    _allChats.refresh();
    clearSelection();
  }

  void deleteSelectedChats() {
    _allChats.removeWhere((chat) => selectedChats.contains(chat));
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
