import 'package:get/get.dart';
import 'package:kmt/modules/ng_information/services/ngService.dart';
import 'package:kmt/services/base_service.dart';
import '../controllers/ng_information_controller.dart';

class NgInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<NgInformationService>(
      () => NgInformationService(Get.find<BaseService>()),
    );
    Get.lazyPut<NgInformationController>(
      () => NgInformationController(Get.find<NgInformationService>()),
    );
  }
}
