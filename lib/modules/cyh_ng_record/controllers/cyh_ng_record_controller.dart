import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/modules/cyh_ng_record/services/cyh_ng_record_service.dart';
import 'package:kmt/routes/app_routes.dart';

class CYHNGRecordController extends GetxController {
  final CYHNGRecordService service;
  CYHNGRecordController(this.service);

  final isLoading = false.obs;

  final machineController = TextEditingController();
  final isEnabled = false.obs;
  final workType = WorkTab.Production.obs;

  void checkIsEnabledButton() {
    isEnabled.value = machineController.text.trim().isNotEmpty;
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

  void goToModel() async {
    if (machineController.text.trim().isEmpty) {
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    final r = await service.fetchNGCYH(
      machineNo: machineController.text.trim(),
    );
    EasyLoading.dismiss();
    if (!r.ok) {
      EasyLoading.showInfo(r.message,
          duration: const Duration(seconds: 2), dismissOnTap: false);
      return;
    }

    Get.toNamed(AppRoutes.cyhNGRecordModel, arguments: {
      'machine': machineController.text,
      'running-list': r.data
    });
  }
}
