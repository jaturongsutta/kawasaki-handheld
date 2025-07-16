import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/alert/controllers/alert_controller.dart';

class AlertView extends GetView<AlertController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการแจ้งเตือน')),
      body: Obx(() {
        if (controller.alertHistory.isEmpty) {
          return const Center(child: Text('ยังไม่มีการแจ้งเตือน'));
        }
        return ListView.builder(
          itemCount: controller.alertHistory.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(controller.alertHistory[index]),
          ),
        );
      }),
    );
  }
}
