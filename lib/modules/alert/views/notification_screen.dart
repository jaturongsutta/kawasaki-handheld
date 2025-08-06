import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/modules/alert/views/notification_detail_screen.dart';
import '../controllers/notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() => Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.notifications_active, color: Colors.black),
                  ),
                  if (controller.notifications.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 9,
                        child: Text(
                          '${controller.unread}',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    )
                ],
              ))
        ],
      ),
      body: Obx(() => ListView.separated(
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final item = controller.notifications[index];
              return InkWell(
                onTap: () async {
                  final result = await Get.to(
                    () => NotificationDetailScreen(notification: item),
                  );
                  if (result == true) {
                    controller.loadNotifications(reset: true);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        item.header,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: item.level == 'W'
                              ? Colors.green
                              : item.level == 'A'
                                  ? Colors.orange
                                  : item.level == 'D'
                                      ? Colors.red
                                      : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // วันที่แจ้งเตือน
                      Text(
                        'Date: ${formatDate(item.startDate)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      // รายละเอียด
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => controller.loadMore(),
          child: const Text('View more'),
        ),
      ),
    );
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yy').format(date); // ✅ ปรับตามนี้
    } catch (e) {
      return '-';
    }
  }

  String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return '-';
    }
  }
}
