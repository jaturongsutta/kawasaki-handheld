import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_serial_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_serial_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHLeakTestSerialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHLeakTestSerialService>(
      () => CYHLeakTestSerialService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHLeakTestSerialController>(
      () => CYHLeakTestSerialController(Get.find<CYHLeakTestSerialService>()),
    );
    Get.lazyPut<CYHLeakTestSerialController>(() => CYHLeakTestSerialController(Get.find()));
  }
}
