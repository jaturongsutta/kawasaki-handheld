import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_ng_service.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHLeakTestNGController extends GetxController {
  final CYHLeakTestNGService service;
  CYHLeakTestNGController(this.service);

  final isLoading = false.obs;
  final isModelReadOnly = true.obs;
  final workTypeController = TextEditingController();

  final models = <LeakTestRunningModel>[].obs; // ถ้ามี list model
  final machineController = TextEditingController();
  final gsController = TextEditingController();
  final isEnabled = false.obs;
  final mcDateCtrls = List.generate(18, (_) => TextEditingController());
  final dataModel = Rxn<LeakTestNgModel>();

  final castingDateCtrls = List.generate(6, (_) => TextEditingController());
  final moldCtrls = List.generate(12, (_) => TextEditingController());

  final plantResultModel = Rxn<LeakTestRunningModel>();

  final selectedcastingDate = ''.obs;
  final selectedmoldCtrls = ''.obs;

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
    print("init => ");

    if (args != null) {
      final data = args['ng-result'];

      if (data is Map<String, dynamic>) {
        final model = LeakTestNgModel.fromJson(data);
        dataModel.value = model;
        print('model is => ${model.toJson()}');
      } else {
        print('❌ ng-result is not a Map, got: ${data.runtimeType}');
      }

      final plant = args['plant-result'];
      plantResultModel.value = plant;

      // workTypeController.text =
      // machineController.text = args['machine'] ?? '';
      // if (args['running-list'] != null) {
      //   final list = args['running-list'] as List<LeakTestRunningModel>;
      //   models.assignAll(list);
      // }

      // if (models.isNotEmpty) {
      //   selectedModel.value = models[0];
      // }

      // if (workTypeController.text == 'Production') {
      //   isModelReadOnly.value = true;
      // } else {
      //   isModelReadOnly.value = false;
      // }
    }
  }

  // Future<void> getGSCount() async {
  //   isLoading.value = true;
  //   try {
  //     final count = await service.fetchGSCount(
  //         modelCd: selectedModel.value?.modelCd,
  //         serialNo: selectedMCDate.value);
  //     gsController.text = count;
  //   } catch (_) {
  //     print("catch getGSCount ${_}");
  //     // selectedWorkType.value = null;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Color hexToColor(String hex) {
    // ลบ # ถ้ามี
    hex = hex.replaceAll('#', '');

    // ถ้ามีแค่ 6 ตัว (ไม่มี alpha) เติม FF ข้างหน้า (opacity 100%)
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    // แปลงเป็น int แล้วคืนค่า Color
    return Color(int.parse(hex, radix: 16));
  }

  void checkIsEnabledButton() {
    isEnabled.value =
        selectedmoldCtrls.isNotEmpty && selectedcastingDate.isNotEmpty;
  }

  void confirmForm() async {
    try {
      EasyLoading.show(
          status: 'กำลังบันทึก...', maskType: EasyLoadingMaskType.black);

      final box = GetStorage();
      final user = box.read('user');
      final updatedBy = user?['userId'] ?? '';

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final model = LeakTestModel(
        castingDate: selectedcastingDate.value,
        moldNo: selectedmoldCtrls.value,
        plantId: plantResultModel.value?.id ?? '',
        lineCd: box.read('selectedLine'),
        ngId: dataModel.value?.id ?? '',
        updatedBy: updatedBy,
        mappedPlanId: '',
        machineNo: '',
        workType: '',
        modelCd: '',
        serialNo: '',
        gsNo: '',
        scanDate: now,
        createdBy: updatedBy,
      );

      final res = await service.insertLeakTest(model);

      if (res['result'] == true) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        resetForm();
        Get.offAllNamed(AppRoutes.cyhLeakTest);
      } 
      else {
        EasyLoading.dismiss();
        EasyLoading.showInfo(res['message'] ?? 'บันทึกล้มเหลว',
            duration: const Duration(seconds: 2), dismissOnTap: false);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> scanAndFill(OcrMode mode) async {
    final result = await Get.to<String>(() => OcrView(mode: mode));
    if (result == null || result.isEmpty) return;

    List<TextEditingController> target;
    int cellCount;
    if (mode == OcrMode.castingDate6) {
      target = castingDateCtrls;
      cellCount = 6;
    } else {
      target = moldCtrls;
      cellCount = 12;
    }
    // switch (mode) {
    //   case OcrMode.castingDate6:
    //     target = castingDateCtrls;
    //     cellCount = 6;
    //     break;
    //   case OcrMode.mcDate18:
    //     // target = noCtrls;
    //     cellCount = 18;
    //     break;
    //   case OcrMode.no2:
    //     // target = noCtrls;
    //     cellCount = 2;
    //     break;
    //   case OcrMode.serial11:
    //     // target = serialCtrls;
    //     cellCount = 11;
    //     break;
    //   case OcrMode.mold4:
    //     target = moldCtrls;
    //     cellCount = 4;
    //     break;
    //   case OcrMode.machine5:
    //     // target = machineCtrls;
    //     cellCount = 5;
    //     break;
    // }

    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }
  }

  void clearCastingDate() => castingDateCtrls.forEach((c) => c.clear());
  void clearMold() => moldCtrls.forEach((c) => c.clear());

  void resetForm() {
    workTypeController.clear();
    machineController.clear();
    plantResultModel.value = null;
    mcDateCtrls.clear();
    gsController.clear();
  }
}
