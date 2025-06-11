import 'package:get/get.dart';
import '../controllers/production_status_manage_controller.dart';

class ProductionStatusManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductionStatusManageController>(() => ProductionStatusManageController());
  }
}
