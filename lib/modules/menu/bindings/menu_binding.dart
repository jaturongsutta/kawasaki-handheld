import 'package:get/get.dart';
import 'package:kmt/modules/menu/controllers/menu_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuPageController>(() => MenuPageController());
  }
}
