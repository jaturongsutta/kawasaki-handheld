import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHLeakTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHLeakTestService>(
      () => CYHLeakTestService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHLeakTestController>(
      () => CYHLeakTestController(Get.find<CYHLeakTestService>()),
    );
    Get.lazyPut<CYHLeakTestController>(() => CYHLeakTestController(Get.find()));
  }
}
