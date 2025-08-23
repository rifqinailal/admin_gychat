// lib/app/modules/chat_list/chat_list_controller.dart
import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/shared/widgets/pin_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultMessage {
  final ChatModel chat;
  final MessageModel message;
  SearchResultMessage({required this.chat, required this.message});
}

class ChatListController extends GetxController {
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
    searchController = TextEditingController(); 
    searchController.addListener(_onSearchChanged);
    fetchChats();
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
      allChats.where((chat) => chat.isGroup).toList();

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
        id: 1,
        name: 'Jeremy Owen',
        unreadCount: 2,
        messages:[ 
          MessageModel(
            messageId: 1,
            senderId: "user_01",
            senderName: "Jeremy Owen",
            text: "Langsung tanyakan ke indra aja",
            timestamp: DateTime.now(),
            isSender: false,
            type: MessageType.text,
          ),
          MessageModel(
            messageId: 2,
            senderId: "admin_01",
            senderName: "Anda",
            text: "Oke, siap.",
            timestamp: DateTime.now(),
            isSender: true,
            type: MessageType.text,
          ),
        ],
      ),
      ChatModel(
        id: 2,
        name: 'Olympiad Bus',
        isGroup: true,
        unreadCount: 5,
        messages: [
          MessageModel(
            messageId: 3,
            senderId: "user_02",
            senderName: "Pimpinan A",
            text: "Tolong segera diselesaikan ya.",
            timestamp: DateTime.now(),
            isSender: false,
            type: MessageType.text,
          ),
        ],
      ),
      ChatModel(id: 3, name: 'Classtell', unreadCount: 0, messages: []),
      ChatModel(
        id: 7,
        name: 'Projek Selesai',
        isArchived: true,
        messages: [
          MessageModel(
            messageId: 4,
            senderId: "user_03",
            senderName: "Indra Yulianto",
            text: "Laporan final sudah saya kirim.",
            timestamp: DateTime.now(),
            isSender: false,
            type: MessageType.text,
          ),
        ],
      ),
      ChatModel(id: 8, name: 'Indra Yulianto', unreadCount: 0, messages: []),
      ChatModel(
        id: 9,
        name: 'Agas Indransyah',
        unreadCount: 0,
        messages: [
          MessageModel(
            messageId: 5,
            senderId: "user_04",
            senderName: "Agas Indransyah",
            text: "mengetik.....",
            timestamp: DateTime.now(),
            isSender: false,
            type: MessageType.text,
          ),
        ],
      ),
    ];
    _allChats.assignAll(dummyData);
  }
}
