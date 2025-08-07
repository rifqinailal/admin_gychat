import 'package:admin_gychat/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinConfirmationDialog extends StatelessWidget {
  final int chatCount;

  const PinConfirmationDialog({super.key, required this.chatCount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/pin.png', height: 150),
                Text(
                  'Pin maksimal $chatCount obrolan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: ThemeColor.gray,
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            top: 20,  // Posisi di dalam batas atas
            right: 30, // Posisi di dalam batas kanan
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 24, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}