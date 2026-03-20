import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_serial_controller.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_flow_log_service.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/routes/app_routes.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
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

  final scannerKey = GlobalKey<KeyenceScannerState>();

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      scannerKey.currentState?.initSensorReader();
    });
  }

  @override
  void onInit() {
    super.onInit();
    _log('onInit');
    _bootstrap();
  }

  CYHLeakTestFlowLogService get _flowLog {
    if (Get.isRegistered<CYHLeakTestFlowLogService>()) {
      return Get.find<CYHLeakTestFlowLogService>();
    }
    return Get.put(CYHLeakTestFlowLogService(), permanent: true);
  }

  void _log(String step, {Map<String, dynamic>? data}) {
    final payload = data == null ? '' : ' | $data';
    debugPrint('[CYHLeakTestController][$step]$payload');
    _flowLog.add('CYHLeakTestController', step, data: data);
  }

  void _logError(
    String step,
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? data,
  }) {
    final payload = data == null ? '' : ' | $data';
    debugPrint('[CYHLeakTestController][$step][ERROR] $error$payload');
    debugPrint(stackTrace.toString());
    _flowLog.addError('CYHLeakTestController', step, error, stackTrace,
        data: data);
  }

  void checkIsEnabledButton() {
    isEnabled.value = (selectedWorkType.value ?? '').isNotEmpty &&
        selectedMachineNo.value!.isNotEmpty;
  }

  Future<void> _bootstrap() async {
    final box = GetStorage();
    final line = box.read('selectedLine')?.toString();
    _log('_bootstrap.start', data: {'line': line});
    await Future.wait([
      loadMachines(),
    ]);
    _log('_bootstrap.end', data: {'machineCount': machines.length});
  }

  Future<void> checkMachine() async {
    isLoading.value = true;
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      _log('checkMachine.request', data: {
        'endpoint': '/leak/check-machine',
        'Machine_No': selectedMachineNo.value,
      });
      final list =
          await service.checkMachine(machineNo: selectedMachineNo.value);
      EasyLoading.dismiss();
      _log('checkMachine.response', data: {
        'count': list.length,
        'result': list.map((e) => e.toJson()).toList(),
      });
      if (list.isNotEmpty) {
        checkIsEnabledButton();
      } else {
        isEnabled.value = false;
        _log('checkMachine.invalid', data: {
          'Machine_No': selectedMachineNo.value,
        });
        EasyLoading.showError('Invalid Machine!',
            duration: const Duration(seconds: 2), dismissOnTap: false);
      }
    } catch (e, st) {
      _logError('checkMachine.catch', e, st, data: {
        'Machine_No': selectedMachineNo.value,
      });
      EasyLoading.showError('Something went wrong.',
          duration: const Duration(seconds: 2), dismissOnTap: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMachines() async {
    isLoading.value = true;
    try {
      _log('loadMachines.request', data: {
        'endpoint': '/leak/machine-all',
      });
      final list = await service.fetchMachinesAll();
      machines.assignAll(list);
      _log('loadMachines.response', data: {
        'count': machines.length,
        'result': machines.map((e) => e.toJson()).toList(),
      });
      if (machines.isNotEmpty) {
        selectedMachineNo.value = machines.first.value;
        checkMachine();
      } else {
        selectedMachineNo.value = null;
      }
    } catch (e, st) {
      _logError('loadMachines.catch', e, st);
      machines.clear();
      selectedMachineNo.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkTestResult() async {
    final machineNo = selectedMachineNo.value;
    final workType = selectedWorkType.value;
    _log('checkTestResult.trigger', data: {
      'machineNo': machineNo,
      'workType': workType,
    });
    _log('checkTestResult.start', data: {
      'machineNo': machineNo,
      'workType': workType,
    });

    isLoading.value = true;
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      _log('checkTestResult.request', data: {
        'endpoint': '/leak/check-test-result',
        'Machine_No': machineNo,
      });
      final list = await service.checkTestResult(machineNo: machineNo);
      EasyLoading.dismiss();
      _log('checkTestResult.response', data: {
        'resultCount': list.length,
        'testedStatus': list.isNotEmpty ? list[0].testedStatus : null,
      });
      if (list.isNotEmpty) {
        if (list[0].testedStatus == 1) {
          _log('checkTestResult.route', data: {
            'route': AppRoutes.cyhLeakTestOK,
            'workType': workType,
            'machine': machineNo,
          });
          Get.offNamed(AppRoutes.cyhLeakTestOK, arguments: {
            'workType': workType,
            'machine': machineNo,
            'page-type': 'cyh-main'
          });
        } else {
          _log('checkTestResult.route', data: {
            'route': AppRoutes.cyhLeakTestNG,
            'workType': workType,
            'machine': machineNo,
          });

          Get.offNamed(AppRoutes.cyhLeakTestNG, arguments: {
            'workType': workType,
            'machine': machineNo,
            'page-type': 'cyh-main'
          });
        }
      } else {
        _log('checkTestResult.next', data: {
          'action': 'goToSerial',
          'reason': 'empty-check-test-result',
        });
        await goToSerial(
            machineNoOverride: machineNo, workTypeOverride: workType);
      }
    } catch (e, st) {
      _logError('checkTestResult.catch', e, st, data: {
        'machineNo': machineNo,
        'workType': workType,
      });
    } finally {
      isLoading.value = false;
      _log('checkTestResult.end', data: {'isLoading': isLoading.value});
    }
  }

  Future<void> scanQrForMachine(String code) async {
    _log('scanQrForMachine.start', data: {'rawCode': code});
    if (code.trim().isEmpty) {
      Get.snackbar('Invalid', 'QR ว่าง');
      return;
    }

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final target = norm(code);

    MachinePredefineModel? matchedMachine;
    for (final machine in machines) {
      final value = machine.value;
      if (value != null && norm(value) == target) {
        matchedMachine = machine;
        break;
      }
    }

    if (matchedMachine?.value == null || matchedMachine!.value!.isEmpty) {
      _log('scanQrForMachine.notFoundInDropdown', data: {
        'rawCode': code,
        'normalized': target,
        'dropdownValues': machines.map((e) => e.value).toList(),
      });
      isEnabled.value = false;
      Get.snackbar('Invalid Machine', 'ไม่พบ Machine ในรายการ: $code');
      return;
    }

    selectedMachineNo.value = matchedMachine.value;
    _log('scanQrForMachine.normalized',
        data: {'targetMachine': matchedMachine.value});
    await checkMachine();

    if (isEnabled.value) {
      _log('scanQrForMachine.next', data: {'action': 'checkTestResult'});
      checkTestResult();
    }
  }

  Future<void> goToSerial(
      {String? machineNoOverride, String? workTypeOverride}) async {
    final machineNo = machineNoOverride ?? selectedMachineNo.value;
    final workType = workTypeOverride ?? selectedWorkType.value;

    _log('goToSerial.start', data: {
      'machineNo': machineNo,
      'workType': workType,
    });

    if (machineNo == null || machineNo.isEmpty) {
      _log('goToSerial.validationFail', data: {'reason': 'machine-empty'});
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      _log('goToSerial.request', data: {
        'endpoint': '/leak/production-list-running',
        'Machine_No': machineNo,
        'Work_Type': workType,
      });

      final r = await service.fetchRunningList(
          machineNo: machineNo, workType: workType);
      EasyLoading.dismiss();

      final runningCount = r.data?.length ?? 0;
      _log('goToSerial.response', data: {
        'ok': r.ok,
        'message': r.message,
        'runningCount': runningCount,
      });

      if (!r.ok) {
        _log('goToSerial.stop', data: {'reason': 'running-list-not-ok'});
        EasyLoading.showInfo(r.message,
            duration: const Duration(seconds: 2), dismissOnTap: false);
        return;
      }

      Get.delete<CYHLeakTestSerialController>(force: true);
      _log('goToSerial.route', data: {
        'route': AppRoutes.cyhLeakTestSerial,
        'workType': workType,
        'machine': machineNo,
        'runningCount': runningCount,
      });
      await Get.toNamed(AppRoutes.cyhLeakTestSerial, arguments: {
        'workType': workType,
        'machine': machineNo,
        'running-list': r.data
      });
      _log('goToSerial.returned', data: {
        'fromRoute': AppRoutes.cyhLeakTestSerial,
      });
      await Future.delayed(const Duration(milliseconds: 150));
      await scannerKey.currentState?.initSensorReader();
      _log('goToSerial.scannerReinitialized');
    } catch (e, st) {
      EasyLoading.dismiss();
      _logError('goToSerial.catch', e, st, data: {
        'machineNo': machineNo,
        'workType': workType,
      });
    }
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
