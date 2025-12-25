import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/routes/app_routes.dart';
import '../services/cyh_leak_test_service.dart';

class CYHLeakTestController extends GetxController {
  final CYHLeakTestService service;
  CYHLeakTestController(this.service);

  final isLoading = false.obs;
  final selectedWorkType = RxnString("Production");

  final isEnabled = false.obs;
  final workType = WorkTab.Production.obs;
  final selectedMachineNo = RxnString();
  final machines = <MachinePredefineModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  void checkIsEnabledButton() {
    isEnabled.value = (selectedWorkType.value ?? '').isNotEmpty &&
        selectedMachineNo.value!.isNotEmpty;
  }

  Future<void> _bootstrap() async {
    final box = GetStorage();
    final line = box.read('selectedLine')?.toString();
    await Future.wait([
      loadMachines(),
    ]);
  }

  Future<void> loadMachines() async {
    isLoading.value = true;
    try {
      final list = await service.fetchMachinesAll();
      machines.assignAll(list);
      if (machines.isNotEmpty) {
        selectedMachineNo.value = machines.first.value;
        checkIsEnabledButton();
      } else {
        selectedMachineNo.value = null;
      }
    } catch (_) {
      machines.clear();
      selectedMachineNo.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkTestResult() async {
    isLoading.value = true;
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final list =
          await service.checkTestResult(machineNo: selectedMachineNo.value);
      EasyLoading.dismiss();
      if (list.isNotEmpty) {
        if (list[0].testedStatus == 1) {
          Get.offAllNamed(AppRoutes.cyhLeakTestOK, arguments: {
            'workType': selectedWorkType.value,
            'machine': selectedMachineNo.value,
            'page-type': 'cyh-main'
          });
        } else {
          Get.offAllNamed(AppRoutes.cyhLeakTestNG, arguments: {
            'workType': selectedWorkType.value,
            'machine': selectedMachineNo.value,
            'page-type': 'cyh-main'
          });
        }
      } else {
        goToSerial();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> scanQrForMachine(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar('Invalid', 'QR ว่าง');
      return;
    }

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final target = norm(code);

    selectedMachineNo.value = target;
    checkIsEnabledButton();
    checkTestResult();
  }

  void goToSerial() async {
    if (selectedMachineNo.value!.isEmpty) {
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    final r = await service.fetchRunningList(
        machineNo: selectedMachineNo.value, workType: selectedWorkType.value);
    EasyLoading.dismiss();
    if (!r.ok) {
      EasyLoading.showInfo(r.message,
          duration: const Duration(seconds: 2), dismissOnTap: false);
      return;
    }

    Get.toNamed(AppRoutes.cyhLeakTestSerial, arguments: {
      'workType': selectedWorkType.value,
      'machine': selectedMachineNo.value,
      'running-list': r.data
    });
  }

  void confirmForm() async {
    try {
      if (isEnabled.value) {
        await checkTestResult();
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString());
    }
  }

  // String _fmtTime(String time4Digit) {
  //   if (time4Digit.length == 4) {
  //     return '${time4Digit.substring(0, 2)}:${time4Digit.substring(2, 4)}:00';
  //   }
  //   return '00:00:00';
  // }

  void resetForm() {
    // selectedMachineNo.value = null;
    // startDate.value = DateTime.now();
    // endDate.value = DateTime.now();
    // startTimeController.clear();
    // endTimeController.clear();
  }
}
