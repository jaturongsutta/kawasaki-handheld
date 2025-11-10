import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/model/machine_model.dart';
import 'package:kmt/routes/app_routes.dart';
import '../services/cyh_leak_test_service.dart';

class CYHLeakTestSerialController extends GetxController {
  final CYHLeakTestService service;
  CYHLeakTestSerialController(this.service);

  final isLoading = false.obs;
  final isModelReadOnly = true.obs;
  // final machines = <MachineModel>[].obs;
  // final selectedMachineNo = RxnString();
  // final startDate = Rx<DateTime>(DateTime.now());
  // final endDate = Rx<DateTime>(DateTime.now());
  // final startTime = Rx<TimeOfDay>(const TimeOfDay(hour: 8, minute: 0));
  // final endTime = Rx<TimeOfDay>(const TimeOfDay(hour: 17, minute: 0));
  // final startTimeController =
  //     TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
  // final endTimeController =
  //     TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

  // final selectedWorkType = RxnString();
  final workTypeController = TextEditingController();

  final selectedModel = Rxn<LeakTestRunningModel>();
  final models = <LeakTestRunningModel>[].obs; // ถ้ามี list model
  final machineController = TextEditingController();
  final gsController =
      TextEditingController(); // ค่าเริ่มต้นถ้าต้องการ: TextEditingController(text: '1')

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

  // Future<void> loadMachines({required String? lineCd}) async {
  //   isLoading.value = true;
  //   try {
  //     final list = await service.fetchMachines(lineCd: lineCd);
  //     machines.assignAll(list);
  //     if (machines.isNotEmpty) {
  //       selectedMachineNo.value = machines.first.machineNo;
  //     } else {
  //       selectedMachineNo.value = null;
  //     }
  //   } catch (_) {
  //     machines.clear();
  //     selectedMachineNo.value = null;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
      }
      else {
          isModelReadOnly.value = false;
      }
    }
  }

  // Future<void> pickStartDate(BuildContext ctx) async {
  //   final d = await showDatePicker(
  //     context: ctx,
  //     initialDate: startDate.value,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (d != null) startDate.value = d;
  // }

  // Future<void> pickEndDate(BuildContext ctx) async {
  //   final d = await showDatePicker(
  //     context: ctx,
  //     initialDate: endDate.value,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (d != null) endDate.value = d;
  // }

  // Future<void> pickStartTime(BuildContext ctx) async {
  //   final t = await showTimePicker(context: ctx, initialTime: startTime.value);
  //   if (t != null) startTime.value = t;
  // }

  // Future<void> pickEndTime(BuildContext ctx) async {
  //   final t = await showTimePicker(context: ctx, initialTime: endTime.value);
  //   if (t != null) endTime.value = t;
  // }

  void goToSerial() {
    if (machineController.text.trim().isEmpty) {
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }
    // Get.toNamed(AppRoutes.cyhLeakTestSerial, arguments: {
    //   'machineNo': selectedMachineNo.value,
    //   'startDate': startDate.value,
    //   'endDate': endDate.value,
    //   'startTime': startTime.value,
    //   'endTime': endTime.value,
    // });
  }

  void goToNG() {
    // if (machineController.text.trim().isEmpty) {
    //   Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
    //   return;
    // }
    // Get.toNamed(AppRoutes.cyhLeakTestNG, arguments: {
    //   'machineNo': selectedMachineNo.value,
    //   'startDate': startDate.value,
    //   'endDate': endDate.value,
    //   'startTime': startTime.value,
    //   'endTime': endTime.value,
    // });
  }

  // void goToForm() {
  //   if (selectedMachineNo.value == null || selectedMachineNo.value!.isEmpty) {
  //     Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
  //     return;
  //   }
  //   Get.toNamed(AppRoutes.cyhNoPlanForm, arguments: {
  //     'machineNo': selectedMachineNo.value,
  //     'startDate': startDate.value,
  //     'endDate': endDate.value,
  //     'startTime': startTime.value,
  //     'endTime': endTime.value,
  //   });
  // }

  void confirmForm() async {
    try {
      EasyLoading.show(
          status: 'กำลังบันทึก...', maskType: EasyLoadingMaskType.black);

      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';
      // final startTimeStr = startTimeController.text;
      // final endTimeStr = endTimeController.text;

      // if (startTimeStr.isEmpty || endTimeStr.isEmpty) {
      //   EasyLoading.dismiss();
      //   Get.snackbar('Error', 'กรุณากรอกเวลาให้ครบ');
      //   return;
      // }

      // final startDateStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      // final endDateStr = DateFormat('yyyy-MM-dd').format(endDate.value);

      // final startDT = DateTime.parse('$startDateStr ${_fmtTime(startTimeStr)}');
      // final endDT = DateTime.parse('$endDateStr ${_fmtTime(endTimeStr)}');
      // final diffMinutes = endDT.difference(startDT).inMinutes.toDouble();
      // if (endDT.isBefore(startDT)) {
      //   EasyLoading.dismiss();
      //   Get.snackbar('Error', 'เวลา End ต้องมากกว่า Start');
      //   return;
      // }
      // final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      // final model = LeakNoPlanModel(
      //   id: 0,
      //   machineNo: selectedMachineNo.value ?? '',
      //   startDate: startDateStr,
      //   startTime: startTimeStr,
      //   endDate: endDateStr,
      //   endTime: endTimeStr,
      //   lossTime: diffMinutes,
      //   createdDate: now,
      //   createdBy: createdBy,
      //   updatedDate: now,
      //   updatedBy: createdBy,
      // );

      // final res = await service.insertLeakNoPlan(model);

      // if (res['result'] == true) {
      //   EasyLoading.showSuccess('บันทึกสำเร็จ',
      //       duration: const Duration(seconds: 1), dismissOnTap: false);

      //   await Future.delayed(const Duration(seconds: 1));
      //   resetForm();
      //   Get.offAllNamed(AppRoutes.cyhNoPlan);
      // } else {
      //   EasyLoading.dismiss();
      //   Get.snackbar('Error', res['message'] ?? 'บันทึกล้มเหลว');
      // }
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
