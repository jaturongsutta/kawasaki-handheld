import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/line_stop_historical_model.dart';
import 'package:kmt/model/line_stop_init_data_model.dart';
import 'package:kmt/model/line_stop_production_model.dart';
import 'package:kmt/model/line_stop_record_model.dart';
import 'package:kmt/model/line_stop_record_request.dart';
import 'package:kmt/model/ng_production_model.dart';
import 'package:kmt/modules/line_stop_information/services/line_stop_service.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';

class LineStopInformationController extends GetxController with GetSingleTickerProviderStateMixin {
  final LineStopInformationService service;

  LineStopInformationController(this.service);
  final LoginController loginController = Get.find<LoginController>();
  final menuController = Get.find<MenuTwoController>();
  final ngRecordList = <LineStopRecordModel>[].obs;
  final historicalRecordList = <LineStopHistoricalRecordModel>[].obs;
  late TabController tabController;
  final isLoading = false.obs;
  final step = ValueNotifier<int>(0);
  final selectedDate = DateTime.now().obs;
  final selectedProcess = ''.obs;
  final totalRecords = 0.obs;
  final ngDate = DateTime.now().obs;
  final ngTimeController = TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
  final quantityController = TextEditingController(text: '1');
  final commentController = TextEditingController();
  Rxn<LineStopProductionPlanModel> runningPlan = Rxn<LineStopProductionPlanModel>();
  Rxn<LineStopInitDataModel> initData = Rxn<LineStopInitDataModel>();

  var selectedReason = ''.obs;
  var selectedTempReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    loadLineStopInitialData();
    reloadHistoricalRecords();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
  }

  Future<void> loadLineStopInitialData() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      final result = await service.fetchLineStopInitialData(box.read('selectedLine'));
      if (result != null) {
        initData.value = result;

        // ค่า Default
        final defaults = result.defaults;
        if (defaults != null) {
          ngDate.value = DateTime.parse(defaults.ngDate);
          ngTimeController.text = defaults.ngTime;
          quantityController.text = defaults.quantity.toString();
        }
        if (menuController.selectedLineTempReason.value.isNotEmpty ||
            menuController.selectedLineTempProcess.value.isNotEmpty) {
          final reasonLabel = initData.value!.reason
              .firstWhere(
                (ele) => ele.code == menuController.selectedLineTempReason.value,
              )
              .label;

          selectedReason.value = reasonLabel;
          selectedProcess.value = menuController.selectedLineTempProcess.value;
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
    final box = GetStorage();
    final user = box.read('user');
    final createdBy = user?['userId'] ?? '';

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
      lineCd: box.read('selectedLine'),
      processCd: selectedProcess.value,
      lineStopDate: DateFormat('yyyy-MM-dd').format(ngDate.value),
      lineStopTime: ngTimeController.text,
      lossTime: int.tryParse(quantityController.text) ?? 0,
      reason: reason,
      comment: commentController.text,
      createdBy: createdBy,
    );

    try {
      final result = await service.saveLineStopRecord(request);
      if (result) {
        Get.snackbar('สำเร็จ', 'บันทึกข้อมูลสำเร็จ');

        // ✅ เปลี่ยนหน้าไปแสดงรายการหลังบันทึก
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

        // ✅ โหลดรายการข้อมูล NG Record
        final resRecordList =
            await service.fetchLineStopRecordList(box.read('selectedLine'), dateStr);
        ngRecordList.assignAll(resRecordList);
        // step.value = 1;
        reloadHistoricalRecords();
        changeTab(1);
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
      final box = GetStorage();
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final resRecordList =
          await service.fetchLineStopRecordList(box.read('selectedLine'), dateStr);
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
      final box = GetStorage();
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      final res = await service.fetchHistoricalList(
        lineCd: box.read('selectedLine'),
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

  void setRecordFromList(LineStopRecordModel record) {
    final oldInitData = initData.value;
    if (oldInitData == null) return;

    initData.value = LineStopInitDataModel(
      process: oldInitData.process,
      reason: oldInitData.reason,
      defaults: oldInitData.defaults,
      plan: NGProductionPlanModel(
        statusName: record.statusName,
        lineCd: record.lineCd,
        lineName: '-',
        planDate: record.planDate,
        planStartTime: record.planStartTime,
        teamName: record.teamName,
        shiftPeriodName: record.shiftPeriodName,
        b1: record.b1,
        b2: record.b2,
        b3: record.b3,
        b4: record.b4,
        ot: record.ot,
        modelCd: record.modelCd,
        cycleTimes: record.cycleTimes,
        planTotalTime: record.planTotalTime,
        planFgAmt: record.planFgAmt,
        actualFgAmt: record.actualFgAmt ?? 0,
        status: record.status,
        id: record.id,
        partNo: record.partNo,
        part1: record.partUpper,
        part2: record.partLower ?? '',
      ),
    );
  }

  @override
  void onClose() {
    ngTimeController.dispose();
    quantityController.dispose();
    commentController.dispose();
    tabController.dispose();

    super.onClose();
  }
}
