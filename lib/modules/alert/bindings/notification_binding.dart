import 'package:get/get.dart';
import 'package:kmt/modules/alert/controllers/notification_controller.dart';

class AlertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
