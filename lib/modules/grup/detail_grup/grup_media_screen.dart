// lib/modules/grup/detail_grup/grup_media_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_grup_controller.dart';
import 'package:admin_gychat/shared/theme/colors.dart';

class GrupMediaScreen extends GetView<DetailGrupController> {
  const GrupMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: ThemeColor.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, 
            color: ThemeColor.black, 
            size: 22
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() { 
          return CupertinoSlidingSegmentedControl<int>(
            groupValue: controller.selectedMediaTabIndex.value,
            backgroundColor: ThemeColor.grey3,
            thumbColor: ThemeColor.white,
            onValueChanged: (int? newValue) {
              if (newValue != null) {
                controller.changeMediaTab(newValue);
              }
            },
            children: { 
              0: _buildSegment("Media"),
              1: _buildSegment("Links"),
              2: _buildSegment("Docs"),
            },
          );
        }),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement select functionality
            },
            child: const Text(
              'Select',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                color: ThemeColor.black, 
                fontSize: 20
              ),
            ),
          ),
        ],
      ),
      body: Obx(() { 
        switch (controller.selectedMediaTabIndex.value) {
          case 0: return _buildEmptyState('No Media');
          case 1: return _buildEmptyState('No Links');
          case 2: return _buildDocsList();
          default: return const Center(
            child: Text(
              'Select a tab'
            )
          );
        }
      }),
    );
  }

  Widget _buildSegment(String text) { 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          color: ThemeColor.black,
          fontSize: 14
        ),
      ),
    );
  }
  
  Widget _buildDocsList() {
    return Obx(() {
      if (controller.docsList.isEmpty) {
        return _buildEmptyState('No Documents');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.docsList.length,
        itemBuilder: (context, index) {
          final doc = controller.docsList[index];
          final isPdf = doc['type'] == 'pdf';
          return _buildDocListItem(
            icon: isPdf ? Icons.picture_as_pdf : Icons.description,
            iconColor: isPdf ? ThemeColor.red : ThemeColor.blue2,
            title: doc['name'],
          );
        },
      );
    });
  }

  // Widget untuk setiap item dalam daftar dokumen
  Widget _buildDocListItem({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ThemeColor.grey6, 
          width: 1
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 35),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal, 
            color: ThemeColor.black, 
            fontSize: 16
          ),
        ),
      ),
    );
  }
  
  // Widget untuk menampilkan state kosong
  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 18, color: ThemeColor.grey5),
      ),
    );
  }
}