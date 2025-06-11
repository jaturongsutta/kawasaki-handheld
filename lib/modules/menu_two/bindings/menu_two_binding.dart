import 'package:get/get.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';

class MenuTwoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuTwoController>(() => MenuTwoController());
  }
}
