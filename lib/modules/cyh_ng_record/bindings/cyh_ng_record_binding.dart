import 'package:get/get.dart';
import 'package:kmt/modules/cyh_ng_record/controllers/cyh_ng_record_controller.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHNGRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHNGRecordService>(
      () => CYHNGRecordService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHNGRecordController>(
      () => CYHNGRecordController(Get.find<CYHNGRecordService>()),
    );
    Get.lazyPut<CYHNGRecordController>(() => CYHNGRecordController(Get.find()));
  }
}
