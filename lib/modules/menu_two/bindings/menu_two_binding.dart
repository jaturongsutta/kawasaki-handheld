import 'package:get/get.dart';
import 'package:kmt/modules/line_stop_information/controllers/line_stop_information_controller.dart';
import 'package:kmt/modules/line_stop_information/services/line_stop_service.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';
import 'package:kmt/modules/ng_information/controllers/ng_information_controller.dart';
import 'package:kmt/modules/ng_information/services/ngService.dart';
import 'package:kmt/services/base_service.dart';

class MenuTwoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<MenuTwoController>(() => MenuTwoController());
    Get.lazyPut<LineStopInformationService>(
      () => LineStopInformationService(Get.find<BaseService>()),
    );
    Get.lazyPut<LineStopInformationController>(
      () => LineStopInformationController(Get.find<LineStopInformationService>()),
    );
    Get.lazyPut<NgInformationService>(
      () => NgInformationService(Get.find<BaseService>()),
    );
    Get.lazyPut<NgInformationController>(
      () => NgInformationController(Get.find<NgInformationService>()),
    );
  }
}
