import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/line_stop_historical_model.dart';
import 'package:kmt/model/line_stop_init_data_model.dart';
import 'package:kmt/model/line_stop_production_model.dart';
import 'package:kmt/model/line_stop_record_model.dart';
import 'package:kmt/model/line_stop_record_request.dart';
import 'package:kmt/modules/line_stop_information/services/line_stop_service.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class LineStopInformationController extends GetxController {
  final LineStopInformationService service;

  LineStopInformationController(this.service);
  final LoginController loginController = Get.find<LoginController>();
  final ngRecordList = <LineStopRecordModel>[].obs;
  final historicalRecordList = <LineStopHistoricalRecordModel>[].obs;

  final isLoading = false.obs;
  final step = ValueNotifier<int>(0);
  final selectedDate = DateTime.now().obs;
  final selectedProcess = ''.obs;
  final totalRecords = 0.obs;
  final ngDate = DateTime.now().obs;
  final ngTimeController = TextEditingController(text: '10:35');
  final quantityController = TextEditingController(text: '1');
  final commentController = TextEditingController();
  Rxn<LineStopProductionPlanModel> runningPlan = Rxn<LineStopProductionPlanModel>();
  Rxn<LineStopInitDataModel> initData = Rxn<LineStopInitDataModel>();

  var selectedReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLineStopInitialData(); // ✅ โหลดแผนเมื่อเปิดหน้า
  }

  Future<void> loadLineStopInitialData() async {
    isLoading.value = true;
    try {
      final result = await service.fetchLineStopInitialData(loginController.selectedLine.value);
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

    final request = LineStopRecordRequest(
      planId: plan.id,
      lineCd: loginController.selectedLine.value,
      processCd: selectedProcess.value,
      lineStopDate: DateFormat('yyyy-MM-dd').format(ngDate.value),
      lineStopTime: ngTimeController.text,
      lossTime: int.tryParse(quantityController.text) ?? 0,
      reason: reason,
      comment: commentController.text,
      createdBy: 1,
    );

    try {
      final result = await service.saveLineStopRecord(request);
      if (result) {
        Get.snackbar('สำเร็จ', 'บันทึกข้อมูลสำเร็จ');

        // ✅ เปลี่ยนหน้าไปแสดงรายการหลังบันทึก
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

        // ✅ โหลดรายการข้อมูล NG Record
        final resRecordList =
            await service.fetchLineStopRecordList(loginController.selectedLine.value, dateStr);
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
          await service.fetchLineStopRecordList(loginController.selectedLine.value, dateStr);
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
    ngTimeController.dispose();
    quantityController.dispose();
    commentController.dispose();
    super.onClose();
  }
}
