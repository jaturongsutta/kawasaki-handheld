import 'package:get/get.dart';
import '../controllers/production_status_list_controller.dart';

class ProductionStatusListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductionStatusListController>(() => ProductionStatusListController());
  }
}
