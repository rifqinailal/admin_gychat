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
  int get archivedChatsCount => _allChats.where((chat) => chat.isArchived).length;
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
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    saveChatsToStorage();
    searchController.dispose();
    super.onClose();
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

  List<ChatModel> get unreadChats => allChats.where((chat) => chat.unreadCount > 0).toList();
  List<ChatModel> get groupChats => allChats.where((chat) => chat.roomType == 'group').toList();

  List<MessageModel> getMessagesForRoom(int roomId) {
    try {
      final chat = _allChats.firstWhere((c) => c.roomId == roomId);
      return chat.messages;
    } catch (e) {
      print("Chat with ID $roomId not found. Returning empty list.");
      return [];
    }
  }

  void setPinnedMessage(int roomId, int? messageId) {
    final index = _allChats.indexWhere((c) => c.roomId == roomId);
    if (index != -1) {
      // Dapatkan chat lama
      final chat = _allChats[index];
      // Buat chat baru dengan ID pin yang diperbarui
      final updatedChat = chat.copyWith(pinnedMessageId: messageId);
      // Ganti chat lama dengan yang baru
      _allChats[index] = updatedChat;
      // Simpan perubahan
      saveChatsToStorage();
    }
  }

  // Fungsi untuk menambahkan pesan baru ke room dan menyimpan
  void addMessageToChat(int roomId, MessageModel message) {
    final index = _allChats.indexWhere((c) => c.roomId == roomId);
    if (index != -1) {
      final chat = _allChats[index];

      // Tambahkan pesan baru ke list di dalam ChatModel
      chat.messages.insert(0, message);

      // Buat salinan chat yang sudah diperbarui dan pindahkan ke atas
      final updatedChat = chat.copyWith(
        lastMessage: message.text ?? (
          message.type == MessageType.image ? 'Image' : 'Document'
        ),
        lastTime: message.timestamp,
      );

      _allChats.removeAt(index);
      _allChats.insert(0, updatedChat);

      // Langsung simpan untuk memastikan persistensi
      saveChatsToStorage();
    }
  }

  void updateMessageInChat(int roomId, MessageModel updatedMessage) {
    final chatIndex = _allChats.indexWhere((c) => c.roomId == roomId);
    if (chatIndex != -1) {
      final chat = _allChats[chatIndex];
      final messageIndex = chat.messages.indexWhere(
        (m) => m.messageId == updatedMessage.messageId,
      );

      if (messageIndex != -1) {
        // Ganti pesan lama dengan versi yang sudah diperbarui
        chat.messages[messageIndex] = updatedMessage;
        // Simpan seluruh state aplikasi
        saveChatsToStorage();
        print(
          "Message ${updatedMessage.messageId} in room $roomId updated and saved.",
        );
      }
    }
  } 

  void saveChatsToStorage() {
    List<Map<String, dynamic>> chatsJson = _allChats.map((chat) => chat.toJson()).toList();
    _box.write(_boxKey, chatsJson);
    print("Daftar chat berhasil disimpan ke local storage!");
  }

  void loadChatsFromStorage() {
    var chatsJson = _box.read<List>(_boxKey);
    if (chatsJson != null && chatsJson.isNotEmpty) {
      _allChats.value = chatsJson.map(
        (json) => ChatModel.fromJson(Map<String, dynamic>.from(json))
      ).toList();
      print("Daftar chat berhasil dimuat dari local storage!");
    } else {
      fetchChats();
    }
  }

  void updateChatMetadata(int roomId, String? lastMessage, DateTime? lastTime) { 
    int index = _allChats.indexWhere((chat) => chat.roomId == roomId);
    if (index != -1) {
      final chat = _allChats[index];
      // Pindahkan chat ke paling atas
      _allChats.removeAt(index);
      _allChats.insert(
        0,
        chat.copyWith(lastMessage: lastMessage, lastTime: lastTime),
      );

      // Langsung simpan perubahan
      saveChatsToStorage();
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
        if (message.text != null && message.text!.toLowerCase().contains(query)) {
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

  void addNewChat(ChatModel newChat) {
    // Menambahkan chat baru di posisi paling atas
    _allChats.insert(0, newChat);
    print("Grup baru '${newChat.name}' ditambahkan ke list.");
    saveChatsToStorage();
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
