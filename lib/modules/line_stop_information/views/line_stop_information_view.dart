import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/line_stop_historical_model.dart';
import 'package:kmt/modules/line_stop_information/controllers/line_stop_information_controller.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import 'package:kmt/widgets/timeformat.dart';

class LineStopInformationView extends GetView<LineStopInformationController> {
  LineStopInformationView({super.key});
  final GlobalKey<KeyenceScannerState> scannerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    scannerKey.currentState?.stopSensorReader();

    return ValueListenableBuilder(
      valueListenable: controller.step,
      builder: (context, pageValue, child) {
        if (pageValue == 0) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Line Stop Records'),
                bottom: TabBar(
                  controller: controller.tabController,
                  tabs: const [
                    Tab(text: 'Records'),
                    Tab(text: 'Historical'),
                  ],
                ),
              ),
              body: TabBarView(
                controller: controller.tabController,
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
    );
  }
}

class _RecordTab extends StatelessWidget {
  final controller = Get.find<LineStopInformationController>();
  final loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();
  final box = GetStorage();

  _RecordTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.initData.value;

      if (data == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final plan = data.plan;

      return KeyenceScanner(
        onBarcodeScanned: (String scannedCode) {
          String codeToCheck;
          if (scannedCode.contains('|')) {
            final parts = scannedCode.split('|');
            if (parts.length >= 2) {
              codeToCheck = parts[1];
              final reasonLabel =
                  controller.initData.value!.reason.firstWhere((ele) => ele.code == parts[2]).label;
              controller.selectedReason.value = reasonLabel;
            } else {
              codeToCheck = scannedCode;
            }
          } else {
            codeToCheck = scannedCode;
          }

          if (data.process.contains(codeToCheck)) {
            controller.selectedProcess.value = codeToCheck;
          } else {
            Get.snackbar('ไม่พบข้อมูล', 'ไม่พบ Process ที่ตรงกับรหัส: $codeToCheck');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Line', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(box.read('selectedLine'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        if (plan != null) ...[
                          _buildInfoRowClickable(
                            'Plan Date',
                            formatDateTime(plan.planDate, plan.planStartTime),
                            () {
                              controller.selectedDate.value = DateTime.parse(plan.planDate);
                              controller.reloadRecords();
                              controller.step.value = 1;
                            },
                          ),
                          _buildInfoRow('Shift', plan.teamName),
                          _buildInfoRow('Shift Time', plan.shiftPeriodName),
                          _buildInfoRow('Model', plan.modelCd),
                          _buildInfoRow('Part No', plan.partNo),
                          _buildInfoRow('Part 1', plan.part1),
                          _buildInfoRow('Part 2', plan.part2),
                          const SizedBox(height: 8),
                          _buildDropdown('Process', data.process, controller.selectedProcess,
                              isRequired: true),
                          const SizedBox(height: 8),
                          _buildDatePicker('Stop Date', controller.ngDate, isRequired: true),
                          const SizedBox(height: 8),
                          _buildTextFormField(
                            'Stop Time',
                            controller.ngTimeController,
                            isRequired: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              TimeTextInputFormatter(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTextFormField(
                            'Lost Time',
                            controller.quantityController,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            'Reason',
                            data.reason.map((e) => e.label).toList(),
                            controller.selectedReason,
                            isRequired: true,
                          ),
                          const SizedBox(height: 8),
                          _buildCommentField('Comment', controller.commentController),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      controller.save();
                                    }
                                  },
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
                        ] else ...[
                          const Center(child: Text('No production plan available')),
                          OutlinedButton(onPressed: Get.back, child: const Text('Back')),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String formatDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final time = DateTime.parse(timeStr);
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('dd/MM/yy HH:mm').format(combined);
    } catch (_) {
      return '-';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowClickable(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 45,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
  }) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              validator: isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอก $label';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    RxString selectedValue, {
    bool isRequired = false,
  }) {
    final dropdownItems = [
      '-- กรุณาเลือก --',
      ...items,
    ];

    return Obx(() {
      return SizedBox(
        height: 60,
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
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: dropdownItems.contains(selectedValue.value) && selectedValue.value.isNotEmpty
                    ? selectedValue.value
                    : '-- กรุณาเลือก --',
                items: dropdownItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: item == '-- กรุณาเลือก --' ? Colors.grey : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedValue.value = value == '-- กรุณาเลือก --' ? '' : value;
                  }
                },
                validator: isRequired
                    ? (value) {
                        if (value == null || value.isEmpty || value == '-- กรุณาเลือก --') {
                          return 'กรุณาเลือก $label';
                        }
                        return null;
                      }
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDatePicker(String label, Rx<DateTime?> selectedDate, {bool isRequired = false}) {
    return FormField<DateTime>(
      validator: isRequired
          ? (_) {
              if (selectedDate.value == null) {
                return 'กรุณาเลือก $label';
              }
              return null;
            }
          : null,
      builder: (formFieldState) {
        return Obx(() {
          final dateText =
              selectedDate.value != null ? DateFormat('dd/MM/yy').format(selectedDate.value!) : '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDate.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          selectedDate.value = picked;
                          formFieldState.didChange(picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xF2EAF1FC),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: formFieldState.hasError ? Colors.red : Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateText.isNotEmpty ? dateText : 'เลือกวันที่',
                              style: TextStyle(
                                color: dateText.isNotEmpty ? Colors.black : Colors.grey,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 100, top: 4),
                  child: Text(
                    formFieldState.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  Widget _buildCommentField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 3,
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
    final controller = Get.find<LineStopInformationController>();

    return KeyenceScanner(
      onBarcodeScanned: (String) {},
      child: Obx(() {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(title: const Text('Production Status')),
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
                                    DateFormat('dd/MM/yy').format(controller.selectedDate.value);
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
                                    return InkWell(
                                      onTap: () {
                                        controller.setRecordFromList(record);
                                        controller.step.value = 0;
                                      },
                                      child: Card(
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
                                                    const SizedBox(
                                                        width: 80, child: Text('Status')),
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
  _HistoryTab();
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LineStopInformationController>();

    return KeyenceScanner(
      onBarcodeScanned: (String) {},
      child: Obx(() {
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
                                    DateFormat('dd/MM/yy').format(controller.selectedDate.value);
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
                                box.read('selectedLine'),
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
                                    final LineStopHistoricalRecordModel record =
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
                                                formatDateTime(record.planDate ?? '',
                                                    record.planStartTime ?? '')),
                                            _row('Line', record.lineCd),
                                            _row('Shift', record.teamName ?? '-'),
                                            _row('Model', record.modelCd ?? '-'),
                                            _row('Process', record.processCd ?? '-'),
                                            _row(
                                                'Stop Date', formatDate(record.lineStopDate ?? '')),
                                            _row(
                                                'Stop Time', formatTime(record.lineStopTime ?? '')),
                                            _row('Lost Time', record.lossTime.toString()),
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

  // String formatDate(String dateStr) {
  //   try {
  //     final date = DateTime.parse(dateStr);
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
