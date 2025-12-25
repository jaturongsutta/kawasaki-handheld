import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHLeakTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService(), fenix: true);

    Get.lazyPut<CYHLeakTestService>(
      () => CYHLeakTestService(Get.find<BaseService>()),
      fenix: true,
    );

    Get.lazyPut<CYHLeakTestController>(
      () => CYHLeakTestController(Get.find<CYHLeakTestService>()),
      fenix: true,
    );
  }
}
