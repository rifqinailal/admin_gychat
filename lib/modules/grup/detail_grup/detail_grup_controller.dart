// lib/modules/grup/detail_grup/detail_grup_controller.dart
import 'dart:io';
import 'package:admin_gychat/models/chat_model.dart';
import 'package:admin_gychat/modules/chat_list/chat_list_controller.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_description_screen.dart';
import 'edit_detail_profile_grup_screen.dart';
import 'grup_invite_link_screen.dart';
import 'grup_media_screen.dart';
import 'grup_qr_code_screen.dart';

class DetailGrupController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ChatListController _chatListController = Get.find<ChatListController>();

  // var groupName = 'Grup-9 Members'.obs; 
  // var groupDescription = 'Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. This makes it easier to focus on the layout and design.'.obs;
  // var groupImage = Rx<File?>(null);
  //var members = List.generate(8, (index) => 'User ${index + 1}').obs;
  var chat = Rxn<ChatModel>();
  var isExitingGroup = false.obs;
  var isDescriptionExpanded = false.obs;
  var isCurrentUserMember = true.obs;

  late TextEditingController nameController; 
  late TextEditingController descriptionController;
  late final int _roomId;

  var selectedMediaTabIndex = 0.obs; // 0: Media, 1: Links, 2: Docs

  // Data dummy untuk ditampilkan
  final RxList<Map<String, String>> mediaList = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> linksList = <Map<String, String>>[].obs;
  final RxList<Map<String, dynamic>> docsList = <Map<String, dynamic>>[
    {'name': 'Juknis Olympiade Star', 'type': 'pdf'},
    {'name': 'Juknis Olympiade Star', 'type': 'pdf'},
    {'name': 'Juknis Olympiade Star', 'type': 'pdf'},
    {'name': 'Juknis Olympiade Star', 'type': 'doc'},
    {'name': 'Juknis Olympiade Star', 'type': 'doc'},
    {'name': 'Juknis Olympiade Star', 'type': 'doc'}
  ].obs;

  // Variabel untuk link grup
  var groupInviteLink = 'https://chat.whatsapp.com/llitc1NxjwBGsXGDITXMT'.obs;

  // Getter untuk kemudahan akses data
  String get groupName => chat.value?.name ?? 'Loading...';
  String get groupDescription => chat.value?.description ?? '';
  File? get groupImage => chat.value?.urlPhoto != null ? File(chat.value!.urlPhoto!) : null;
  List<String> get members => List.generate(8, (index) => 'User ${index + 1}');
  int get memberCount => members.length;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    descriptionController = TextEditingController();

    if (Get.arguments != null && Get.arguments is Map<String, dynamic> && Get.arguments['id'] != null) {
      _roomId = Get.arguments['id'];
      _loadGroupData();
      ever(_chatListController.allChatsInternal, (_) => _loadGroupData());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error', 'Gagal membuka detail grup.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: ThemeColor.Red1.withOpacity(0.8),
          colorText: ThemeColor.white,
        );
        if (Get.routing.previous.isNotEmpty) {
          Get.back();
        }
      });
    }
  }

  void _loadGroupData() {
    try {
      final currentChat = _chatListController.allChatsInternal.firstWhere((c) => c.roomId == _roomId);
      chat.value = currentChat;
      isCurrentUserMember.value = currentChat.isMember;
      nameController.text = currentChat.name;
      descriptionController.text = currentChat.description ?? '';
    } catch (e) {
      print("Error finding group: $e");
      Get.back(); // Kembali jika grup tidak ditemukan
    }
  }

  // Memilih dan memotong gambar
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          // TODO: Panggil fungsi di ChatListController untuk update foto
          // _chatListController.updateGroupPhoto(_roomId, croppedFile.path);
          Get.snackbar(
            'Success',
            'Group photo updated successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: ThemeColor.white,
            margin: const EdgeInsets.all(18),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.Red1.withOpacity(0.8),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18),
      );
    }
  }

  void deletePhoto() {
    if (groupImage != null) {
      // TODO: Panggil fungsi di ChatListController untuk menghapus foto (mengirim path null)
      // _chatListController.updateGroupPhoto(_roomId, null);
      Get.snackbar(
        'Success', 'Group photo has been deleted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18)
      );

    } else {
      Get.snackbar(
        'Info', 'No group photo to delete.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.primary.withOpacity(0.8),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18)
      );
    }
  }

  // Memotong gambar
  Future<CroppedFile?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: ThemeColor.black,
          toolbarWidgetColor: ThemeColor.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
  }

  // Melihat gambar grup
  Future<void> viewGroupImage() async {
    if (groupImage != null) {
      await Get.to(
        () => Scaffold(
          backgroundColor: ThemeColor.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.zero,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.file(
                  groupImage!,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 50.0,
                left: 16.0,
                child: CircleAvatar(
                  backgroundColor: ThemeColor.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: ThemeColor.white,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ],
          ),
        ),
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // Fungsi untuk membuka tautan grup
  Future<void> launchGroupLink() async {
    final Uri url = Uri.parse(groupInviteLink.value);
    // Membuka link di aplikasi eksternal (Gychat/Browser)
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Gagal', 'Tidak dapat membuka tautan');
    }
  }

  // Fungsi untuk navigasi ke halaman QR Code
  void goToQrCodeScreen() => Get.to(() => const GrupQrCodeScreen());

  // Navigasi ke halaman invite link
  void goToInviteLinkScreen() => Get.to(() => const GrupInviteLinkScreen());

  // Fungsi untuk menyalin link
  void copyInviteLink() {
    Clipboard.setData(ClipboardData(text: groupInviteLink.value));
    Get.snackbar(
      'Copied',
      'Group invite link copied to clipboard',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: ThemeColor.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void forwardInviteLink() {
    final link = groupInviteLink.value;
    final group = groupName;
    Share.share('Join the "$group" group on Gychat: $link');
  }

  void changeMediaTab(int index) => selectedMediaTabIndex.value = index;

  void goToMediaScreen() {
    selectedMediaTabIndex.value = 2; // Asumsi Docs adalah tab ke-2
    Get.to(() => const GrupMediaScreen());
  }

  // Fungsi untuk toggle deskripsi
  void toggleDescription() => isDescriptionExpanded.value = !isDescriptionExpanded.value;

  void goToEditInfoScreen() => Get.bottomSheet(const EditDetailProfileGrupScreen(), isScrollControlled: true);

  void goToEditDescriptionScreen() => Get.bottomSheet(const EditDescriptionScreen(), isScrollControlled: true, backgroundColor: Colors.transparent);

  // Menyimpan deskripsi
  void saveGroupDescription() {
    // TODO: Tambahkan logic untuk update deskripsi di ChatListController
    Get.back();
    Get.snackbar(
      'Success',
      'Group description updated!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: ThemeColor.white,
      margin: const EdgeInsets.all(18),
    );
  }

  // Menampilkan pilihan untuk edit foto
  void showEditPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: ThemeColor.black,
                size: 20
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(
                  color: ThemeColor.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: ThemeColor.black,
                size: 20,
              ),
              title: const Text(
                'Choose Photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ThemeColor.black
                ),
              ),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: ThemeColor.Red1),
              title: const Text(
                'Delete Photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ThemeColor.Red1
                ),
              ),
              onTap: () {
                Get.back();
                showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteConfirmation() {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                deletePhoto();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete Photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.Red1,
                  fontSize: 18
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: ThemeColor.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
  
  Future<void> exitOrDeleteGroup() async {
    if (isCurrentUserMember.value) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              "Exit Group",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
            ),
          ),
          content: Text(
            "Do you want to leave group \"$groupName\"?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: ThemeColor.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeColor.primary,
                      side: const BorderSide(color: ThemeColor.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      isExitingGroup.value = true;
                      await Future.delayed(const Duration(seconds: 1));
                      _chatListController.exitFromGroup(_roomId);
                      isExitingGroup.value = false;
                      Get.snackbar(
                        'Success',
                        'You have successfully left the group.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green.withOpacity(0.8),
                        colorText: ThemeColor.white,
                        margin: const EdgeInsets.all(18),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.primary,
                      foregroundColor: ThemeColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Exit",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              "Delete Group",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
            ),
          ),
          content: const Text(
            "Group will be removed from your chat list.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeColor.primary,
                      side: const BorderSide(color: ThemeColor.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _chatListController.deleteGroup(_roomId);
                      Get.offNamedUntil(AppRoutes.Dashboard, (route) => route.isFirst);
                      Get.snackbar(
                        'Success',
                        'Group successfully deleted.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green.withOpacity(0.8),
                        colorText: ThemeColor.white,
                        margin: const EdgeInsets.all(18),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.primary,
                      foregroundColor: ThemeColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void saveGroupInfo() {
    if (nameController.text.isNotEmpty) {
      // TODO: Tambahkan logic untuk update nama grup di ChatListController
      Get.back();
      Get.snackbar(
        'Success',
        'Group info updated!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18),
      );
    } else {
      Get.snackbar(
        'Error',
        'Group name cannot be empty.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ThemeColor.Red1.withOpacity(0.8),
        colorText: ThemeColor.white,
        margin: const EdgeInsets.all(18),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
} 