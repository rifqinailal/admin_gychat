// lib/modules/grup/detail_grup/detail_grup_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class DetailGrupScreen extends GetView<DetailGrupController> {
  const DetailGrupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.lightGrey1,
      body: SafeArea(
        child: Obx(() {
          // Menampilkan loading jika data chat belum siap
          if (controller.chat.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // Setelah data siap, tampilkan layout utama
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCustomAppBar(),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildExitedBanner(),
                if (!controller.isCurrentUserMember.value)
                  const SizedBox(height: 20),
                  
                if (controller.isCurrentUserMember.value) ...[
                  _buildInfoCard(children: [_buildDescriptionTile()]),
                  const SizedBox(height: 20),
                ],

                _buildInfoCard(children: [_buildMediaTile()]),
                const SizedBox(height: 20),

                if (controller.isCurrentUserMember.value) ...[
                  _buildInfoCard(children: [_buildInviteTile()]),
                  const SizedBox(height: 20),
                ],

                _buildMembersSection(),
                const SizedBox(height: 20),

                _buildExitOrDeleteSection(),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExitedBanner() {
    if (!controller.isCurrentUserMember.value) {
      return Container(
        width: double.infinity,
        color: ThemeColor.yelow,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Text(
          'Anda bukan lagi anggota grup ini',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ThemeColor.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: ThemeColor.black,
              size: 22,
            ),
            onPressed: () => Get.back(),
          ),
          const Text(
            'Group info',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: ThemeColor.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Tombol 'Edit' hanya tampil jika masih menjadi anggota
          controller.isCurrentUserMember.value
              ? TextButton(
                  onPressed: controller.goToEditInfoScreen,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: ThemeColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
              : const SizedBox(width: 60),
        ],
      ),
    );
  }
  
  // Header section with group image and name
  Widget _buildHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (controller.groupImage != null) {
              controller.viewGroupImage();
            }
          },
          child: CircleAvatar(
            radius: 50,
            backgroundColor: ThemeColor.grey4,
            backgroundImage: controller.groupImage != null
                ? FileImage(controller.groupImage!)
                : null,
            child: controller.groupImage == null
                ? const Icon(Icons.group, size: 60, color: ThemeColor.grey5)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.groupName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeColor.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Group • ${controller.memberCount} members',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins',
            color: ThemeColor.mediumGrey5,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTile() {
    const int maxChars = 76;
    return Obx(() {
      final description = controller.groupDescription;
      final isLongText = description.length > maxChars;
      final isExpanded = controller.isDescriptionExpanded.value;
      final displayText = isLongText && !isExpanded ? '${description.substring(0, maxChars)}...' : description;

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: ThemeColor.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              TextSpan(text: displayText),
              if (isLongText)
                TextSpan(
                  text: isExpanded ? ' see less' : ' see more',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: ThemeColor.yelow,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = controller.toggleDescription,
                ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: ThemeColor.black,
        ),
        onTap: controller.goToEditDescriptionScreen,
      );
    });
  }
  
  // Media tile
  Widget _buildMediaTile() {
    return ListTile(
      leading: const Icon(Icons.image_outlined, size: 26, color: ThemeColor.black),
      title: const Text(
        'Media, links, and docs',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: ThemeColor.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '10',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: ThemeColor.black,
              fontWeight: FontWeight.normal,
              fontSize: 17,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: ThemeColor.black),
        ],
      ),
      onTap: controller.goToMediaScreen,
    );
  }
  
  // Invite link tile
  Widget _buildInviteTile() {
    return ListTile(
      leading: const Icon(Icons.link, size: 26, color: ThemeColor.black),
      title: const Text(
        'Invite via group link',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: ThemeColor.black,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ThemeColor.black),
      onTap: controller.goToInviteLinkScreen,
    );
  }
  
  // Members section
  Widget _buildMembersSection() {
    return _buildInfoCard(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${controller.memberCount} members',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: ThemeColor.black,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.members.length > 4 ? 4 : controller.members.length,
          separatorBuilder: (context, index) => const Divider(height: 5, indent: 72),
          itemBuilder: (context, index) {
            final member = controller.members[index];
            final isCurrentUser = index == 0;
            return ListTile(
              leading: const CircleAvatar(
                radius: 20,
                backgroundColor: ThemeColor.grey4,
                child: Icon(Icons.person, color: ThemeColor.grey5, size: 30),
              ),
              title: Text(member),
              trailing: isCurrentUser ? _buildAdminBadge() : null,
            );
          },
        ),
        const Divider(height: 1, indent: 20),
        ListTile(
          title: const Text(
            'See all',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: ThemeColor.black,
              fontSize: 16,
            ),
          ),
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
        color: ThemeColor.yelow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Admin Grup',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: ThemeColor.black,
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildExitOrDeleteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isExitingGroup.value ? null : controller.exitOrDeleteGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          alignment: Alignment.centerLeft,
        ),
        child: controller.isExitingGroup.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: ThemeColor.Red1),
              )
            : Text(
                controller.isCurrentUserMember.value ? 'Exit Group' : 'Delete Group',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: ThemeColor.Red1,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      )),
    );
  }
  
  // Reusable card widget for consistent styling
  Widget _buildInfoCard({required List<Widget> children, EdgeInsets? padding}) {
    return Container(
      padding: padding,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}