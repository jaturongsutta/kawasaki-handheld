import 'package:get/get.dart';
import 'package:kmt/modules/line_stop_information/controllers/line_stop_information_controller.dart';

class LineStopInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LineStopInformationController>(() => LineStopInformationController());
  }
}
