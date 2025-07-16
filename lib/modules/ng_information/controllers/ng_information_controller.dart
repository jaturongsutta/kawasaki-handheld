import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/ng_historical_model.dart';
import 'package:kmt/model/ng_init_data_model.dart';
import 'package:kmt/model/ng_production_model.dart';
import 'package:kmt/model/ng_record_model.dart';
import 'package:kmt/model/ng_record_request.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/modules/ng_information/services/ngService.dart';

class NgInformationController extends GetxController {
  final NgInformationService service;
  NgInformationController(this.service);
  final LoginController loginController = Get.find<LoginController>();
  final ngRecordList = <NgRecordModel>[].obs;
  final historicalRecordList = <HistoricalRecordModel>[].obs;

  final isLoading = false.obs;
  final step = ValueNotifier<int>(0);
  final selectedDate = DateTime.now().obs;
  final selectedProcess = ''.obs;
  final totalRecords = 0.obs;
  final partNoController = TextEditingController(text: '1000203-09475');
  final partUpperController = TextEditingController(text: '1000003-00475');
  final partLowerController = TextEditingController(text: '1000013-08985');
  final ngDate = DateTime.now().obs;
  final ngTimeController = TextEditingController(text: '10:35');
  final quantityController = TextEditingController(text: '1');
  final commentController = TextEditingController();
  Rxn<NGProductionPlanModel> runningPlan = Rxn<NGProductionPlanModel>();
  Rxn<NgInitDataModel> initData = Rxn<NgInitDataModel>();

  var reasonOptions = ['Blow Hole', 'Crack', 'Scratch', 'Other'];
  var selectedReason = 'Blow Hole'.obs;

  @override
  void onInit() {
    super.onInit();
    loadNgInitialData(); // ✅ โหลดแผนเมื่อเปิดหน้า
    reloadHistoricalRecords(); // ✅ โหลดแผนเมื่อเปิดหน้า
  }

  Future<void> loadNgInitialData() async {
    isLoading.value = true;
    try {
      final result = await service.fetchNgInitialData(loginController.selectedLine.value);
      if (result != null) {
        initData.value = result;

        // ค่า Default
        final defaults = result.defaults;
        if (defaults != null) {
          ngDate.value = DateTime.parse(defaults.ngDate);
          ngTimeController.text = defaults.ngTime;
          quantityController.text = defaults.quantity.toString();
        }
      } else {
        Get.snackbar('Error', 'ไม่พบข้อมูลเริ่มต้น');
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่พบข้อมูลเริ่มต้น');
    } finally {
      isLoading.value = false;
    }
  }

  String get planDateDisplay {
    final planDateString = runningPlan.value?.planDate;
    if (planDateString != null && planDateString.isNotEmpty) {
      return planDateString;
    }
    return '-';
  }

  void save() async {
    final plan = initData.value?.plan;
    if (plan == null) {
      Get.snackbar('Error', 'ไม่มีข้อมูลแผนการผลิต');
      return;
    }
    isLoading.value = true;

    final reason = initData.value!.reason
        .firstWhere(
          (ele) => ele.label == selectedReason.value,
        )
        .code;

    final request = NgRecordRequest(
      planId: plan.id,
      lineCd: loginController.selectedLine.value,
      processCd: selectedProcess.value,
      ngDate: DateFormat('yyyy-MM-dd').format(ngDate.value),
      ngTime: ngTimeController.text,
      quantity: int.tryParse(quantityController.text) ?? 0,
      reason: reason,
      comment: commentController.text,
      createdBy: 1,
    );

    try {
      final result = await service.saveNgRecord(request);
      if (result) {
        Get.snackbar('สำเร็จ', 'บันทึกข้อมูลสำเร็จ');

        // ✅ เปลี่ยนหน้าไปแสดงรายการหลังบันทึก
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

        // ✅ โหลดรายการข้อมูล NG Record
        final resRecordList =
            await service.fetchNgRecordList(loginController.selectedLine.value, dateStr);
        ngRecordList.assignAll(resRecordList);
        step.value = 1;
      } else {
        Get.snackbar('ไม่สำเร็จ', 'บันทึกข้อมูลไม่สำเร็จ');
      }
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'ไม่สามารถบันทึกข้อมูลได้');
    } finally {
      isLoading.value = false;
    }
  }

  void updateDate(DateTime newDate) {
    selectedDate.value = newDate;
  }

  void reloadRecords() async {
    isLoading.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final resRecordList =
          await service.fetchNgRecordList(loginController.selectedLine.value, dateStr);
      ngRecordList.assignAll(resRecordList);
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'ไม่สามารถบันทึกข้อมูลได้');
    } finally {
      isLoading.value = false;
    }
  }

  void reloadHistoricalRecords() async {
    isLoading.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      final res = await service.fetchHistoricalList(
        lineCd: loginController.selectedLine.value,
        dateFrom: dateStr,
        dateTo: dateStr, // ใช้วันเดียวกันทั้ง dateFrom และ dateTo ในกรณีค้นหาวันเดียว
      );
      totalRecords.value = res['total'];
      historicalRecordList.assignAll(res['records']);
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'ไม่สามารถโหลดข้อมูล Historical ได้');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    partNoController.dispose();
    partUpperController.dispose();
    partLowerController.dispose();
    ngTimeController.dispose();
    quantityController.dispose();
    commentController.dispose();
    super.onClose();
  }
}
