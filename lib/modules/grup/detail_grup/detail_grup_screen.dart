// lib/modules/grup/detail_grup/detail_grup_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';

class DetailGrupScreen extends GetView<DetailGrupController> {
  const DetailGrupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary color from the design
    const primaryColor = const Color.fromARGB(255, 240, 240, 240);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCustomAppBar(Colors.black),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              // Description Card
              _buildInfoCard(
                children: [_buildDescriptionTile()],
              ),
              const SizedBox(height: 20),

              // Media Card
              _buildInfoCard(
                children: [_buildMediaTile()],
              ),
              const SizedBox(height: 20),

              // Invite link Card
              _buildInfoCard(
                children: [_buildInviteTile()],
              ),
              const SizedBox(height: 20),

              // Members Section Card
              _buildMembersSection(),
              const SizedBox(height: 20),
              
              // Exit Group Button
              _buildExitSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // A custom app bar that sits on the blue background
  Widget _buildCustomAppBar(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          const Text(
            'Group info',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: controller.goToEditInfoScreen,
            child: const Text('Edit',
                style: TextStyle(color: Colors.black, fontSize: 17)),
          ),
        ],
      ),
    );
  }

  // Header section with avatar, name, and member count
  Widget _buildHeader() {
    return Column(
      children: [
        Obx(() => CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black.withOpacity(0.1),
              backgroundImage: controller.groupImage.value != null
                  ? FileImage(controller.groupImage.value!)
                  : null,
              child: controller.groupImage.value == null
                  ? const Icon(Icons.group, size: 60, color: Colors.grey)
                  : null,
            )),
        const SizedBox(height: 16),
        Obx(() => Text(
              controller.groupName.value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )),
        const SizedBox(height: 8),
        Obx(() => Text(
              'Group • ${controller.members.length} members',
              style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.9)),
            )),
      ],
    );
  }

  // Description tile with 'see more' link
  Widget _buildDescriptionTile() {
    const int maxChars = 100; // Tentukan batas karakter sebelum 'see more' muncul
    const primaryColor = Colors.black;

    return Obx(() {
      final description = controller.groupDescription.value;
      final isLongText = description.length > maxChars;
      final isExpanded = controller.isDescriptionExpanded.value;

      // Teks yang akan ditampilkan
      final displayText = isLongText && !isExpanded
          ? '${description.substring(0, maxChars)}...'
          : description;

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Colors.black87, fontSize: 16, height: 1.4),
            children: [
              TextSpan(text: displayText),
              // Tampilkan 'see more' atau 'see less' jika teks panjang
              if (isLongText)
                TextSpan(
                  text: isExpanded ? ' see less' : ' see more',
                  style: const TextStyle(color: Color.fromARGB(255, 255, 210, 7), fontWeight: FontWeight.w500),
                  recognizer: TapGestureRecognizer()
                    ..onTap = controller.toggleDescription,
                ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: controller.goToEditDescriptionScreen, // Navigasi ke halaman edit deskripsi
      );
    });
  }
  
  // Media tile showing the count
  Widget _buildMediaTile() {
    return ListTile(
      leading: const Icon(Icons.image_outlined, color: Colors.grey),
      title: const Text('Media, links, and docs', style: TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('10', style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: controller.goToMediaScreen,
    );
  }

  // Invite link tile
  Widget _buildInviteTile() {
    return ListTile(
      leading: const Icon(Icons.link, color: Colors.grey),
      title: const Text('Invite via group link', style: TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // TODO: Handle invite link tap
      },
    );
  }

  // The main members section with list and 'See all' button
  Widget _buildMembersSection() {
    return _buildInfoCard(
      padding: EdgeInsets.zero, // Remove padding to allow full-width list
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Obx(() => Text(
            '${controller.members.length} members',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          )),
        ),
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.members.length > 4 ? 4 : controller.members.length, // Show max 4 members initially
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final member = controller.members[index];
                final isCurrentUser = index == 0; // Assuming current user is always first
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(member),
                  trailing: isCurrentUser ? _buildAdminBadge() : null,
                );
              },
            )),
        const Divider(height: 1, indent: 16),
        ListTile(
          title: const Text('See all', style: TextStyle(color: Colors.black, fontSize: 16)),
          onTap: () {
            // TODO: Navigate to see all members screen
          },
        ),
      ],
    );
  }
  
  // Custom widget for the "Admin Grup" badge
  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Admin Grup',
        style: TextStyle(
          color: Colors.amber.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // The red 'Exit Group' button section
  Widget _buildExitSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: controller.isExitingGroup.value ? null : controller.exitGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Obx(() => controller.isExitingGroup.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.red),
              )
            : const Text(
                'Exit Group',
                style: TextStyle(
                    color: Colors.red, fontSize: 17, fontWeight: FontWeight.normal),
              )),
      ),
    );
  }

  // Reusable card widget for consistent styling
  Widget _buildInfoCard({required List<Widget> children, EdgeInsets? padding}) {
    return Container(
      padding: padding,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}