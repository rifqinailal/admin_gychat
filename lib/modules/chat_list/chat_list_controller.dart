// lib/app/modules/chat_list/chat_list_controller.dart
import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/shared/widgets/pin_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SearchResultMessage {
  final ChatModel chat;
  final MessageModel message;
  SearchResultMessage({required this.chat, required this.message});
}

class ChatListController extends GetxController {
  final _box = GetStorage();
  final _boxKey = 'all_chats';
  var _allChats = <ChatModel>[].obs;
  var isSelectionMode = false.obs;
  var selectedChats = <ChatModel>{}.obs;
  int get archivedChatsCount =>
      _allChats.where((chat) => chat.isArchived).length;
  final int pinLimit = 2;
  late TextEditingController searchController;
  var searchQuery = ''.obs;
  var isSearching = false.obs;
  var searchResultChats = <ChatModel>[].obs;
  var searchResultMessages = <SearchResultMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChatsFromStorage();
    debounce(
      _allChats,
      (_) => saveChatsToStorage(),
      time: const Duration(seconds: 1),
    );
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
  }

  List<ChatModel> get allChatsInternal => _allChats;
  List<ChatModel> get allChats {
    final chats = _allChats.where((chat) => !chat.isArchived).toList();
    chats.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    return chats;
  }

  List<ChatModel> get unreadChats =>
      allChats.where((chat) => chat.unreadCount > 0).toList();
  List<ChatModel> get groupChats =>
      allChats.where((chat) => chat.roomType == 'group').toList();

  void saveChatsToStorage() {
    List<Map<String, dynamic>> chatsJson =
        _allChats.map((chat) => chat.toJson()).toList();
    _box.write(_boxKey, chatsJson);
    print("Daftar chat berhasil disimpan ke local storage!");
  }

  void loadChatsFromStorage() {
    var chatsJson = _box.read<List>(_boxKey);
    if (chatsJson != null && chatsJson.isNotEmpty) {
      _allChats.value =
          chatsJson
              .map(
                (json) => ChatModel.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();
      print("Daftar chat berhasil dimuat dari local storage!");
    } else {
      fetchChats();
    }
  }

  void _onSearchChanged() {
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
    searchQuery.value = searchController.text;
  }

  // Pencarian / Search
  void _performSearch() {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      isSearching.value = false;
      searchResultChats.clear();
      searchResultMessages.clear();
      return;
    }

    isSearching.value = true;

    // Cari di nama chat
    searchResultChats.assignAll(
      _allChats.where((chat) => chat.name.toLowerCase().contains(query)),
    );
    // Cari di dalam pesan
    List<SearchResultMessage> messageResults = [];
    for (var chat in _allChats) {
      for (var message in chat.messages) {
        if (message.text != null &&
            message.text!.toLowerCase().contains(query)) {
          messageResults.add(SearchResultMessage(chat: chat, message: message));
        }
      }
    }
    searchResultMessages.assignAll(messageResults);
  }

  // Membersihkan hasil pencarian
  void clearSearch() {
    searchController.clear();
  }

  // Pin dan Unpin
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

  // Archive dan Unarchive
  void archiveSelectedChats() {
    for (var chat in selectedChats) {
      chat.isArchived = true;
    }
    _allChats.refresh();
    clearSelection();
  }

  // Delete
  void deleteSelectedChats() {
    _allChats.removeWhere((chat) => selectedChats.contains(chat));
    Get.back();
    clearSelection();
  }

  // Selection
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

  // Dummy data untuk testing
  void fetchChats() {
    var dummyData = [
      ChatModel(
        roomId: 10,
        roomMemberId: 2,
        roomType: "group",
        name: "Grup Belajar",
        lastMessage: "Kapan deadline?",
        lastTime: DateTime.now(),
        unreadCount: 2,
      ),
      ChatModel(
        roomId: 11,
        roomMemberId: 3,
        roomType: "one_to_one",
        name: "Peserta 1",
        lastMessage: "Terimakasih Kak",
        lastTime: DateTime.now().subtract(const Duration(hours: 1)),
        isPinned: true,
      ),
      ChatModel(
        roomId: 12,
        roomMemberId: 4,
        roomType: "one_to_one",
        name: "Bantuan Teknis",
        lastMessage: "Oke, akan kami periksa.",
        lastTime: DateTime.now().subtract(const Duration(days: 1)),
        isArchived: true,
      ),
    ];
    _allChats.assignAll(dummyData);
  }
}
