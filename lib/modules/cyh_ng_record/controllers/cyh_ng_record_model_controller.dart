import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_model_service.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHNGRecordModelController extends GetxController {
  final CYHNGRecordModelService service;
  CYHNGRecordModelController(this.service);

  final isLoading = false.obs;
  final isModelReadOnly = true.obs;
  final workTypeController = TextEditingController();

  final selectedModel = Rxn<LeakTestNgModel>();
  final models = <LeakTestNgModel>[].obs; // ถ้ามี list model
  final machineController = TextEditingController();
  final gsController = TextEditingController();
  final isEnabled = false.obs;
  final mcDateCtrls = List.generate(18, (_) => TextEditingController());
  final selectedMCDate = ''.obs;

  final moldCtrls = List.generate(12, (_) => TextEditingController());
  final selectedmoldCtrls = ''.obs;

  final caNoCtrls = List.generate(3, (_) => TextEditingController());
  final selectedCANo = ''.obs;

  final caDateCtrls = List.generate(6, (_) => TextEditingController());
  final selectedCADate = ''.obs;

  final gsCheck = '0'.obs;
  final workType = WorkTab.Production.obs;
  late Worker _mcDateWorker;

  Future<void> scanAndFill(OcrMode mode) async {
    print('scan in ');
    final r = await Get.to<String>(() => OcrView(mode: mode));
    if (r == null || r.isEmpty) return;

    final result = r.replaceAll(RegExp(r'\s+'), '');

    List<TextEditingController> target = mcDateCtrls;
    int cellCount = 0;
    if (mode == OcrMode.mcDate18) {
      target = mcDateCtrls;
      cellCount = 18;

      selectedMCDate.value = result.toUpperCase();
      getGSCount();
      checkIsEnabledButton();
    } else {
      target = moldCtrls;
      cellCount = 12;
    }

    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }

    print("ToTal value => ${selectedMCDate.value}");
  }

  void initFormFromArgs() {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      machineController.text = args['machine'] ?? '';
      if (args['running-list'] != null) {
        final list = args['running-list'] as List<LeakTestNgModel>;
        models.assignAll(list);
      }

      workType.value = WorkTab.Master;
      if (args['workType'] == 'Production') {
        workType.value = WorkTab.Production;
      }

      if (models.isNotEmpty) {
        selectedModel.value = models[0];
      }

      if (workType.value == WorkTab.Production) {
        isModelReadOnly.value = true;
      } else {
        isModelReadOnly.value = false;
      }
    }
  }

  void checkGetGSCount() {
    _mcDateWorker = debounce<String>(
      selectedMCDate,
      (_) async {
        if (selectedMCDate.isNotEmpty) {
          await getGSCount();
        }
        checkIsEnabledButton();
      },
      time: const Duration(milliseconds: 400),
    );
  }

  Future<void> getGSCount() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

    try {
      final count = await service.fetchGSCount(
          modelCd: selectedModel.value?.modelCd,
          serialNo: selectedMCDate.value);
      gsController.text = count;
      gsCheck.value = count;
    } catch (_) {
      print("catch getGSCount ${_}");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  void checkIsEnabledButton() {
    isEnabled.value = selectedMCDate.value.trim().isNotEmpty;
    print("selectedMCDate => ${selectedMCDate.value.trim()}");
    print("isElable => ${isEnabled}");
  }

  void confirmForm() async {
    if (selectedMCDate.value.trim().isEmpty) {
      Get.snackbar('Warning', 'กรุณากรอก M/C Date ก่อน');
      return;
    }
    try {
      EasyLoading.show(
          status: 'กำลังบันทึก...', maskType: EasyLoadingMaskType.black);

      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final model = LeakTestModel(
        mappedPlanId: int.tryParse(selectedModel.value?.id ?? '') ?? 0,
        machineNo: machineController.text,
        workType: workTypeController.text,
        modelCd: selectedModel.value?.modelCd ?? '',
        serialNo: selectedMCDate.value,
        gsNo: gsController.text.isEmpty ? '0' : gsController.text,
        caNo: selectedCANo.value,
        caDate: selectedCADate.value,
        moldNo: selectedmoldCtrls.value,
        scanDate: now,
        createdBy: createdBy,
        plantId: 0,
        lineCd: '',
        ngId: '',
        updatedBy: createdBy,
      );

      final res = await service.insertLeakTest(model);

      if (res['result'] == true && res['type'] == 'OK') {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        Get.toNamed(AppRoutes.cyhLeakTestOK, arguments: {
          'ng-result': res['data'],
          'plant-result': selectedModel.value
        });
      } else if (res['result'] == true &&
          (res['data'] as Map<String, dynamic>).isNotEmpty) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        Get.toNamed(AppRoutes.cyhLeakTestNG, arguments: {
          'ng-result': res['data'],
          'plant-result': selectedModel.value
        });
      } else {
        EasyLoading.dismiss();
        EasyLoading.showInfo(res['message'] ?? 'บันทึกล้มเหลว',
            duration: const Duration(seconds: 2), dismissOnTap: false);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString());
    }
  }

  void clearMold() => moldCtrls.forEach((c) => c.clear());
  void clearMCDate() => mcDateCtrls.forEach((c) => c.clear());
  void clearCANo() => caNoCtrls.forEach((c) => c.clear());

  void clearCADate() {
    for (final c in caDateCtrls) {
      c.clear();
    }
    // ใส่ขีดใหม่ให้ช่องที่ 3 ด้วย
    if (caDateCtrls.length > 2) caDateCtrls[2].text = '-';
    selectedCADate.value = '';
  }

  void resetForm() {
    workTypeController.clear();
    machineController.clear();
    selectedModel.value = null;
    mcDateCtrls.clear();
    gsController.clear();
  }

  @override
  void onClose() {
    _mcDateWorker.dispose();
    super.onClose();
  }
}
