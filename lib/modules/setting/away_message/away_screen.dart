import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_gychat/routes/app_routes.dart';
import 'away_controller.dart';

class AwayScreen extends GetView<AwayController> {
  const AwayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Away Message',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _buildCard([_buildToggleSwitch()]),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isAwayEnabled.value) {
                  return _buildCard([
                    _buildScheduleTile(),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildMessageTile(),
                  ]);
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return ListTile(
      title: const Text('Send Away Message'),
      trailing: Obx(
        () => CupertinoSwitch(
          value: controller.isAwayEnabled.value,
          onChanged: (value) => controller.toggleAway(value),
          activeColor: const Color(0xFF3F51B5),
        ),
      ),
    );
  }
  
  // Halaman Schedule
  Widget _buildScheduleTile() {
    return ListTile(
      title: const Text('Schedule'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => Text(
            controller.scheduleOption.value == ScheduleOption.always 
              ? 'Always Send' 
              : 'Custom Schedule',
            style: const TextStyle(color: Colors.grey),
          )),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () => Get.toNamed(AppRoutes.Schedule),
    );
  }
  
  // onTap memanggil popup edit
  Widget _buildMessageTile() {
    return ListTile(
      title: const Text('Message'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => Text(
            controller.message.value,
            style: const TextStyle(color: Colors.grey),
          )),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      // Memanggil fungsi pop-up yang ada di controller
      onTap: () => controller.showMessageEditPopup(),
    );
  }
}

// Mengedit Message
class EditMessageScreen extends StatelessWidget {
  const EditMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AwayController controller = Get.find<AwayController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        title: const Text(
          'Edit Away Message',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              controller.message.value = controller.messageEditController.text;
              Get.back();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: controller.messageEditController,
              autofocus: true,
              maxLines: null,
              minLines: 5,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your message',
              ),
            ),
          ),
        ),
      ),
    );
  }
}