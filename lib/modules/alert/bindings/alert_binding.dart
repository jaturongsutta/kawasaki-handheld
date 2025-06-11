import 'package:get/get.dart';
import 'package:kmt/modules/alert/controllers/alert_controller.dart';

class AlertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlertController>(() => AlertController());
  }
}
