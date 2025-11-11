import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_serial_service.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHLeakTestSerialController extends GetxController {
  final CYHLeakTestSerialService service;
  CYHLeakTestSerialController(this.service);

  final isLoading = false.obs;
  final isModelReadOnly = true.obs;
  final workTypeController = TextEditingController();

  final selectedModel = Rxn<LeakTestRunningModel>();
  final models = <LeakTestRunningModel>[].obs; // ถ้ามี list model
  final machineController = TextEditingController();
  final gsController = TextEditingController();
  final isEnabled = false.obs;
  final mcDateCtrls = List.generate(18, (_) => TextEditingController());
  final selectedMCDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final box = GetStorage();
    final line = box.read('selectedLine')?.toString();
    await Future.wait([
      // loadMachines(lineCd: line),
    ]);
  }

  Future<void> scanAndFill(OcrMode mode) async {
    print('scan in ');
    final result = await Get.to<String>(() => OcrView(mode: mode));
    if (result == null || result.isEmpty) return;

    List<TextEditingController> target = mcDateCtrls;
    int cellCount = 0;
    if (mode == OcrMode.mcDate18) {
      target = mcDateCtrls;
      cellCount = 18;
    }

    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }

    selectedMCDate.value = result.toUpperCase();
    getGSCount();
    checkIsEnabledButton();
    print("ToTal value => ${selectedMCDate.value}");
  }

  void clearMCDate() => mcDateCtrls.forEach((c) => c.clear());

  void openFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Text('Filter (กำหนดเองภายหลัง)'),
      ),
    );
  }

  Future<void> scanQrForMachine(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar('Invalid', 'QR ว่าง');
      return;
    }

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final target = norm(code);

    // if (machines.isEmpty) {
    //   final line = Get.find<GetStorage>().read('selectedLine')?.toString();
    //   // await loadMachines(lineCd: line);
    // }

    // final found = machines.firstWhereOrNull(
    //   (m) => norm(m.machineNo) == target,
    // );

    // if (found != null) {
    //   selectedMachineNo.value = found.machineNo;
    //   Get.snackbar('Selected', 'Machine: ${found.machineNo}', snackPosition: SnackPosition.BOTTOM);
    // } else {
    //   final fuzzy = machines.firstWhereOrNull(
    //     (m) => norm(m.machineNo).contains(target),
    //   );

    //   if (fuzzy != null) {
    //     selectedMachineNo.value = fuzzy.machineNo;
    //     Get.snackbar('Selected (≈)', 'Machine: ${fuzzy.machineNo}',
    //         snackPosition: SnackPosition.BOTTOM);
    //   } else {
    //     Get.snackbar('Not found', 'ไม่พบเครื่องที่ตรงกับ: $code',
    //         snackPosition: SnackPosition.BOTTOM);
    //   }
    // }
  }

  void initFormFromArgs() {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      workTypeController.text = args['workType'] ?? '';
      machineController.text = args['machine'] ?? '';
      if (args['running-list'] != null) {
        final list = args['running-list'] as List<LeakTestRunningModel>;
        models.assignAll(list);
      }

      if (models.isNotEmpty) {
        selectedModel.value = models[0];
      }

      if (workTypeController.text == 'Production') {
        isModelReadOnly.value = true;
      } else {
        isModelReadOnly.value = false;
      }
    }
  }

  Future<void> getGSCount() async {
    isLoading.value = true;
    try {
      final count = await service.fetchGSCount(
          modelCd: selectedModel.value?.modelCd,
          serialNo: selectedMCDate.value);
      gsController.text = count;
    } catch (_) {
      print("catch getGSCount ${_}");
      // selectedWorkType.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void checkIsEnabledButton() {
    isEnabled.value = mcDateCtrls.isNotEmpty;
  }

  void confirmForm() async {
    try {
      EasyLoading.show(
          status: 'กำลังบันทึก...', maskType: EasyLoadingMaskType.black);

      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final model = LeakTestModel(
        mappedPlanId: selectedModel.value?.id ?? '',
        machineNo: machineController.text,
        workType: workTypeController.text,
        modelCd: selectedModel.value?.modelCd ?? '',
        serialNo: selectedMCDate.value,
        gsNo: gsController.text,
        scanDate: now,
        createdBy: createdBy,
      );

      final res = await service.insertLeakTest(model);

      if (res['result'] == true && (res['data'] as List).isEmpty) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        resetForm();
        Get.offAllNamed(AppRoutes.cyhLeakTest);
      } else if (res['result'] == true && (res['data'] as List).isNotEmpty) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        Get.toNamed(AppRoutes.cyhLeakTestNG, arguments: {
          // 'workType': selectedWorkType.value,
          // 'machine': machineController.text,
          // 'running-list': r.data
        });
      } else {
        EasyLoading.dismiss();
        EasyLoading.showInfo(res['message'] ?? 'บันทึกล้มเหลว',
            duration: const Duration(seconds: 2), dismissOnTap: false);
        // Get.snackbar('Error', res['message'] ?? 'บันทึกล้มเหลว');
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString());
    }
  }

  void resetForm() {
    workTypeController.clear();
    machineController.clear();
    selectedModel.value = null;
    mcDateCtrls.clear();
    gsController.clear();
  }
}
