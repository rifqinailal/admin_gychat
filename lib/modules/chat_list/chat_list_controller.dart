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
  var allChatsInternal = <ChatModel>[].obs;
  var isSelectionMode = false.obs;
  var selectedChats = <ChatModel>{}.obs;
  int get archivedChatsCount => allChatsInternal.where((chat) => chat.isArchived).length;
  final int pinLimit = 2;
  late TextEditingController searchController;
  var searchQuery = ''.obs;
  var isSearching = false.obs;
  var searchResultChats = <ChatModel>[].obs;
  var searchResultMessages = <SearchResultMessage>[].obs;

  bool get canDeleteSelectedChats {
    if (selectedChats.isEmpty) {
      return false;
    }
    return selectedChats.every((chat) {
      if (chat.roomType == 'one_to_one') {
        return true;
      }
      if (chat.roomType == 'group' && !chat.isMember) {
        return true;
      }
      return false;
    });
  }

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

  List<ChatModel> get allchats => allChatsInternal;
  List<ChatModel> get allChats {
    final chats = allChatsInternal.where((chat) => !chat.isArchived).toList();
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
      final chat = allChatsInternal.firstWhere((c) => c.roomId == roomId);
      return chat.messages;
    } catch (e) {
      print("Chat with ID $roomId not found. Returning empty list.");
      return [];
    }
  }

  void setPinnedMessage(int roomId, int? messageId) {
    final index = allChatsInternal.indexWhere((c) => c.roomId == roomId);
    if (index != -1) {
      final oldChat = allChatsInternal[index];
      
      ChatModel updatedChat;
      if (messageId == null) {
        updatedChat = oldChat.copyWith(
          clearPinnedMessage: true, 
          messages: oldChat.messages.map((m) => m.copyWith(isPinned: false)).toList(),
        );
      } else {
        updatedChat = oldChat.copyWith(
          pinnedMessageId: messageId,
          messages: oldChat.messages.map((m) {
            return m.copyWith(isPinned: m.messageId == messageId);
          }).toList(),
        );
      }
      
      allChatsInternal[index] = updatedChat;
      saveChatsToStorage();
      allChatsInternal.refresh();
    }
  }

  void addMessageToChat(int roomId, MessageModel message) { 
    final index = allChatsInternal.indexWhere((c) => c.roomId == roomId);
    if (index != -1) {
      final chat = allChatsInternal[index];
      chat.messages.insert(0, message);
      final updatedChat = chat.copyWith( 
        lastMessage: message.text ??
            (message.type == MessageType.image ? 'Image' : 'Document'),
        lastTime: message.timestamp,
      );
      allChatsInternal.removeAt(index);
      allChatsInternal.insert(0, updatedChat);
      saveChatsToStorage();
    }
  }

  void updateMessageInChat(int roomId, MessageModel updatedMessage) {
    final chatIndex = allChatsInternal.indexWhere((c) => c.roomId == roomId);
    if (chatIndex != -1) {
      final chat = allChatsInternal[chatIndex];
      final messageIndex = chat.messages.indexWhere(
        (m) => m.messageId == updatedMessage.messageId,
      );

      if (messageIndex != -1) { 
        chat.messages[messageIndex] = updatedMessage;
        saveChatsToStorage(); 
        print(
          "Message ${updatedMessage.messageId} in room $roomId updated and saved.",
        );
      }
    }
  } 

  void saveChatsToStorage() {
    List<Map<String, dynamic>> chatsJson = allChatsInternal.map((chat) => chat.toJson()).toList();
    _box.write(_boxKey, chatsJson);
    print("Daftar chat berhasil disimpan ke local storage!");
  }

  void loadChatsFromStorage() {
    var chatsJson = _box.read<List>(_boxKey);
    if (chatsJson != null && chatsJson.isNotEmpty) {
      allChatsInternal.value = chatsJson.map(
        (json) => ChatModel.fromJson(Map<String, dynamic>.from(json))
      ).toList();
      print("Daftar chat berhasil dimuat dari local storage!");
    } else {
      fetchChats();
    }
  }

  void _onSearchChanged() { 
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 300),
    );
    searchQuery.value = searchController.text;
  }
  
  void _performSearch() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) { 
      isSearching.value = false;
      searchResultChats.clear();
      searchResultMessages.clear();
      return;
    } 
    isSearching.value = true; 
    searchResultChats.assignAll(
      allChatsInternal.where((chat) => chat.name.toLowerCase().contains(query)),
    );
    List<SearchResultMessage> messageResults = []; 
    for (var chat in allChatsInternal) {
      for (var message in chat.messages) {
        if (message.text != null && message.text!.toLowerCase().contains(query)) {
          messageResults.add(SearchResultMessage(chat: chat, message: message));
        }
      }
    }
    searchResultMessages.assignAll(messageResults);
  }

  void clearSearch() { 
    searchController.clear();
  }

  void updateChatMetadata(int roomId, String? lastMessage, DateTime? lastTime) {
    int index = allChatsInternal.indexWhere((chat) => chat.roomId == roomId);
    if (index != -1) {
      final chat = allChatsInternal[index];
      allChatsInternal.removeAt(index);
      allChatsInternal.insert(
        0,
        chat.copyWith(lastMessage: lastMessage, lastTime: lastTime),
      );
      saveChatsToStorage();
    }
  }

  // Pin dan Unpin
  void pinSelectedChats() {
    int currentPinnedCount = allChatsInternal.where((c) => c.isPinned).length;
    int newPinsCount = selectedChats.where((c) => !c.isPinned).length;
    if (currentPinnedCount + newPinsCount > pinLimit) {
      Get.dialog(PinConfirmationDialog(chatCount: pinLimit));
      return;
    }
    for (var chat in selectedChats) {
      chat.isPinned = !chat.isPinned;
    }
    allChatsInternal.refresh();
    clearSelection();
    saveChatsToStorage();
  }

  // Archive dan Unarchive
  void archiveSelectedChats() {
    for (var chat in selectedChats) {
      chat.isArchived = true;
    }
    allChatsInternal.refresh();
    clearSelection();
    saveChatsToStorage();
  }

  // Delete
  void deleteSelectedChats() {
    allChatsInternal.removeWhere((chat) => selectedChats.contains(chat));
    Get.back();
    clearSelection();
    saveChatsToStorage();
  }

  // Selection
  void startSelection(ChatModel chat) {
    isSelectionMode.value = true;
    selectedChats.add(chat);
    saveChatsToStorage();
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
    allChatsInternal.refresh();
    saveChatsToStorage();
  }

  void addNewChat(ChatModel newChat) {
    // Menambahkan chat baru di posisi paling atas
    allChatsInternal.insert(0, newChat);
    print("Grup baru '${newChat.name}' ditambahkan ke list.");
    saveChatsToStorage();
  }

  void exitFromGroup(int roomId) {
  final index = allChatsInternal.indexWhere((chat) => chat.roomId == roomId && chat.roomType == 'group');
  if (index != -1) {
    final systemMessage = MessageModel(
      chatRoomId: roomId.toString(),
      messageId: DateTime.now().millisecondsSinceEpoch,
      senderId: 'system',
      senderName: 'System',
      text: 'Anda leave the grup',
      timestamp: DateTime.now(),
      isSender: false,
      type: MessageType.system,
    );

    final oldChat = allChatsInternal[index];
    
    final newMessages = List<MessageModel>.from(oldChat.messages);
    newMessages.insert(0, systemMessage);

    final updatedChat = oldChat.copyWith(
      isMember: false,
      messages: newMessages,
      lastMessage: systemMessage.text,
      lastTime: systemMessage.timestamp,
    );

    allChatsInternal[index] = updatedChat;
    
    saveChatsToStorage();

    allChatsInternal.refresh(); 
    
    print("User has exited from group ID: $roomId and a system message was added.");
  }
}

  void deleteGroup(int roomId) {
    allChatsInternal.removeWhere((chat) => chat.roomId == roomId);
    saveChatsToStorage();
    print("Group with ID: $roomId has been deleted.");
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
    allChatsInternal.assignAll(dummyData);
  }
}
