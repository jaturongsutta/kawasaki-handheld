import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_ok_service.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHLeakTestOKController extends GetxController {
  final CYHLeakTestOKService service;
  CYHLeakTestOKController(this.service);

  final isLoading = false.obs;
  final isModelReadOnly = true.obs;
  final workTypeController = TextEditingController();

  final models = <LeakTestRunningModel>[].obs; // ถ้ามี list model
  final machineController = TextEditingController();
  final gsController = TextEditingController();
  final isEnabled = false.obs;

  final dataModel = Rxn<LeakTestNgModel>();

  final castingDateCtrls = List.generate(6, (_) => TextEditingController());
  final moldCtrls = List.generate(12, (_) => TextEditingController());

  final plantResultModel = Rxn<LeakTestRunningModel>();

  final mcDateCtrls = List.generate(18, (_) => TextEditingController());
  final selectedmoldCtrls = ''.obs;

  final caNoCtrls = List.generate(3, (_) => TextEditingController());
  final selectedCANo = ''.obs;

  final caDateCtrls = List.generate(6, (_) => TextEditingController());
  final selectedcastingDate = ''.obs;

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
      selectedCANo.value = dataModel.value?.caNo ?? '';
      selectedcastingDate.value = dataModel.value?.caDate ?? '';
      selectedmoldCtrls.value = dataModel.value?.moldNo ?? '';

      final plant = args['plant-result'];
      plantResultModel.value = plant;

      initTextField(dataModel.value?.caNo ?? '', caNoCtrls);
      initTextField(dataModel.value?.caDate ?? '', castingDateCtrls);
      initTextField(dataModel.value?.moldNo ?? '', moldCtrls);

      checkIsEnabledButton();
    }
  }

  void initTextField(String text, List<TextEditingController> widget) {
    final len = text.length;
    final max = widget.length;

    final limit = len < max ? len : max; // min(len, max)

    for (var i = 0; i < limit; i++) {
      widget[i].text = text[i];
    }

    for (var i = limit; i < max; i++) {
      widget[i].clear();
    }
  }

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
    isEnabled.value = selectedCANo.trim().isNotEmpty &&
        selectedmoldCtrls.trim().isNotEmpty &&
        selectedcastingDate.trim().isNotEmpty;
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
        caNo: selectedCANo.value,
        caDate: selectedcastingDate.value,
        moldNo: selectedmoldCtrls.value,
        plantId: plantResultModel.value?.id ?? 0,
        lineCd: box.read('selectedLine'),
        ngId: dataModel.value?.id ?? '',
        updatedBy: updatedBy,
        mappedPlanId: 0,
        machineNo: '',
        workType: '',
        modelCd: '',
        serialNo: '',
        gsNo: '',
        scanDate: now,
        createdBy: updatedBy,
      );

      final res = await service.updateLeakTestOK(model);

      if (res['result'] == true) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        resetForm();
        Get.offAllNamed(AppRoutes.cyhLeakTest);
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

  Future<void> scanAndFill(OcrMode mode) async {
    final r = await Get.to<String>(() => OcrView(mode: mode));
    if (r == null || r.isEmpty) return;

    final result = r.replaceAll(RegExp(r'\s+'), '');
    List<TextEditingController> target = moldCtrls;
    int cellCount = 12;
   
    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }
  }

  void clearCANo() => caNoCtrls.forEach((c) => c.clear());
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
