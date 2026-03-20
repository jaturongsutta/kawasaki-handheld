import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/capture/capture_view.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_flow_log_service.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_serial_service.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHLeakTestSerialController extends GetxController {
  final CYHLeakTestSerialService service;
  CYHLeakTestSerialController(this.service);

  final isLoading = false.obs;
  final isModelReadOnly = true.obs;

  final selectedModel = Rxn<LeakTestRunningModel>();
  final models = <LeakTestRunningModel>[].obs; // ถ้ามี list model
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
  final workTypeString = ''.obs;
  Worker? _mcDateWorker;

  CYHLeakTestFlowLogService get _flowLog {
    if (Get.isRegistered<CYHLeakTestFlowLogService>()) {
      return Get.find<CYHLeakTestFlowLogService>();
    }
    return Get.put(CYHLeakTestFlowLogService(), permanent: true);
  }

  void _log(String step, {Map<String, dynamic>? data}) {
    final payload = data == null ? '' : ' | $data';
    debugPrint('[CYHLeakTestSerialController][$step]$payload');
    _flowLog.add('CYHLeakTestSerialController', step, data: data);
  }

  Future<void> scanAndFillWithOCR() async {
    final r = await Get.to<String>(() => CaptureView.withConfig());
    if (r == null) return;

    final result = r.replaceAll(RegExp(r'\s+'), '');
    if (result.isEmpty) return;

    List<TextEditingController> target;
    int cellCount;

    target = mcDateCtrls;
    cellCount = 18;

    selectedMCDate.value = result.toUpperCase();
    getGSCount();
    checkGetLeakCYH();
    checkIsEnabledButton();

    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }

    print("OCR => $result");
  }

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
      checkGetLeakCYH();
      checkIsEnabledButton();
    } else {
      target = moldCtrls;
      cellCount = 12;
      selectedmoldCtrls.value = result.toUpperCase();
    }

    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }

    print("ToTal value => ${selectedMCDate.value}");
  }

  void initFormFromArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    _log('initFormFromArgs.start', data: {
      'hasArgs': args != null,
      'argKeys': args?.keys.toList(),
    });

    if (args != null) {
      machineController.text = args['machine'] ?? '';
      _log('initFormFromArgs.machineAssigned', data: {
        'machine': machineController.text,
      });

      if (args['running-list'] != null) {
        final list = args['running-list'] as List<LeakTestRunningModel>;
        models.assignAll(list);
        _log('initFormFromArgs.runningListAssigned', data: {
          'runningCount': list.length,
        });
      }

      workType.value = WorkTab.Master;
      workTypeString.value = args['workType'];
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

      _log('initFormFromArgs.end', data: {
        'workType': workType.value.name,
        'workTypeString': workTypeString.value,
        'modelCount': models.length,
        'selectedModel': selectedModel.value?.modelCd,
        'isModelReadOnly': isModelReadOnly.value,
      });
    } else {
      _log('initFormFromArgs.end', data: {'reason': 'args-null'});
    }
  }

  void checkGetGSCount() {
    _mcDateWorker?.dispose();
    _mcDateWorker = debounce<String>(
      selectedMCDate,
      (_) async {
        if (selectedMCDate.isNotEmpty) {
          checkGetLeakCYH();
          await getGSCount();
        }
        checkIsEnabledButton();
      },
      time: const Duration(milliseconds: 400),
    );
  }

  Future<void> checkGetLeakCYH() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

    try {
      final result = await service.getLeakCYH(
          modelCd: selectedModel.value?.modelCd,
          serialNo: selectedMCDate.value);
      if (result.isNotEmpty) {
        initTextField(pad3Int(result[0].castingNo ?? 0).toString(), caNoCtrls);
        initTextField(result[0].castingDate.toString(), caDateCtrls);
        initTextField(result[0].moldNo.toString(), moldCtrls);

        selectedCANo.value = pad3Int(result[0].castingNo ?? 0).toString();
        selectedCADate.value = result[0].castingDate.toString();
        selectedmoldCtrls.value = result[0].moldNo.toString();
      }
    } catch (_) {
      print("catch checkGetLeakCYH ${_}");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  String pad3Int(int value) {
    return value.toString().padLeft(3, '0');
  }

  void initTextField(String? text, List<TextEditingController> widget) {
    // เคสที่ต้องเคลียร์หมดเลย
    if (text == null || text.isEmpty || text == 'null') {
      for (var c in widget) c.clear();
      return;
    }

    final len = text.length;
    final max = widget.length;

    final limit = len < max ? len : max; // min(len, max)

    for (var i = 0; i < limit; i++) {
      widget[i].text = text[i];
    }

    // clear ช่องที่เหลือ
    for (var i = limit; i < max; i++) {
      widget[i].clear();
    }
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
        mappedPlanId:
            workType.value == WorkTab.Master ? null : selectedModel.value?.id,
        machineNo: machineController.text,
        workType: workTypeString.value,
        modelCd: selectedModel.value?.modelCd ?? '',
        serialNo: selectedMCDate.value,
        gsNo: gsController.text.isEmpty ? '0' : gsController.text,
        caNo: selectedCANo.value,
        caDate: selectedCADate.value,
        moldNo: selectedmoldCtrls.value,
        scanDate: now,
        createdBy: createdBy,
        planId: 0,
        lineCd: '',
        ngId: '',
        updatedBy: createdBy,
      );
      print("Model ${model.workType}");
      print("Model ${model.serialNo}");
      print("json model ${model.toJson()}");

      final res = await service.insertLeakTest(model);
      print("result is ${res}");
      print("res valuetype ${res['type']}");

      if (res['result'] == true && res['type'] == 'OK') {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        Get.offNamed(AppRoutes.cyhLeakTestOK, arguments: {
          'ng-result': res['data'],
          'page-type': 'cyh-leak',
          'machine': machineController.text
        });
      } else if (res['result'] == true && res['type'] == 'NG') {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        Get.offNamed(AppRoutes.cyhLeakTestNG, arguments: {
          'ng-result': res['data'],
          'page-type': 'cyh-leak',
          'machine': machineController.text
        });
      } else if (res['result'] == true && res['type'] == null) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        Get.delete<CYHLeakTestController>(force: true);
        Get.offAllNamed(AppRoutes.cyhLeakTest);
      } else {
        EasyLoading.dismiss();
        EasyLoading.showInfo('บันทึกล้มเหลว \n${res['message']}',
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
    machineController.clear();
    selectedModel.value = null;
    mcDateCtrls.clear();
    gsController.clear();
  }

  @override
  void onInit() {
    clearMCDate();
    clearCANo();
    clearCADate();
    clearMold();
    selectedMCDate.value = '';
    selectedCANo.value = '';
    selectedCADate.value = '';
    selectedmoldCtrls.value = '';
    super.onInit();
  }

  @override
  void onClose() {
    _mcDateWorker?.dispose();
    super.onClose();
  }
}
