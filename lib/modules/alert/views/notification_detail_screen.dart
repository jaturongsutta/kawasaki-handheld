import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/notification_model.dart';
import '../controllers/notification_controller.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final controller = Get.find<NotificationController>();
  bool isMarked = false;

  @override
  void initState() {
    super.initState();
    markAsReadIfNeeded();
  }

  Future<void> markAsReadIfNeeded() async {
    if (widget.notification.isReads != 'Y') {
      await controller.markAsRead(widget.notification.id);
      setState(() {
        isMarked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;

    return Scaffold(
      appBar: AppBar(title: const Text("Notification Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.header,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: notification.level == 'W'
                    ? Colors.green
                    : notification.level == 'A'
                        ? Colors.orange
                        : notification.level == 'D'
                            ? Colors.red
                            : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text('description : ${notification.title}'),
            const SizedBox(height: 12),
            Text(formatDate(notification.startDate)),
            // Text("End: ${formatDate(notification.endDate)}"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Back"),
                onPressed: () {
                  Get.back(result: true); // กลับไปพร้อมแจ้งว่ามีการเปลี่ยนแปลง
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yy').format(date);
    } catch (e) {
      return '-';
    }
  }
}
