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

  final isBreak1Checked = false.obs;
  final isBreak2Checked = false.obs;
  final isBreak3Checked = false.obs;
  final isBreak4Checked = false.obs;

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

      plan.ot = isOTChecked.value ? 'Y' : 'N';
      final data = {
        'Line_CD': plan.lineCd,
        'Plan_Start_DT': plan.startDT!.toIso8601String(),
        'Plan_Stop_DT': plan.endDT!.toIso8601String(),
        'B1': plan.b1,
        'B2': plan.b2,
        'B3': plan.b3,
        'B4': plan.b4,
        'OT': plan.ot,
        'Shift_Period': plan.shiftPeriod,
        'id': plan.id,
      };

      final otData = await service.fetchOTData(data);
      print('object===> $otData');
      if (otData.isNotEmpty) {
        dialogService.showDialog(
          title: 'ไม่สามารถแก้ไขได้',
          description: otData,
        );
        return false;
      }

      final confirm = await dialogService.showConfirmationDialog(
        title: 'ยืนยันการอัปเดต OT',
        description: isOT ? "คุณต้องการเพิ่ม OT ใช่หรือไม่?" : "คุณต้องการลบ OT ใช่หรือไม่?",
      );

      if (confirm?.confirmed == true) {
        final success = await service.updateOT(
          planId: plan.id,
          isOT: isOT,
          data: data,
          cycleTime: plan.cycleTime,
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
    } catch (e, s) {
      print('eee ==> $e');
      print('sss ==> $s');

      EasyLoading.showError('เกิดข้อผิดพลาด');
      return false;
    } finally {
      isLoading.value = false;
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

      plan.ot = isOTChecked.value ? 'Y' : 'N';
      final data = {
        'Line_CD': plan.lineCd,
        'Plan_Start_DT': plan.startDT!.toIso8601String(),
        'Plan_Stop_DT': plan.endDT!.toIso8601String(),
        'B1': plan.b1,
        'B2': plan.b2,
        'B3': plan.b3,
        'B4': plan.b4,
        'OT': plan.ot,
        'Shift_Period': plan.shiftPeriod,
        'id': plan.id,
      };
      final otData = await service.fetchOTData(data);
      if (otData.isNotEmpty) {
        dialogService.showDialog(
          title: 'ไม่สามารถแก้ไขได้',
          description: otData,
        );
        return false;
      }

      final confirm = await dialogService.showConfirmationDialog(
        title: 'ยืนยันการอัปเดต OT',
        description: isOT ? "คุณต้องการเพิ่ม OT ใช่หรือไม่?" : "คุณต้องการลบ OT ใช่หรือไม่?",
      );

      if (confirm?.confirmed == true) {
        final success = await service.updateOT(
          planId: plan.id,
          isOT: isOT,
          data: data,
          cycleTime: plan.cycleTime,
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

  void initBreaksFromModel(ProductionDetailModel m) {
    isBreak1Checked.value = m.b1 == 'Y';
    isBreak2Checked.value = m.b2 == 'Y';
    isBreak3Checked.value = m.b3 == 'Y';
    isBreak4Checked.value = m.b4 == 'Y';
  }

  Future<bool> setBreak(int breakNo) async {
    final plan = selectedPlanDetail.value;
    switch (breakNo) {
      case 1:
        plan!.b1 = isBreak1Checked.value ? 'Y' : 'N';

        break;
      case 2:
        plan!.b2 = isBreak2Checked.value ? 'Y' : 'N';

        break;
      case 3:
        plan!.b3 = isBreak3Checked.value ? 'Y' : 'N';

        break;
      case 4:
        plan!.b4 = isBreak4Checked.value ? 'Y' : 'N';

        break;
    }
    return true;
  }

  Future<bool> setBreakOther(int breakNo) async {
    final plan = selectedOtherPlanDetail.value;
    switch (breakNo) {
      case 1:
        plan!.b1 = isBreak1Checked.value ? 'Y' : 'N';

        break;
      case 2:
        plan!.b2 = isBreak2Checked.value ? 'Y' : 'N';

        break;
      case 3:
        plan!.b3 = isBreak3Checked.value ? 'Y' : 'N';

        break;
      case 4:
        plan!.b4 = isBreak4Checked.value ? 'Y' : 'N';

        break;
    }
    return true;
  }

  DateTime _combineDateAndTime(String planDateIso, String timeIso) {
    final date = DateTime.parse(planDateIso); // แปลงเป็น local
    final time = DateTime.parse(timeIso); // แปลงเป็น local

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
  }

  String _fmt(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    final d = dt.toLocal();
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
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
    isBreak1Checked.value = false;
    isBreak2Checked.value = false;
    isBreak3Checked.value = false;
    isBreak4Checked.value = false;
    super.onClose();
  }
}
