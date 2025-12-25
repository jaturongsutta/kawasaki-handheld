import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_service.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHNGRecordController extends GetxController {
  final CYHNGRecordService service;
  CYHNGRecordController(this.service);
  final selectedMachineNo = RxnString();
  final isLoading = false.obs;

  // final machineController = TextEditingController();
  final isEnabled = false.obs;
  final workType = WorkTab.Production.obs;
  final machines = <MachinePredefineModel>[].obs;

  void checkIsEnabledButton() {
    isEnabled.value = selectedMachineNo.value!.isNotEmpty;
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      loadMachines(),
    ]);
  }

  Future<void> scanQrForMachine(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar('Invalid', 'QR ว่าง');
      return;
    }

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final target = norm(code);

    selectedMachineNo.value = target;
    await checkMachine();

    if (isEnabled.value) {
      goToModel();
    }
  }

  Future<void> loadMachines() async {
    isLoading.value = true;
    try {
      final list = await service.fetchMachinesAll();
      machines.assignAll(list);
      if (machines.isNotEmpty) {
        selectedMachineNo.value = machines.first.value;
        checkMachine();
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

  Future<void> checkMachine() async {
    isLoading.value = true;
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final list =
          await service.checkMachine(machineNo: selectedMachineNo.value);
      EasyLoading.dismiss();
      if (list.isNotEmpty) {
        checkIsEnabledButton();
      } else {
        isEnabled.value = false;
        EasyLoading.showError('Invalid Machine!',
            duration: const Duration(seconds: 2), dismissOnTap: false);
      }
    } catch (_) {
      EasyLoading.showError('Something went wrong.',
            duration: const Duration(seconds: 2), dismissOnTap: false);
    } finally {
      isLoading.value = false;
    }
  }

  void goToModel() async {
    if (selectedMachineNo.value!.isEmpty) {
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    final r = await service.fetchNGCYH(
      machineNo: selectedMachineNo.value,
    );
    EasyLoading.dismiss();
    if (!r.ok) {
      EasyLoading.showInfo(r.message,
          duration: const Duration(seconds: 2), dismissOnTap: false);
      return;
    }

    Get.toNamed(AppRoutes.cyhNGRecordModel, arguments: {
      'machine': selectedMachineNo.value,
      'running-list': r.data
    });
  }

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }
}
