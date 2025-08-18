import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/production_detail_model.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/modules/production_status_list/controllers/production_status_list_controller.dart';

class ProductionStatusView extends GetView<ProductionStatusController> {
  const ProductionStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.step,
      builder: (context, pageValue, child) {
        if (pageValue == 0) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Production Status'),
                bottom: TabBar(
                  controller: controller.tabController,
                  tabs: const [
                    Tab(text: 'Current'),
                    Tab(text: 'Other'),
                  ],
                ),
              ),
              body: TabBarView(
                controller: controller.tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _CurrentListTab(),
                  _OtherTab(),
                ],
              ),
            ),
          );
        } else if (pageValue == 1) {
          return _ProductionstatusTab();
        } else {
          return _OtherProductionstatusTab();
        }
      },
    );
  }
}

class _ProductionstatusTab extends StatelessWidget {
  final controller = Get.find<ProductionStatusController>();
  final loginController = Get.find<LoginController>();
  final box = GetStorage();
  _ProductionstatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final data = controller.selectedPlanDetail.value!;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              controller.step.value = 0;
              controller.selectedPlanDetail.value = null;
            },
          ),
          title: const Text('Production Status'),
        ),
        body: Obx(() => Stack(
              children: [
                // ✅ หน้าหลัก
                _buildContent(data),

                // ✅ แสดง Overlay Loading
                if (controller.isLoading.value)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            )));
  }

  Widget _buildContent(ProductionDetailModel data) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Line',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                box.read('selectedLine'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _infoRow('Plan', formatDateTime(data.planDate, data.planStartTime)),
                  _infoRow('Shift', data.teamName),
                  _infoRow('ShiftTime', data.shiftPeriodName),
                  _breakRow('Break 1', controller.isBreak1Checked, () => controller.setBreak(1)),
                  _breakRow(
                      'Lunch Break', controller.isBreak2Checked, () => controller.setBreak(2)),
                  _breakRow('Break 2', controller.isBreak3Checked, () => controller.setBreak(3)),
                  _breakRow('Break OT', controller.isBreak4Checked, () => controller.setBreak(4)),
                  _otRow(data),
                  _infoRow('Model', data.modelCd),
                  _infoRow('Cycle Time', '${formatTime(data.cycleTime)} mins'),
                  _infoRow('Part No', data.partNo),
                  _infoRow('Part 1', data.partUpper),
                  _infoRow('Part 2', data.partLower ?? '-'),
                  _infoRow('AS400', data.productCd),
                  _infoRow('Product Code', data.pkCd),
                  const SizedBox(height: 16),
                  if (data.status == "20" || data.status == "10")
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('Stop'),
                            onPressed: () {
                              controller.confirmStopPlan();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade100,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.step.value = 0;
                              controller.selectedPlanDetail.value = null;
                            },
                            child: const Text('Back'),
                          ),
                        ),
                      ],
                    ),
                  if (data.status != "20" && data.status != "10")
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          controller.step.value = 0;
                          controller.selectedPlanDetail.value = null;
                        },
                        child: const Text('Back'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label :', style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otRow(ProductionDetailModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(() {
        final isChecked = controller.isOTChecked.value;

        return Row(
          children: [
            const SizedBox(
              width: 120,
              child: Text('OT :', style: TextStyle(color: Colors.grey)),
            ),
            Switch(
              value: isChecked,
              onChanged: (val) => controller.isOTChecked.value = val,
              activeColor: Colors.green,
              activeTrackColor: Colors.green.shade200,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade200,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 74,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await controller.setOT();

                  if (success) {
                    controller.isOTSet.value = true;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'Save',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String formatDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final time = DateTime.parse(timeStr);
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('dd/MM/yy HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }

  Widget _breakRow(String label, RxBool rxValue, Future<bool> Function() onSet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Obx(() {
        final isChecked = rxValue.value;

        return Row(
          children: [
            SizedBox(
              width: 120,
              child: Text('$label :', style: const TextStyle(color: Colors.grey)),
            ),
            Switch(
              value: isChecked,
              onChanged: (val) {
                rxValue.value = val;
                // onSet(val);
                onSet();
              },
              activeColor: Colors.green,
              activeTrackColor: Colors.green.shade200,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade200,
            ),
            const SizedBox(width: 8),
          ],
        );
      }),
    );
  }

  String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('mm:ss').format(time);
    } catch (e) {
      return '-';
    }
  }
}

class _CurrentListTab extends StatelessWidget {
  final controller = Get.find<ProductionStatusController>();
  _CurrentListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.planList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No production plan for today.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
                onPressed: controller.fetchTodayProductionPlan,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.planList.length,
        itemBuilder: (context, index) {
          final item = controller.planList[index];
          return InkWell(
            onTap: () {
              controller.loadPlanDetail(item.id);
            },
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Line', item.lineCd),
                    _row('Plan Date', controller.formatPlanTime(item.planDate, item.planStartTime)),
                    _row('Shift', item.teamName),
                    _row('Shift Time', item.shiftPeriodName),
                    _row('OT', item.ot == 'Y' ? 'Yes' : 'No'),
                    _row('Model', item.modelCd),
                    _row('Status', item.statusName),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _OtherTab extends StatelessWidget {
  _OtherTab();
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductionStatusController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            Column(
              children: [
                _buildDatePicker(context, controller),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Line',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(box.read('selectedLine'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          Text(
                            'total: ${controller.plans.length}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  child: Obx(() {
                    final plans = controller.plans;
                    if (plans.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No data found'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reload'),
                              onPressed: () async => await controller.searchOtherTab(),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final record = plans[index];
                        return InkWell(
                          onTap: () async {
                            await controller.loadOtherPlanDetail(record.id);
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _row('Plan',
                                      formatDateTime(record.planDate, record.planStartTime)),
                                  _row('Shift', record.teamName),
                                  _row('ShiftTime', record.shiftPeriodName),
                                  _row('OT', record.ot == 'Y' ? 'Yes OT' : 'No'),
                                  _row('Model', record.modelCd),
                                  _row('Status', record.statusName),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDatePicker(BuildContext context, ProductionStatusController controller) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.selectedDate.value = picked;
            await controller.searchOtherTab();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Obx(() {
            final dateStr = DateFormat('dd/MM/yy').format(controller.selectedDate.value);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr),
                const Icon(Icons.calendar_today, size: 18),
              ],
            );
          }),
        ),
      ),
    );
  }

  String formatDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final time = DateTime.parse(timeStr);
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('dd/MM/yy HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }

  // String formatDate(String dateStr) {
  //   try {
  //     final date = DateTime.parse(dateStr).toLocal();
  //     final combined = DateTime(date.year, date.month, date.day);
  //     return DateFormat('yy/MM/dd').format(combined);
  //   } catch (e) {
  //     return '-';
  //   }
  // }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yy').format(date); // ✅ ปรับตามนี้
    } catch (e) {
      return '-';
    }
  }

  String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return '-';
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _OtherProductionstatusTab extends StatelessWidget {
  final controller = Get.find<ProductionStatusController>();
  final loginController = Get.find<LoginController>();
  final box = GetStorage();
  _OtherProductionstatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final data = controller.selectedOtherPlanDetail.value!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.step.value = 0;
            controller.selectedOtherPlanDetail.value = null;
          },
        ),
        title: const Text('Production Status'),
      ),
      body: Obx(() => Stack(
            children: [
              // ✅ หน้าหลัก
              _buildContent(data),

              // ✅ แสดง Overlay Loading
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildContent(ProductionDetailModel data) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Line',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                box.read('selectedLine'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _infoRow('Plan', formatDateTime(data.planDate, data.planStartTime)),
                  _infoRow('Shift', data.teamName),
                  _infoRow('ShiftTime', data.shiftPeriodName),
                  _breakRow(
                      'Break 1', controller.isBreak1Checked, () => controller.setBreakOther(1)),
                  _breakRow(
                      'Lunch Break', controller.isBreak2Checked, () => controller.setBreakOther(2)),
                  _breakRow(
                      'Break 2', controller.isBreak3Checked, () => controller.setBreakOther(3)),
                  _breakRow(
                      'Break OT', controller.isBreak4Checked, () => controller.setBreakOther(4)),
                  _otRow(data),
                  _infoRow('Model', data.modelCd),
                  _infoRow('Cycle Time', '${formatTime(data.cycleTime)} mins'),
                  _infoRow('Part No', data.partNo),
                  _infoRow('Part 1', data.partUpper),
                  _infoRow('Part 2', data.partLower ?? '-'),
                  _infoRow('AS400', data.productCd),
                  _infoRow('Product Code', data.pkCd),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.step.value = 0;
                            controller.selectedOtherPlanDetail.value = null;
                          },
                          child: const Text('Back'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label :', style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otRow(ProductionDetailModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(() {
        final isChecked = controller.isOTCheckedOther.value;

        return Row(
          children: [
            const SizedBox(
              width: 120,
              child: Text('OT :', style: TextStyle(color: Colors.grey)),
            ),
            Switch(
              value: isChecked,
              onChanged: (val) => controller.isOTCheckedOther.value = val,
              activeColor: Colors.green,
              activeTrackColor: Colors.green.shade200,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade200,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 74,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await controller.setOTOther();
                  if (success) {
                    controller.isOTSetOther.value = true;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'SET OT',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _breakRow(String label, RxBool rxValue, Future<bool> Function() onSet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Obx(() {
        final isChecked = rxValue.value;

        return Row(
          children: [
            SizedBox(
              width: 120,
              child: Text('$label :', style: const TextStyle(color: Colors.grey)),
            ),
            Switch(
              value: isChecked,
              onChanged: (val) {
                rxValue.value = val;
                // onSet(val);
                onSet();
              },
              activeColor: Colors.green,
              activeTrackColor: Colors.green.shade200,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade200,
            ),
            const SizedBox(width: 8),
          ],
        );
      }),
    );
  }

  String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('mm:ss').format(time);
    } catch (e) {
      return '-';
    }
  }

  String formatDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final time = DateTime.parse(timeStr);
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('dd/MM/yy HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }
}
