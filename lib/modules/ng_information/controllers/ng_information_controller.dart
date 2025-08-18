import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/ng_historical_model.dart';
import 'package:kmt/model/ng_init_data_model.dart';
import 'package:kmt/model/ng_production_model.dart';
import 'package:kmt/model/ng_record_model.dart';
import 'package:kmt/model/ng_record_request.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';
import 'package:kmt/modules/ng_information/services/ngService.dart';

class NgInformationController extends GetxController with GetSingleTickerProviderStateMixin {
  final NgInformationService service;
  NgInformationController(this.service);
  final LoginController loginController = Get.find<LoginController>();
  final menuController = Get.find<MenuTwoController>();

  final ngRecordList = <NgRecordModel>[].obs;
  final historicalRecordList = <HistoricalRecordModel>[].obs;
  late TabController tabController;
  final isLoading = false.obs;
  final step = ValueNotifier<int>(0);
  final selectedDate = DateTime.now().obs;
  final selectedProcess = ''.obs;
  final totalRecords = 0.obs;
  final partNoController = TextEditingController(text: '1000203-09475');
  final partUpperController = TextEditingController(text: '1000003-00475');
  final partLowerController = TextEditingController(text: '1000013-08985');
  final ngDate = DateTime.now().obs;
  var tempTimeDefault = ''.obs;
  var timeDefault = ''.obs;
  final ngTimeController = TextEditingController(
    text: DateFormat('HH:mm').format(DateTime.now()),
  );
  final quantityController = TextEditingController(text: '1');
  final commentController = TextEditingController();
  Rxn<NGProductionPlanModel> runningPlan = Rxn<NGProductionPlanModel>();
  Rxn<NgInitDataModel> initData = Rxn<NgInitDataModel>();
  final box = GetStorage();
  var reasonOptions = ['Blow Hole', 'Crack', 'Scratch', 'Other'];
  var selectedReason = ''.obs;

  @override
  void onInit() {
    print('============ onInit ============');
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    loadNgInitialData();
    reloadHistoricalRecords();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
  }

  Future<void> loadNgInitialData() async {
    isLoading.value = true;
    try {
      final result = await service.fetchNgInitialData(box.read('selectedLine'));
      if (result != null) {
        initData.value = result;

        // ค่า Default
        final defaults = result.defaults;
        if (defaults != null) {
          ngDate.value = DateTime.parse(defaults.ngDate);
          ngTimeController.text = defaults.ngTime;
          timeDefault.value = defaults.ngTime;
          tempTimeDefault.value = defaults.ngTime;
          quantityController.text = defaults.quantity.toString();
        }
        print('######### ===>###### ');

        if (menuController.selectedNGTempReason.value.isNotEmpty ||
            menuController.selectedNGTempProcess.value.isNotEmpty) {
          final reasonLabel = initData.value!.reason
              .firstWhere(
                (ele) => ele.code == menuController.selectedNGTempReason.value,
              )
              .label;
          print('reasonLabel ===> $reasonLabel');

          selectedReason.value = reasonLabel;
          selectedProcess.value = menuController.selectedNGTempProcess.value;
        }
      } else {
        Get.snackbar('Error', 'ไม่พบข้อมูลเริ่มต้น');
      }
    } catch (e) {
      print('eeeee=== > $e');
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

    print('create by ===>$createdBy');

    final request = NgRecordRequest(
      planId: plan.id,
      lineCd: box.read('selectedLine'),
      processCd: selectedProcess.value,
      ngDate: DateFormat('yyyy-MM-dd').format(ngDate.value),
      ngTime: ngTimeController.text,
      quantity: int.tryParse(quantityController.text) ?? 0,
      reason: reason,
      comment: commentController.text,
      createdBy: createdBy,
    );

    try {
      final result = await service.saveNgRecord(request);
      if (result) {
        Get.snackbar('สำเร็จ', 'บันทึกข้อมูลสำเร็จ');

        // ✅ เปลี่ยนหน้าไปแสดงรายการหลังบันทึก
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

        // ✅ โหลดรายการข้อมูล NG Record
        final resRecordList = await service.fetchNgRecordList(box.read('selectedLine'), dateStr);
        ngRecordList.assignAll(resRecordList);
        // step.value = 1;
        reloadHistoricalRecords();
        resetFormToDefaults();
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
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final resRecordList = await service.fetchNgRecordList(box.read('selectedLine'), dateStr);
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

  void setRecordFromList(NgRecordModel record) {
    final oldInitData = initData.value;
    if (oldInitData == null) return;

    initData.value = NgInitDataModel(
      process: oldInitData.process,
      reason: oldInitData.reason,
      defaults: oldInitData.defaults,
      plan: NGProductionPlanModel(
        statusName: record.statusName,
        lineCd: record.lineCd,
        lineName: '-', // หรือดึงจากข้อมูลอื่น
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

  void resetFormToDefaults() {
    // ล้างตัวเลือก
    selectedProcess.value = '';
    selectedReason.value = '';
    timeDefault.value = tempTimeDefault.value;

    // ถ้ามี defaults จาก API ให้ใช้ก่อน
    final defaults = initData.value?.defaults;
    if (defaults != null) {
      try {
        ngDate.value = DateTime.parse(defaults.ngDate);
      } catch (_) {
        ngDate.value = DateTime.now();
      }
      ngTimeController.text = defaults.ngTime;
      quantityController.text = defaults.quantity.toString();
    } else {
      // ถ้าไม่มี defaults ให้ลองอิงจากแผน
      final plan = initData.value?.plan;
      if (plan != null) {
        try {
          ngDate.value = DateTime.parse(plan.planDate);
        } catch (_) {
          ngDate.value = DateTime.now();
        }
      } else {
        ngDate.value = DateTime.now();
      }
      ngTimeController.text = DateFormat('HH:mm').format(DateTime.now());
      quantityController.text = '1';
    }

    commentController.clear();
  }

  @override
  void onClose() {
    partNoController.dispose();
    partUpperController.dispose();
    partLowerController.dispose();
    ngTimeController.dispose();
    quantityController.dispose();
    commentController.dispose();
    tabController.dispose();

    // ❗️ปิด Rx และ Rxn
    step.dispose();
    selectedDate.close();
    selectedProcess.close();
    selectedReason.close();
    ngDate.close();
    isLoading.close();
    totalRecords.close();

    ngRecordList.close();
    historicalRecordList.close();
    initData.close();
    runningPlan.close();

    super.onClose();
  }
}
