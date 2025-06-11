import 'package:get/get.dart';
import '../controllers/ng_information_controller.dart';

class NgInformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NgInformationController>(() => NgInformationController());
  }
}
