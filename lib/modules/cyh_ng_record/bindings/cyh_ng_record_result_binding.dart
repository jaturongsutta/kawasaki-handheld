import 'package:get/get.dart';
import 'package:kmt/modules/cyh_ng_record/controllers/cyh_ng_record_result_controller.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_result_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHNGRecordResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHNGRecordResultService>(
      () => CYHNGRecordResultService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHNGRecordResultController>(
      () => CYHNGRecordResultController(Get.find<CYHNGRecordResultService>()),
    );
    Get.lazyPut<CYHNGRecordResultController>(() => CYHNGRecordResultController(Get.find()));
  }
}
