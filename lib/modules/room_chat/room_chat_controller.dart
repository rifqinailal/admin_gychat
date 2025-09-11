// lib/modules/room_chat/room_chat_controller.dart
import 'dart:io';
import 'package:admin_gychat/models/message_model.dart';
import 'package:admin_gychat/models/quick_reply_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/modules/setting/quick_replies/quick_controller.dart';
import 'package:admin_gychat/modules/star/global/starred_messages_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';

class RoomChatController extends GetxController {
  late TextEditingController messageController;
  late TextEditingController searchController;
  var messages = <MessageModel>[].obs;

  final ChatListController _chatListController = Get.find();

  final String currentUserId = "admin_01";
  var chatRoomInfo = {}.obs;
  var isSearchMode = false.obs;
  var searchQuery = ''.obs;
  var isMessageSelectionMode = false.obs;
  var selectedMessages = <MessageModel>{}.obs;
  var pinnedMessage = Rxn<MessageModel>();
  late QuickController quickController;
  var showQuickReplies = false.obs;
  var filteredQuickReplies = <QuickReply>[].obs;
  var replyMessage = Rxn<MessageModel>();
  var editingMessage = Rxn<MessageModel>();
  var isCurrentUserMember = true.obs;

  List<MessageModel> get filteredMessages {
    if (searchQuery.isEmpty) return messages;
    return messages.where(
      (msg) => msg.text?.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      ) ?? false,
    ).toList();
  }

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int? messageIdToJump;
  var highlightedMessageId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    searchController = TextEditingController();
    quickController = Get.find<QuickController>();
    messageController.addListener(_onTextChanged);
    if (Get.arguments is Map<String, dynamic>) {
      chatRoomInfo.assignAll(Get.arguments);
      messageIdToJump = Get.arguments['jump_to_message'];
    }

    _updateMembershipAndMessages();

    ever(_chatListController.allChatsInternal,
        (_) => _updateMembershipAndMessages());

    WidgetsBinding.instance.addPostFrameCallback((_) => jumpToMessage());
  }

  void _updateMembershipAndMessages() {
  try {
    final int roomId = chatRoomInfo['id'];
    final chat = _chatListController.allChatsInternal.firstWhere((c) => c.roomId == roomId);

    print("DEBUG: Loading room data, pinnedMessageId = ${chat.pinnedMessageId}");

    isCurrentUserMember.value = chat.isMember;

    // Update messages list dari storage
    messages.assignAll(chat.messages);

    // Sinkronkan pinnedMessage state berdasarkan data storage
    if (chat.pinnedMessageId != null) {
      final pinnedMsg = messages.firstWhereOrNull(
        (m) => m.messageId == chat.pinnedMessageId,
      );
      
      if (pinnedMsg != null) {
        pinnedMessage.value = pinnedMsg;
        print("DEBUG: Pinned message loaded: ${pinnedMsg.messageId}");
        
        // Pastikan state isPinned sesuai dengan pinnedMessageId
        for (int i = 0; i < messages.length; i++) {
          final shouldBePinned = messages[i].messageId == chat.pinnedMessageId;
          messages[i] = messages[i].copyWith(isPinned: shouldBePinned);
        }
      } else {
        print("DEBUG: Pinned message not found in messages list");
        pinnedMessage.value = null;
      }
    } else {
      print("DEBUG: No pinned message in this room");
      pinnedMessage.value = null;
      
      // Pastikan tidak ada message yang terpinning
      for (int i = 0; i < messages.length; i++) {
        messages[i] = messages[i].copyWith(isPinned: false);
      }
    }
    
    messages.refresh();
  } catch (e) {
    isCurrentUserMember.value = false;
    print("Error updating room data: $e");
  }
}

  @override
  void onClose() {
    messageController.removeListener(_onTextChanged);
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void sendMessage() {
    if (editingMessage.value != null) {
      updateMessage();
      return;
    }
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch,
      senderId: currentUserId,
      senderName: "Anda",
      text: text,
      repliedMessage: replyMessage.value != null ? {
        'name': replyMessage.value!.senderName,
        'text': replyMessage.value!.text ?? 'File',
        'messageId': replyMessage.value!.messageId.toString(),
      } : null,
      timestamp: DateTime.now(),
      isSender: true,
      type: MessageType.text,
      chatRoomId: chatRoomInfo['id'].toString(),
    );

    messages.insert(0, newMessage);
    _chatListController.addMessageToChat(chatRoomInfo['id'], newMessage);
    messageController.clear();
    cancelReply();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void takePicture() {
    _sendImage(ImageSource.camera);
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: ThemeColor.black,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Crop Image',
                aspectRatioLockEnabled: false,
              ),
            ]);

        if (croppedFile != null) {
          _showImagePreview(XFile(croppedFile.path), messageController.text);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses gambar: $e');
    }
  }

  Future<void> _sendDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpeg', 'jpg', 'png'],
      );
      if (result != null) {
        final PlatformFile file = result.files.first;

        print('====== DEBUG FILE PICKER ======');
        print('File Name: ${file.name}');
        print('File Path: ${file.path}');
        print('File Size: ${file.size}'); 
        print('=============================');
        
        _showDocumentPreview(file, messageController.text);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih dokumen: $e');
    }
  }

  Future<void> _showImagePreview(XFile pickedFile, String existingText) async {
    final TextEditingController captionController =
        TextEditingController(text: existingText);

    Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(pickedFile.path), fit: BoxFit.scaleDown),
            Positioned(
              top: 40,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan keterangan...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16),
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.send, color: ThemeColor.primary),
                        onPressed: () {
                          final newMessage = MessageModel(
                            chatRoomId: chatRoomInfo['id'].toString(),
                            messageId: DateTime.now().millisecondsSinceEpoch,
                            senderId: currentUserId,
                            senderName: "Anda",
                            timestamp: DateTime.now(),
                            isSender: true,
                            type: MessageType.image,
                            imagePath: pickedFile.path,
                            text: captionController.text.trim(),
                            repliedMessage: replyMessage.value != null
                                ? {
                                    'name': replyMessage.value!.senderName,
                                    'text':
                                        replyMessage.value!.text ?? 'File',
                                    'messageId':
                                        replyMessage.value!.messageId.toString(),
                                  }
                                : null,
                          );
                          messages.insert(0, newMessage);
                          _chatListController.addMessageToChat(
                              chatRoomInfo['id'], newMessage);
                          Get.back();
                          cancelReply();

                          messageController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showDocumentPreview(
      PlatformFile file, String existingText) async {
    final TextEditingController captionController =
        TextEditingController(text: existingText);

    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file_rounded,
                      color: Colors.white, size: 100),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      file.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan keterangan...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16),
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                    FloatingActionButton(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.send, color: ThemeColor.primary),
                      onPressed: () {
                        final newMessage = MessageModel(
                          chatRoomId: chatRoomInfo['id'].toString(),
                          messageId: DateTime.now().millisecondsSinceEpoch,
                          senderId: currentUserId,
                          senderName: "Anda",
                          timestamp: DateTime.now(),
                          isSender: true,
                          type: MessageType.document,
                          documentPath: file.path,
                          documentName: file.name,
                          documentSize: file.size,
                          text: captionController.text.trim(),
                          repliedMessage: replyMessage.value != null
                              ? {
                                  'name': replyMessage.value!.senderName,
                                  'text':
                                      replyMessage.value!.text ?? 'File',
                                  'messageId':
                                      replyMessage.value!.messageId.toString(),
                                }
                              : null,
                        );
                        messages.insert(0, newMessage);
                        _chatListController.addMessageToChat(
                            chatRoomInfo['id'], newMessage);
                        Get.back();
                        cancelReply();
                        messageController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const SizedBox.shrink(),
              trailing: const Icon(Icons.close, color: Colors.black),
              onTap: () => Get.back(),
            ),
            ListTile(
              trailing: const Icon(
                Icons.photo_library,
                color: Colors.blueAccent,
              ),
              leading: const Text(
                'Choose images',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
              onTap: () {
                Get.back();
                _sendImage(ImageSource.gallery);
              },
            ),
            const Divider(height: 1, thickness: 1),
            ListTile(
              trailing:
                  const Icon(Icons.insert_drive_file, color: Colors.red),
              leading: const Text(
                'Choose dokumen',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
              onTap: () {
                Get.back();
                _sendDocument();
              },
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  void starSelectedMessages() {
    for (var msg in selectedMessages) {
      var index = messages.indexWhere((m) => m.messageId == msg.messageId);
      if (index != -1) {
        final updatedMessage = messages[index].copyWith(
          isStarred: !messages[index].isStarred,
        );
        messages[index] = updatedMessage;
        _chatListController.updateMessageInChat(
          chatRoomInfo['id'],
          updatedMessage,
        );
      }
    }
    messages.refresh();

    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().loadStarredMessages();
    }
    clearMessageSelection();
  }

  void pinSelectedMessages() {
  if (selectedMessages.length == 1) {
    final messageToToggle = selectedMessages.first;
    final currentPinnedId = _chatListController.allChatsInternal
        .firstWhere((c) => c.roomId == chatRoomInfo['id'])
        .pinnedMessageId;

    if (currentPinnedId == messageToToggle.messageId) {
      // UNPIN - Hapus pin
      print("UNPIN: Removing pin from message ${messageToToggle.messageId}");
      
      // Update ChatListController dan save to storage
      _chatListController.setPinnedMessage(chatRoomInfo['id'], null);
      
      // Update state lokal
      pinnedMessage.value = null;
      
      // Update message local state - set semua isPinned = false
      for (int i = 0; i < messages.length; i++) {
        messages[i] = messages[i].copyWith(isPinned: false);
      }
    } else {
      // PIN - Set pin baru
      print("PIN: Setting pin to message ${messageToToggle.messageId}");
      
      // Update ChatListController dan save to storage
      _chatListController.setPinnedMessage(
        chatRoomInfo['id'],
        messageToToggle.messageId,
      );
      
      // Update state lokal
      pinnedMessage.value = messageToToggle;
      
      // Update semua message state - hanya satu yang boleh di-pin
      for (int i = 0; i < messages.length; i++) {
        final isPinnedNow = messages[i].messageId == messageToToggle.messageId;
        messages[i] = messages[i].copyWith(isPinned: isPinnedNow);
      }
    }
    
    // Refresh UI dan save local messages
    messages.refresh();
    
    // Debug: Print current pin status
    print("DEBUG: Current pinnedMessageId = ${_chatListController.allChatsInternal
        .firstWhere((c) => c.roomId == chatRoomInfo['id'])
        .pinnedMessageId}");
    
  } else if (selectedMessages.length > 1) {
    Get.snackbar('Info', 'Hanya bisa menyematkan satu pesan dalam satu waktu.');
  }
  
  clearMessageSelection();
}

void debugPinStatus() {
  print("=== DEBUG PIN STATUS ===");
  
  // 1. Check pinnedMessage.value
  print("Local pinnedMessage.value: ${pinnedMessage.value?.messageId ?? 'null'}");
  
  // 2. Check ChatListController data
  final chat = _chatListController.allChatsInternal.firstWhereOrNull((c) => c.roomId == chatRoomInfo['id']);
  if (chat != null) {
    print("ChatListController pinnedMessageId: ${chat.pinnedMessageId ?? 'null'}");
    
    // 3. Check messages isPinned status
    final pinnedMessages = chat.messages.where((m) => m.isPinned).toList();
    print("Messages with isPinned=true: ${pinnedMessages.map((m) => m.messageId).toList()}");
    
    // 4. Check storage data
    final storage = GetStorage();
    final chatsJson = storage.read('all_chats');
    if (chatsJson != null) {
      final chatInStorage = (chatsJson as List).firstWhere(
        (json) => json['room_id'] == chatRoomInfo['id'], 
        orElse: () => null
      );
      if (chatInStorage != null) {
        print("Storage pinnedMessageId: ${chatInStorage['pinned_message_id'] ?? 'null'}");
        
        final messagesInStorage = chatInStorage['messages'] as List;
        final pinnedInStorage = messagesInStorage.where((m) => m['isPinned'] == true).toList();
        print("Storage messages with isPinned=true: ${pinnedInStorage.map((m) => m['messageId']).toList()}");
      }
    }
  }
  
  print("=========================");
}

  void jumpToPinnedMessage() {
    if (pinnedMessage.value != null) {
      jumpToMessage(messageId: pinnedMessage.value!.messageId);
    }
  }

  void deleteMessages({required bool deleteForAll}) {
    List<MessageModel> messagesToDelete = List.from(selectedMessages);

    for (var msg in messagesToDelete) {
      if (pinnedMessage.value != null &&
          msg.messageId == pinnedMessage.value!.messageId) {
        _chatListController.setPinnedMessage(chatRoomInfo['id'], null);
        pinnedMessage.value = null; // [FIX] Update state lokal
      }
    }

    if (!deleteForAll) {
      messages.removeWhere((msg) => messagesToDelete.contains(msg));
    } else {
      for (var msg in messagesToDelete) {
        var index = messages.indexWhere((m) => m.messageId == msg.messageId);
        if (index != -1) {
          final updatedMessage = messages[index].copyWith(isDeleted: true);
          messages[index] = updatedMessage;
          _chatListController.updateMessageInChat(
            chatRoomInfo['id'],
            updatedMessage,
          );
        }
      }
    }

    if (!deleteForAll) {
      final chat = _chatListController.allChatsInternal.firstWhere(
        (c) => c.roomId == chatRoomInfo['id'],
      );
      chat.messages.removeWhere((msg) => messagesToDelete.contains(msg));
    }

    _chatListController.saveChatsToStorage();
    messages.refresh();
    clearMessageSelection();
  }

  void updateMessage() {
    final newText = messageController.text.trim();
    if (editingMessage.value != null && newText.isNotEmpty) {
      var index = messages.indexWhere(
        (m) => m.messageId == editingMessage.value!.messageId,
      );
      if (index != -1) {
        final updatedMessage = messages[index].copyWith(text: newText);
        messages[index] = updatedMessage;
        _chatListController.updateMessageInChat(
          chatRoomInfo['id'],
          updatedMessage,
        );
      }
      messages.refresh();
      cancelEdit();
    }
  }

  void jumpToMessage({int? messageId}) {
    final targetId = messageId ?? messageIdToJump;
    if (targetId != null && itemScrollController.isAttached) {
      final index = messages.indexWhere((m) => m.messageId == targetId);
      if (index != -1) {
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
        highlightedMessageId.value = targetId;
        Future.delayed(const Duration(seconds: 2), () {
          if (highlightedMessageId.value == targetId) {
            highlightedMessageId.value = null;
          }
        });
      }
      if (messageId == null) {
        messageIdToJump = null;
      }
    }
  }

  Future<void> openDocument(String path) async {
    try {
      await OpenFilex.open(path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka file. Pastikan ada aplikasi yang mendukung.',
      );
    }
  }

  void _onTextChanged() {
    final text = messageController.text;
    if (text.startsWith('/')) {
      showQuickReplies.value = true;
      final query = text.substring(1).toLowerCase();
      if (query.isEmpty) {
        filteredQuickReplies.assignAll(quickController.quickReplies);
      } else {
        filteredQuickReplies.assignAll(
          quickController.quickReplies.where(
            (reply) => reply.shortcut.toLowerCase().contains(query),
          ),
        );
      }
    } else {
      showQuickReplies.value = false;
    }
  }

  void selectQuickReply(QuickReply reply) {
    if (reply.imageFile != null) {
      final newMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch,
        senderId: currentUserId,
        senderName: "Anda",
        chatRoomId: chatRoomInfo['id'].toString(),
        timestamp: DateTime.now(),
        isSender: true,
        type: MessageType.image,
        imagePath: reply.imageFile!.path,
        text: reply.message.isNotEmpty ? reply.message : null,
        repliedMessage: replyMessage.value != null
            ? {
                'name': replyMessage.value!.senderName,
                'text': replyMessage.value!.text ?? 'File',
                'messageId': replyMessage.value!.messageId.toString(),
              }
            : null,
      );
      messages.insert(0, newMessage);
      _chatListController.addMessageToChat(chatRoomInfo['id'], newMessage);
      messageController.clear();
      cancelReply();
    } else {
      messageController.text = reply.message;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
    }
    showQuickReplies.value = false;
  }

  void startMessageSelection(MessageModel message) {
    isMessageSelectionMode.value = true;
    selectedMessages.add(message);
  }

  void toggleMessageSelection(MessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
    if (selectedMessages.isEmpty) {
      isMessageSelectionMode.value = false;
    }
  }

  void clearMessageSelection() {
    selectedMessages.clear();
    isMessageSelectionMode.value = false;
  }

  void toggleSearchMode() {
    isSearchMode.value = !isSearchMode.value;
    if (!isSearchMode.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setReplyMessage(MessageModel message) {
    replyMessage.value = message;
  }

  void cancelReply() {
    replyMessage.value = null;
  }

  void copySelectedMessagesText() {
    String copiedText = selectedMessages.map((m) => m.text).join('\n');
    Clipboard.setData(ClipboardData(text: copiedText));
    Get.snackbar('Disalin', 'Teks pesan telah disalin ke clipboard.');
    clearMessageSelection();
  }

  void showDeleteConfirmationDialog() {
    bool canDeleteForAll = selectedMessages.every((msg) => msg.isSender);
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hapus pesan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canDeleteForAll)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          deleteMessages(deleteForAll: true);
                        },
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Hapus untuk semua orang',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: ThemeColor.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        deleteMessages(deleteForAll: false);
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Hapus untuk saya',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemeColor.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Batal',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemeColor.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setEditMessage() {
    if (selectedMessages.length == 1) {
      final messageToEdit = selectedMessages.first;
      if (messageToEdit.isSender &&
          (messageToEdit.type == MessageType.text ||
              messageToEdit.type == MessageType.image)) {
        editingMessage.value = messageToEdit;
        messageController.text = messageToEdit.text ?? '';
        messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length),
        );
        clearMessageSelection();
      } else {
        Get.snackbar(
          'Info',
          'Hanya pesan teks atau gambar Anda yang bisa diedit.',
        );
        clearMessageSelection();
      }
    }
  }

  void cancelEdit() {
    editingMessage.value = null;
    messageController.clear();
  }

  void showImageFullScreen(String imagePath) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(File(imagePath)),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => downloadImage(imagePath),
                  icon: const Icon(Icons.download, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  Future<void> downloadImage(String imagePath) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final String fileName =
            "IMG_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result = await SaverGallery.saveFile(
          androidRelativePath: "Pictures/GychatAdmin",
          filePath: imagePath,
          fileName: fileName,
          skipIfExists: true,
        );
        if (result.isSuccess) {
          Get.snackbar('Berhasil', 'Gambar berhasil disimpan di galeri.');
        } else {
          Get.snackbar(
            'Gagal',
            'Tidak dapat menyimpan gambar: ${result.errorMessage}',
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan gambar.');
      }
    } else {
      Get.snackbar(
        'Izin Ditolak',
        'Izin akses penyimpanan dibutuhkan untuk menyimpan gambar.',
      );
    }
  }

  void jumpToReplyMessage(String replyMessageId) {
    try {
      final int targetMessageId = int.parse(replyMessageId);
      final index = messages.indexWhere((m) => m.messageId == targetMessageId);
      if (index != -1 && itemScrollController.isAttached) {
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        highlightedMessageId.value = targetMessageId;
        Future.delayed(const Duration(seconds: 2), () {
          if (highlightedMessageId.value == targetMessageId) {
            highlightedMessageId.value = null;
          }
        });
      } else {
        Get.snackbar(
          'Info',
          'Pesan yang direply tidak ditemukan',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Error jumping to reply message: $e');
    }
  }
}