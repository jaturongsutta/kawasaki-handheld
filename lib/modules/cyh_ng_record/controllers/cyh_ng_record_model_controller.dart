import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_model_service.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHNGRecordModelController extends GetxController {
  final CYHNGRecordModelService service;
  CYHNGRecordModelController(this.service);

  final isLoading = false.obs;

  final selectedModel = Rxn<LeakTestNgModel>();
  final selectedSerial = Rxn<LeakTestNgModel>();
  final models = <LeakTestNgModel>[].obs; // ถ้ามี list model
  final machineController = TextEditingController();
  final gsController = TextEditingController();
  final isEnabled = false.obs;

  final gsCheck = '0'.obs;
  final workType = WorkTab.Production.obs;
  late Worker _mcDateWorker;

  Future<void> scanAndFill(OcrMode mode) async {
    print('scan in ');
    final r = await Get.to<String>(() => OcrView(mode: mode));
    if (r == null || r.isEmpty) return;

    final result = r.replaceAll(RegExp(r'\s+'), '');
  }

  void initFormFromArgs() {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      machineController.text = args['machine'] ?? '';
      if (args['running-list'] != null) {
        final list = args['running-list'] as List<LeakTestNgModel>;
        models.assignAll(list);
      }

      if (models.isNotEmpty) {
        selectedModel.value = models[0];
      }
    }
  }

  void checkIsEnabledButton() {
    isEnabled.value =
        selectedModel.value != null && selectedSerial.value != null;
    print("selectedModel => ${selectedModel.value != null}");
    print("selectedSerial => ${selectedSerial.value != null}");
    print("isElable => ${isEnabled.value}");
  }

  void confirmForm() async {
    if (selectedModel.value == null) {
      Get.snackbar('Warning', 'กรุณาเลือก Model ก่อน');
      return;
    }

    if (selectedSerial.value == null) {
      Get.snackbar('Warning', 'กรุณาเลือก M/C Date ก่อน');
      return;
    }

    try {
      Get.toNamed(AppRoutes.cyhLeakTestNG,
          arguments: {'ng-result': selectedSerial.value, 'page-type': 'cyh-ng'});
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString());
    }
  }

  void resetForm() {
    machineController.clear();
    selectedModel.value = null;
    gsController.clear();
  }

  @override
  void onClose() {
    _mcDateWorker.dispose();
    super.onClose();
  }
}
