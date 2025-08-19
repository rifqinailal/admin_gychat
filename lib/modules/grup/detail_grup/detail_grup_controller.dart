// lib/modules/grup/detail_grup/detail_grup_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'edit_detail_profile_grup_screen.dart';
import 'edit_description_screen.dart';
import 'grup_media_screen.dart';
import 'grup_invite_link_screen.dart';
import 'grup_qr_code_screen.dart';

class DetailGrupController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Data grup
  var groupName = 'Grup-9 Members'.obs;
  var groupDescription =
  'Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. This makes it easier to focus on the layout and design.'
  .obs; // <-- Deskripsi dibuat lebih panjang untuk demo
  var groupImage = Rx<File?>(null);
  var members = List.generate(8, (index) => 'User ${index + 1}').obs;
  var isExitingGroup = false.obs;

  // State untuk deskripsi
  var isDescriptionExpanded =
      false.obs; // <-- [BARU] State untuk expand/collapse deskripsi

  // Controller untuk text field
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  var selectedMediaTabIndex = 0.obs; // 0: Media, 1: Links, 2: Docs

  // Data dummy untuk ditampilkan
  final RxList<Map<String, String>> mediaList = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> linksList = <Map<String, String>>[].obs;
  final RxList<Map<String, dynamic>> docsList =
      <Map<String, dynamic>>[
        {'name': 'Juknis Olympiade Star', 'type': 'pdf'},
        {'name': 'Juknis Olympiade Star', 'type': 'pdf'},
        {'name': 'Juknis Olympiade Star', 'type': 'pdf'},
        {'name': 'Juknis Olympiade Star', 'type': 'doc'},
        {'name': 'Juknis Olympiade Star', 'type': 'doc'},
        {'name': 'Juknis Olympiade Star', 'type': 'doc'},
      ].obs;

  // Variabel untuk link grup
  var groupInviteLink = 'https://chat.whatsapp.com/llitc1NxjwBGsXGDITXMT'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: groupName.value);
    descriptionController = TextEditingController(text: groupDescription.value);
  }
  
  // [TAMBAHKAN] Fungsi untuk membuka tautan grup
  Future<void> launchGroupLink() async {
    final Uri url = Uri.parse(groupInviteLink.value);
    // Membuka link di aplikasi eksternal (WhatsApp/Browser)
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Gagal', 'Tidak dapat membuka tautan');
    }
  }

  // [TAMBAHKAN] Fungsi untuk navigasi ke halaman QR Code
  void goToQrCodeScreen() {
    Get.to(() => const GrupQrCodeScreen());
  }

  // [BARU] Navigasi ke halaman invite link
  void goToInviteLinkScreen() {
    Get.to(() => const GrupInviteLinkScreen());
  }

  // [BARU] Fungsi untuk menyalin link
  void copyInviteLink() {
    Clipboard.setData(ClipboardData(text: groupInviteLink.value));
    Get.snackbar(
      'Copied',
      'Group invite link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black54,
      colorText: Colors.white,
    );
  }

  // [BARU] Fungsi untuk membagikan link
  void forwardInviteLink() {
    final link = groupInviteLink.value;
    final group = groupName.value;
    // Menggunakan package share_plus untuk membagikan konten
    Share.share('Join the "$group" group on WhatsApp: $link');
  }

  // --- [BARU] Fungsi untuk halaman media ---
  void changeMediaTab(int index) {
    selectedMediaTabIndex.value = index;
  }

  void goToMediaScreen() {
    // Set tab default ke Docs saat halaman dibuka, sesuai desain
    selectedMediaTabIndex.value = 2;
    Get.to(() => const GrupMediaScreen());
  }

  // Fungsi untuk toggle deskripsi
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  void goToEditInfoScreen() {
  nameController.text = groupName.value;
  
  // Gunakan Get.bottomSheet untuk memunculkan widget dari bawah
  Get.bottomSheet(
    const EditDetailProfileGrupScreen(), // Panggil screen yang akan kita buat
    isScrollControlled: true, // Penting agar sheet bisa full screen & menyesuaikan keyboard
    backgroundColor: Colors.transparent, // Agar tidak ada warna latar default
  );
  }

  // [DIPERBARUI] Navigasi ke halaman edit deskripsi
  void goToEditDescriptionScreen() {
    // Pastikan controller text field memiliki data terbaru sebelum navigasi
    descriptionController.text = groupDescription.value;
    Get.to(() => const EditDescriptionScreen());
  }

  // [BARU] Fungsi untuk menyimpan deskripsi
  void saveGroupDescription() {
    groupDescription.value = descriptionController.text;
    Get.back(); // Kembali ke DetailGrupScreen
    Get.snackbar('Success', 'Group description updated!');
  }

  // Menampilkan pilihan untuk edit foto
  void showEditPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF007AFF)),
              title: const Text(
                'Take Photo',
                style: TextStyle(color: Color(0xFF007AFF)),
              ),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF007AFF),
              ),
              title: const Text(
                'Choose Photo',
                style: TextStyle(color: Color(0xFF007AFF)),
              ),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Photo',
                style: TextStyle(color: Colors.red),
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
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete Photo',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> exitGroup() async {
    isExitingGroup.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isExitingGroup.value = false;
    Get.back();
    Get.snackbar('Success', 'You have left the group.');
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      groupImage.value = File(image.path);
    }
  }

  void deletePhoto() {
    groupImage.value = null;
  }

  void saveGroupInfo() {
    if (nameController.text.isNotEmpty) {
      groupName.value = nameController.text;
      Get.back();
      Get.snackbar('Success', 'Group info updated!');
    } else {
      Get.snackbar('Error', 'Group name cannot be empty.');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
