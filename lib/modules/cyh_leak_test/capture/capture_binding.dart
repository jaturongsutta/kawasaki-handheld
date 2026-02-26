import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/capture/ocr_menu_config.dart';

import 'capture_controller.dart';

class CaptureBinding extends Bindings {
  @override
  void dependencies() {
    final config = Get.arguments as OcrMenuConfig;
    Get.lazyPut<CaptureController>(() => CaptureController(config));
  }
}
