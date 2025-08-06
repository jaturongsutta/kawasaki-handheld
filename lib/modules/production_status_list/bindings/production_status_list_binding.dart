import 'package:get/get.dart';
import 'package:kmt/modules/production_status_list/services/production_status_service.dart';
import 'package:kmt/services/base_service.dart';
import '../controllers/production_status_list_controller.dart';

class ProductionStatusListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<ProductionStatusService>(
      () => ProductionStatusService(Get.find<BaseService>()),
    );
    Get.lazyPut<ProductionStatusController>(
      () => ProductionStatusController(Get.find<ProductionStatusService>()),
    );
  }
}
