import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/ng_init_data_model.dart';
import 'package:kmt/model/ng_production_model.dart';
import 'package:kmt/model/plan_search_model.dart';
import 'package:kmt/model/production_detail_model.dart';
import 'package:kmt/model/production_plan_model.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/modules/production_status_list/services/production_status_service.dart';
import 'package:kmt/services/inject.dart';
import 'package:stacked_services/stacked_services.dart';

class ProductionStatusController extends GetxController with GetSingleTickerProviderStateMixin {
  final ProductionStatusService service;
  ProductionStatusController(this.service);
  final dialogService = getIt<DialogService>();
  final LoginController loginController = Get.find<LoginController>();
  final planList = <ProductionPlanModel>[].obs;
  final plans = <PlanSearchModel>[].obs;
  late TabController tabController;
  final isLoading = false.obs;
  final step = ValueNotifier<int>(0);
  final otherStep = ValueNotifier<int>(0);
  final selectedDate = DateTime.now().obs;
  final selectedProcess = ''.obs;
  final totalRecords = 0.obs;
  final partNoController = TextEditingController(text: '1000203-09475');
  final partUpperController = TextEditingController(text: '1000003-00475');
  final partLowerController = TextEditingController(text: '1000013-08985');
  final ngDate = DateTime.now().obs;
  final ngTimeController = TextEditingController(
    text: DateFormat('HH:mm').format(DateTime.now()),
  );
  final quantityController = TextEditingController(text: '1');
  final commentController = TextEditingController();
  Rxn<NGProductionPlanModel> runningPlan = Rxn<NGProductionPlanModel>();
  Rxn<NgInitDataModel> initData = Rxn<NgInitDataModel>();
  final selectedPlanId = RxnInt();
  var reasonOptions = ['Blow Hole', 'Crack', 'Scratch', 'Other'];
  var selectedReason = ''.obs;
  Timer? _autoRefreshTimer;
  RxBool canEditOT = false.obs;
  RxInt otTimeMins = 0.obs;
  final isOTChecked = false.obs;
  final isOTSet = false.obs;
  final isOTCheckedOther = false.obs;
  final isOTSetOther = false.obs;
  Rxn<ProductionDetailModel> selectedPlanDetail = Rxn<ProductionDetailModel>();
  Rxn<ProductionDetailModel> selectedOtherPlanDetail = Rxn<ProductionDetailModel>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchTodayProductionPlan();
    searchOtherTab();
    tabController.addListener(_onTabChange);
  }

  void changeTab(int index) {
    tabController.animateTo(index);
  }

  void _onTabChange() {
    if (tabController.index == 0) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      fetchTodayProductionPlan();
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> fetchTodayProductionPlan() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      final lineCd = box.read('selectedLine');
      final data = await service.fetchTodayPlan(lineCd);
      planList.assignAll(data);
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'โหลดแผนล้มเหลว');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPlanDetail(int id) async {
    isLoading.value = true;
    try {
      final res = await service.fetchProductionDetail(id);
      if (res != null) {
        selectedPlanDetail.value = res;
        print('aaaaa===> ${res.ot}');
        isOTChecked.value = res.ot == 'Y';
        // isOTSet.value = planList.where((val) => val.id == id).first.ot == 'Y';
        step.value = 1;
      } else {
        Get.snackbar('Error', 'ไม่พบข้อมูล Plan');
      }
    } catch (e) {
      Get.snackbar('Error', 'โหลดข้อมูลไม่สำเร็จ');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> setOT() async {
    try {
      isLoading.value = true; // ✅ เริ่ม loading

      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';
      final isOT = isOTChecked.value;

      final plan = selectedPlanDetail.value;
      if (plan == null) return false;

      final otData = await service.fetchOTData(plan.id);
      if (otData == null) {
        dialogService.showDialog(
          title: 'ไม่สามารถแก้ไขได้',
          description: 'แผนนี้เลยเวลาที่กำหนดแล้ว ไม่สามารถอัปเดต OT ได้',
        );
        return false;
      }

      final timeMins = otData['Time_Mins'] ?? 0;

      final confirm = await dialogService.showConfirmationDialog(
        title: 'ยืนยันการอัปเดต OT',
        description: isOT ? "คุณต้องการเพิ่ม OT ใช่หรือไม่?" : "คุณต้องการลบ OT ใช่หรือไม่?",
      );

      if (confirm?.confirmed == true) {
        final newTotalTime = timeMins;

        final success = await service.updateOT(
          planId: plan.id,
          isOT: isOT,
          timeMins: newTotalTime,
          updatedBy: createdBy,
        );

        if (success) {
          EasyLoading.showSuccess('อัปเดต OT สำเร็จ');
          await loadPlanDetail(plan.id);
          await fetchTodayProductionPlan();
          return true;
        } else {
          EasyLoading.showError('เกิดข้อผิดพลาด');
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      EasyLoading.showError('เกิดข้อผิดพลาด');
      return false;
    } finally {
      isLoading.value = false; // ✅ หยุด loading ไม่ว่า success หรือ error
    }
  }

  Future<void> confirmStopPlan() async {
    try {
      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';
      final confirm = await dialogService.showConfirmationDialog(
        title: 'ยืนยันหยุดแผนผลิต',
        description: 'กรุณายืนยัน การหยุดแผนผลิตนี้',
        confirmationTitle: 'หยุด',
        cancelTitle: 'ยกเลิก',
      );

      if (confirm?.confirmed == true) {
        final success = await service.stopPlan(
          selectedPlanDetail.value!.id,
          createdBy,
        );

        if (success) {
          fetchTodayProductionPlan();

          EasyLoading.showSuccess('หยุดแผนผลิตสำเร็จ');
          step.value = 0;
          selectedPlanDetail.value = null;
        } else {
          EasyLoading.showError('หยุดแผนผลิตไม่สำเร็จ');
        }
      }
    } catch (e) {
      print('eeee===> $e');
      EasyLoading.showError('เกิดข้อผิดพลาด');
      return;
    }
  }

///////// Other //////////
  Future<void> searchOtherTab() async {
    isLoading.value = true;

    try {
      final box = GetStorage();
      final results = await service.fetchPlans(
        lineCd: box.read('selectedLine'),
        dateFrom: selectedDate.value,
        dateTo: selectedDate.value,
      );
      plans.assignAll(results);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOtherPlanDetail(int id) async {
    isLoading.value = true;
    try {
      final res = await service.fetchProductionDetail(id);
      if (res != null) {
        selectedOtherPlanDetail.value = res;
        isOTCheckedOther.value = res.ot == 'Y';
        // isOTSetOther.value = planList.where((val) => val.id == id).first.ot == 'Y';
        step.value = 2;
      } else {
        Get.snackbar('Error', 'ไม่พบข้อมูล Plan');
      }
    } catch (e) {
      Get.snackbar('Error', 'โหลดข้อมูลไม่สำเร็จ');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> setOTOther() async {
    try {
      isLoading.value = true; // ✅ เริ่ม loading

      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';
      final isOT = isOTCheckedOther.value;
      final plan = selectedOtherPlanDetail.value;
      if (plan == null) return false;

      final otData = await service.fetchOTData(plan.id);
      if (otData == null) {
        dialogService.showDialog(
          title: 'ไม่สามารถแก้ไขได้',
          description: 'แผนนี้เลยเวลาที่กำหนดแล้ว ไม่สามารถอัปเดต OT ได้',
        );
        return false;
      }

      final timeMins = otData['Time_Mins'] ?? 0;

      final confirm = await dialogService.showConfirmationDialog(
        title: 'ยืนยันการอัปเดต OT',
        description: isOT ? "คุณต้องการเพิ่ม OT ใช่หรือไม่?" : "คุณต้องการลบ OT ใช่หรือไม่?",
      );

      if (confirm?.confirmed == true) {
        final newTotalTime = timeMins;

        final success = await service.updateOT(
          planId: plan.id,
          isOT: isOT,
          timeMins: newTotalTime,
          updatedBy: createdBy,
        );

        if (success) {
          EasyLoading.showSuccess('อัปเดต OT สำเร็จ');
          await loadOtherPlanDetail(plan.id);
          await searchOtherTab();
          return true;
        } else {
          EasyLoading.showError('เกิดข้อผิดพลาด');
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      EasyLoading.showError('เกิดข้อผิดพลาด');
      return false;
    } finally {
      isLoading.value = false; // ✅ หยุด loading ไม่ว่า success หรือ error
    }
  }

  String formatPlanTime(String date, String time) {
    try {
      final d = DateTime.parse(date);
      final t = DateTime.parse(time);
      final combined = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      return DateFormat('dd/MM/yy HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    partNoController.dispose();
    partUpperController.dispose();
    partLowerController.dispose();
    ngTimeController.dispose();
    quantityController.dispose();
    commentController.dispose();
    tabController.dispose();

    // Reset observables
    planList.clear();
    plans.clear();
    step.value = 0;
    otherStep.value = 0;
    selectedDate.value = DateTime.now();
    selectedProcess.value = '';
    totalRecords.value = 0;
    ngDate.value = DateTime.now();
    runningPlan.value = null;
    initData.value = null;
    selectedPlanId.value = null;
    selectedReason.value = '';
    canEditOT.value = false;
    otTimeMins.value = 0;
    isOTChecked.value = false;
    isOTSet.value = false;
    isOTCheckedOther.value = false;
    isOTSetOther.value = false;
    selectedPlanDetail.value = null;
    selectedOtherPlanDetail.value = null;

    super.onClose();
  }
}
