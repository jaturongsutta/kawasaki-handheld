import 'package:get/get.dart';
import 'package:kmt/modules/cyh_ng_record/controllers/cyh_ng_record_model_controller.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_model_service.dart';
import 'package:kmt/services/base_service.dart';

class CYHNGRecordModelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseService>(() => BaseService());
    Get.lazyPut<CYHNGRecordModelService>(
      () => CYHNGRecordModelService(Get.find<BaseService>()),
    );
    Get.lazyPut<CYHNGRecordModelController>(
      () => CYHNGRecordModelController(Get.find<CYHNGRecordModelService>()),
    );
    Get.lazyPut<CYHNGRecordModelController>(
        () => CYHNGRecordModelController(Get.find()));
  }
}
