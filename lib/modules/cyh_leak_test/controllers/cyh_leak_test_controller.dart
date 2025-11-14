import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/model/machine_model.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/routes/app_routes.dart';
import '../services/cyh_leak_test_service.dart';

class CYHLeakTestController extends GetxController {
  final CYHLeakTestService service;
  CYHLeakTestController(this.service);

  final isLoading = false.obs;

  // final workTypeItems = <String>[].obs;
  final selectedWorkType = RxnString("Production");
  final machineController = TextEditingController();
  final isEnabled = false.obs;
  final workType = WorkTab.Production.obs;

  void checkIsEnabledButton() {
    isEnabled.value = (selectedWorkType.value ?? '').isNotEmpty &&
        machineController.text.trim().isNotEmpty;
  }

  Future<void> scanQrForMachine(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar('Invalid', 'QR ว่าง');
      return;
    }

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final target = norm(code);

    machineController.text = target;
    checkIsEnabledButton();
  }

  void goToSerial() async {
    if (machineController.text.trim().isEmpty) {
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    final r = await service.fetchRunningList(
        machineNo: machineController.text.trim(),
        workType: selectedWorkType.value);
    EasyLoading.dismiss();
    if (!r.ok) {
      EasyLoading.showInfo(r.message,
          duration: const Duration(seconds: 2), dismissOnTap: false);
      return;
    }

    Get.toNamed(AppRoutes.cyhLeakTestSerial, arguments: {
      'workType': selectedWorkType.value,
      'machine': machineController.text,
      'running-list': r.data
    });
  }

  void confirmForm() async {
    try {
      EasyLoading.show(
          status: 'กำลังบันทึก...', maskType: EasyLoadingMaskType.black);

      final box = GetStorage();
      final user = box.read('user');
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString());
    }
  }

  String _fmtTime(String time4Digit) {
    if (time4Digit.length == 4) {
      return '${time4Digit.substring(0, 2)}:${time4Digit.substring(2, 4)}:00';
    }
    return '00:00:00';
  }

  void resetForm() {
    // selectedMachineNo.value = null;
    // startDate.value = DateTime.now();
    // endDate.value = DateTime.now();
    // startTimeController.clear();
    // endTimeController.clear();
  }
}
