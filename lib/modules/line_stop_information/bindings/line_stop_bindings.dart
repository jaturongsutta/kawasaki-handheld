import 'package:get/get.dart';
import 'package:kmt/modules/line_stop_information/controllers/line_stop_information_controller.dart';
import 'package:kmt/modules/line_stop_information/services/line_stop_service.dart';
import 'package:kmt/services/base_service.dart';

class LineStopInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<LineStopInformationService>(
      () => LineStopInformationService(Get.find<BaseService>()),
    );
    Get.lazyPut<LineStopInformationController>(
      () => LineStopInformationController(Get.find<LineStopInformationService>()),
    );
  }
}
