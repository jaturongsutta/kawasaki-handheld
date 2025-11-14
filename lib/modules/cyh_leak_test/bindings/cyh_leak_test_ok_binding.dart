import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_ok_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_ok_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHLeakTestOKBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHLeakTestOKService>(
      () => CYHLeakTestOKService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHLeakTestOKController>(
      () => CYHLeakTestOKController(Get.find<CYHLeakTestOKService>()),
    );
    Get.lazyPut<CYHLeakTestOKController>(() => CYHLeakTestOKController(Get.find()));
  }
}
