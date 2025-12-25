import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_history_item_model.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/routes/app_routes.dart';
import '../services/cyh_no_plan_service.dart';

class CYHNoPlanController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CYHNoPlanService service;
  CYHNoPlanController(this.service);

  final isEnabled = false.obs;
  final isLoading = false.obs;
  final machines = <MachinePredefineModel>[].obs;
  final selectedMachineNo = RxnString();
  final startDate = Rx<DateTime>(DateTime.now());
  final endDate = Rx<DateTime>(DateTime.now());
  final startTime = Rx<TimeOfDay>(const TimeOfDay(hour: 8, minute: 0));
  final endTime = Rx<TimeOfDay>(const TimeOfDay(hour: 17, minute: 0));
  final startTimeController =
      TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
  final endTimeController =
      TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
  late TabController tabController;

  final historyDate = Rx<DateTime>(DateTime.now());
  final historyItems = <LeakHistoryItemModel>[].obs;
  final historyTotalLoss = 0.0.obs;
  final isHistoryLoading = false.obs;
  final isHistoryLoadingMore = false.obs;
  final historyHasMore = true.obs;
  final historyPage = 1.obs;
  final int historyPageSize = 10;

  late final ScrollController historyScrollController;

  String get currentLineCd {
    final box = GetStorage();
    return box.read('selectedLine')?.toString() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    historyScrollController = ScrollController();
    historyScrollController.addListener(_onHistoryScroll);

    _bootstrap();
    loadHistoricalInitial();
  }

  @override
  void onClose() {
    historyScrollController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
  }

  Future<void> loadHistoricalInitial() async {
    historyPage.value = 1;
    historyHasMore.value = true;
    historyItems.clear();
    await _fetchHistorical(page: 1, clear: true);
  }

  Future<void> loadHistoricalMore() async {
    if (isHistoryLoading.value ||
        isHistoryLoadingMore.value ||
        !historyHasMore.value) {
      return;
    }
    final nextPage = historyPage.value + 1;
    await _fetchHistorical(page: nextPage);
  }

  Future<void> _bootstrap() async {
    final box = GetStorage();
    final line = box.read('selectedLine')?.toString();
    await Future.wait([
      loadMachines(lineCd: line),
    ]);
  }

  Future<void> loadMachines({required String? lineCd}) async {
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

  void checkIsEnabledButton() {
    isEnabled.value = selectedMachineNo.value!.isNotEmpty;
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

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final target = norm(code);

    selectedMachineNo.value = target;
    await checkMachine();

    if (isEnabled.value) {
      goToForm();
    }

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
      selectedMachineNo.value = args['machineNo'] as String?;
      if (args['startDate'] is DateTime) startDate.value = args['startDate'];
      if (args['endDate'] is DateTime) endDate.value = args['endDate'];
      if (args['startTime'] is TimeOfDay) startTime.value = args['startTime'];
      if (args['endTime'] is TimeOfDay) endTime.value = args['endTime'];
    }
  }

  Future<void> pickStartDate(BuildContext ctx) async {
    final d = await showDatePicker(
      context: ctx,
      initialDate: startDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) startDate.value = d;
  }

  Future<void> pickEndDate(BuildContext ctx) async {
    final d = await showDatePicker(
      context: ctx,
      initialDate: endDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) endDate.value = d;
  }

  Future<void> pickStartTime(BuildContext ctx) async {
    final t = await showTimePicker(context: ctx, initialTime: startTime.value);
    if (t != null) startTime.value = t;
  }

  Future<void> pickEndTime(BuildContext ctx) async {
    final t = await showTimePicker(context: ctx, initialTime: endTime.value);
    if (t != null) endTime.value = t;
  }

  void goToForm() {
    if (selectedMachineNo.value == null || selectedMachineNo.value!.isEmpty) {
      Get.snackbar('Warning', 'กรุณาเลือก Machine ก่อน');
      return;
    }
    Get.toNamed(AppRoutes.cyhNoPlanForm, arguments: {
      'machineNo': selectedMachineNo.value,
      'startDate': startDate.value,
      'endDate': endDate.value,
      'startTime': startTime.value,
      'endTime': endTime.value,
    });
  }

  void confirmForm() async {
    try {
      EasyLoading.show(
          status: 'กำลังบันทึก...', maskType: EasyLoadingMaskType.black);

      final box = GetStorage();
      final user = box.read('user');
      final createdBy = user?['userId'] ?? '';
      final startTimeStr = startTimeController.text;
      final endTimeStr = endTimeController.text;

      if (startTimeStr.isEmpty || endTimeStr.isEmpty) {
        EasyLoading.dismiss();
        Get.snackbar('Error', 'กรุณากรอกเวลาให้ครบ');
        return;
      }

      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate.value);

      final startDT = DateTime.parse('$startDateStr ${_fmtTime(startTimeStr)}');
      final endDT = DateTime.parse('$endDateStr ${_fmtTime(endTimeStr)}');
      final diffMinutes = endDT.difference(startDT).inMinutes.toDouble();
      if (endDT.isBefore(startDT)) {
        EasyLoading.dismiss();
        Get.snackbar('Error', 'เวลา End ต้องมากกว่า Start');
        return;
      }
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final model = LeakNoPlanModel(
        id: 0,
        machineNo: selectedMachineNo.value ?? '',
        startDate: startDateStr,
        startTime: startTimeStr,
        endDate: endDateStr,
        endTime: endTimeStr,
        lossTime: diffMinutes,
        createdDate: now,
        createdBy: createdBy,
        updatedDate: now,
        updatedBy: createdBy,
      );

      final res = await service.insertLeakNoPlan(model);

      if (res['result'] == true) {
        EasyLoading.showSuccess('บันทึกสำเร็จ',
            duration: const Duration(seconds: 1), dismissOnTap: false);

        await Future.delayed(const Duration(seconds: 1));
        resetForm();
        Get.offAllNamed(AppRoutes.cyhNoPlan);
      } else {
        EasyLoading.dismiss();
        Get.snackbar('Error', res['message'] ?? 'บันทึกล้มเหลว');
      }
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

  Future<void> _fetchHistorical({required int page, bool clear = false}) async {
    final line = currentLineCd;
    if (line.isEmpty) return;

    final from = (page - 1) * historyPageSize + 1;
    final to = page * historyPageSize;

    final isFirstPage = page == 1;

    if (isFirstPage) {
      isHistoryLoading.value = true;
    } else {
      isHistoryLoadingMore.value = true;
    }

    try {
      final resp = await service.fetchHistoricalNoPlan(
        lineCd: line,
        date: historyDate.value,
        rowFrom: from,
        rowTo: to,
      );

      final newItems = resp?.items ?? [];

      if (isFirstPage) {
        historyItems.assignAll(newItems);
      } else {
        historyItems.addAll(newItems);
      }

      historyTotalLoss.value = resp?.totalLossTime.toDouble() ?? 0;

      historyPage.value = page;

      if (newItems.length < historyPageSize) {
        historyHasMore.value = false;
      }
    } catch (e) {
      if (isFirstPage) {
        historyItems.clear();
        historyTotalLoss.value = 0;
      }
      Get.snackbar('Error', e.toString());
    } finally {
      isHistoryLoading.value = false;
      isHistoryLoadingMore.value = false;
    }
  }

  void _onHistoryScroll() {
    if (!historyScrollController.hasClients) return;
    final pos = historyScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadHistoricalMore();
    }
  }

  Future<void> pickHistoryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: historyDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      historyDate.value = picked;
      await loadHistoricalInitial();
    }
  }

  String get historyDateDisplay =>
      DateFormat('dd/MM/yyyy').format(historyDate.value);

  void resetForm() {
    selectedMachineNo.value = null;
    startDate.value = DateTime.now();
    endDate.value = DateTime.now();
    startTimeController.clear();
    endTimeController.clear();
  }
}
