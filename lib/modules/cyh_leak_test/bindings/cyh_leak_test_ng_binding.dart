import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_ng_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_ng_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHLeakTestNGBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHLeakTestNGService>(
      () => CYHLeakTestNGService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHLeakTestNGController>(
      () => CYHLeakTestNGController(Get.find<CYHLeakTestNGService>()),
    );
    Get.lazyPut<CYHLeakTestNGController>(() => CYHLeakTestNGController(Get.find()));
  }
}
