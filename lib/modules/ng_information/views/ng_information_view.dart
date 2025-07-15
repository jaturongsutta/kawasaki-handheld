import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/ng_historical_model.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import '../controllers/ng_information_controller.dart';

class NgInformationView extends GetView<NgInformationController> {
  const NgInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyenceScanner(
      onBarcodeScanned: (String) {
        print('replace2');
      },
      child: ValueListenableBuilder(
        valueListenable: controller.step,
        builder: (context, pageValue, child) {
          if (pageValue == 0) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('NG records'), // ✅ แสดงค่าใน Title
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Records'),
                      Tab(text: 'Historical'),
                    ],
                  ),
                ),
                body: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _RecordTab(),
                    _HistoryTab(),
                  ],
                ),
              ),
            );
          } else {
            return const _ListRecord();
          }
        },
      ),
    );
  }
}

class _RecordTab extends StatelessWidget {
  final controller = Get.find<NgInformationController>();
  final loginController = Get.find<LoginController>();

  _RecordTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.initData.value;

      if (data == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final plan = data.plan;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Line',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(
                  loginController.selectedLine.value,
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
                    if (plan != null) ...[
                      _buildInfoRow('Plan Date', formatDateTime(plan.planDate)),
                      _buildInfoRow('Shift', plan.teamName),
                      _buildInfoRow('Shift Time', plan.shiftPeriodName),
                      _buildInfoRow('Model', plan.modelCd),
                      _buildInfoRow('Part No', plan.partNo),
                      _buildInfoRow('Part 1', plan.part1),
                      _buildInfoRow('Part 2', plan.part2),
                    ] else
                      const Center(child: Text('No production plan available')),
                    const SizedBox(height: 8),
                    _buildDropdown('Process', data.process, controller.selectedProcess),
                    const SizedBox(height: 8),
                    _buildDatePicker('NG Date', controller.ngDate),
                    const SizedBox(height: 8),
                    _buildTextField('NG Time', controller.ngTimeController),
                    const SizedBox(height: 8),
                    _buildTextField('Quantity', controller.quantityController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      'Reason',
                      data.reason.map((e) => e.label).toList(),
                      controller.selectedReason,
                    ),
                    const SizedBox(height: 8),
                    _buildCommentField('Comment', controller.commentController),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.save,
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: Get.back,
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
    });
  }

  String formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final combined = DateTime(date.year, date.month, date.day, date.hour, date.minute);
      return DateFormat('yy/MM/dd HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return SizedBox(
      height: 45, // ✅ กำหนดความสูงคงที่
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // ✅ ตัดข้อความกรณียาวเกินไป
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, RxString selectedValue) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
                  value: selectedValue.value.isEmpty ? null : selectedValue.value,
                  items: items
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedValue.value = value;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true, // ✅ ลดความสูงช่องเลือก
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, Rx<DateTime> selectedDate) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Obx(() {
            final dateText = DateFormat('dd/MM/yy').format(selectedDate.value);
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: selectedDate.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) selectedDate.value = picked;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xF2EAF1FC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateText),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return SizedBox(
      height: 45, // ✅ กำหนดความสูงเท่ากัน
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true, // ✅ ลดความสูงช่องกรอก
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}

class _ListRecord extends StatelessWidget {
  const _ListRecord({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NgInformationController>();

    return Obx(() {
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text('NG Record List')),
            body: controller.isLoading.value
                ? const SizedBox()
                : Column(
                    children: [
                      Padding(
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
                              controller.reloadRecords();
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
                              final dateStr =
                                  DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
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
                      ),
                      Expanded(
                        child: controller.ngRecordList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('No record found'),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reload'),
                                      onPressed: controller.reloadRecords,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: controller.ngRecordList.length,
                                itemBuilder: (context, index) {
                                  final record = controller.ngRecordList[index];
                                  return Card(
                                    margin: const EdgeInsets.all(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _row(
                                              'Plan',
                                              formatDateTime(
                                                  record.planDate, record.planStartTime)),
                                          _row('Shift', record.teamName),
                                          _row('Shift Time', record.shiftPeriodName),
                                          _row('OT', record.ot == 'Y' ? 'Yes OT' : '-'),
                                          _row('Model', record.modelCd),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 80, child: Text('Status')),
                                                Expanded(
                                                  child: Text(
                                                    record.statusName,
                                                    style: const TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }

  String formatDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final time = DateTime.parse(timeStr).toLocal();
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('yy/MM/dd HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NgInformationController>();
    final loginController = Get.find<LoginController>();

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            controller.isLoading.value
                ? const SizedBox()
                : Column(
                    children: [
                      Padding(
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
                              controller.reloadHistoricalRecords();
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
                              final dateStr =
                                  DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Line',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              loginController.selectedLine.value,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '',
                              style: TextStyle(fontSize: 1, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'total: ${controller.totalRecords.value.toString()}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: controller.historicalRecordList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('No historical record found'),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reload'),
                                      onPressed: controller.reloadHistoricalRecords,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: controller.historicalRecordList.length,
                                itemBuilder: (context, index) {
                                  final HistoricalRecordModel record =
                                      controller.historicalRecordList[index];
                                  return Card(
                                    margin: const EdgeInsets.all(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _row(
                                              'Plan',
                                              formatDateTime(
                                                  record.planDate, record.planStartTime)),
                                          _row('Line', record.lineCd),
                                          _row('Shift', record.teamName ?? '-'),
                                          _row('Model', record.modelCd ?? '-'),
                                          _row('Process', record.processCd ?? '-'),
                                          _row('NG Date', formatDate(record.ngDate)),
                                          _row('NG Time', formatTime(record.ngTime)),
                                          _row('Quantity', '${record.quantity}'),
                                          _row('Reason', record.reasonName ?? '-'),
                                          _row('Comment', record.comment ?? '-'),
                                          _row('Status', record.statusName ?? '-'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    });
  }

  String formatDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final time = DateTime.parse(timeStr).toLocal();
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('yy/MM/dd HH:mm').format(combined);
    } catch (e) {
      return '-';
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final combined = DateTime(date.year, date.month, date.day);
      return DateFormat('yy/MM/dd').format(combined);
    } catch (e) {
      return '-';
    }
  }

  String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr).toLocal();
      final combined = DateTime(time.hour, time.minute);
      return DateFormat('HH:mm').format(combined);
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
