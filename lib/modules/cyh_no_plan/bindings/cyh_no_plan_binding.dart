import 'package:get/get.dart';
import 'package:kmt/services/base_service.dart';
import '../controllers/cyh_no_plan_controller.dart';
import '../services/cyh_no_plan_service.dart';

class CYHNoPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHNoPlanService>(
      () => CYHNoPlanService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHNoPlanController>(
      () => CYHNoPlanController(Get.find<CYHNoPlanService>()),
    );
    Get.lazyPut<CYHNoPlanController>(() => CYHNoPlanController(Get.find()));
  }
}
