import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
import 'package:get/get.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_serial_controller.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/otp_boxes_row.dart';

class CYHLeakTestSerialView extends GetView<CYHLeakTestSerialController> {
  CYHLeakTestSerialView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initFormFromArgs();

    final theme = Theme.of(context);
    const labelStyle = TextStyle(
      // color: Colors.blue[700],
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    // ระยะ padding ด้านล่างเมื่อคีย์บอร์ดโผล่ขึ้นมา (กันล้น)
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final gsText = controller.gsCheck.value.trim();
    final gsValue = int.tryParse(gsText) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      // เปิดให้เลื่อนอัตโนมัติเวลาเปิดคีย์บอร์ด
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Leak Test',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Obx(() {
        return KeyenceScanner(
          onBarcodeScanned: (String scannedCode) {
            if (scannedCode.isNotEmpty) {
              controller.selectedMCDate.value = scannedCode;
              controller.getGSCount();
              controller.checkIsEnabledButton();
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                // ---------- BODY ----------
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(0),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkTypeSelector(
                            value: controller.workType.value,
                            onChanged: (v) => {}),
                        Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // แถว Machine (TextField + ปุ่มสแกน)
                                _LabeledField(
                                  label: 'Machine',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          readOnly: true,
                                          controller:
                                              controller.machineController,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),
                                _LabeledField(
                                  label: 'Model',
                                  child: AbsorbPointer(
                                    absorbing: controller.isModelReadOnly.value,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded:
                                          controller.isModelReadOnly.value,
                                      value: controller
                                          .selectedModel.value?.modelCd,
                                      items: controller.models
                                          .map((m) => m.modelCd)
                                          .where((cd) => cd.isNotEmpty)
                                          .toSet() // <-- ตรงนี้แปลงเป็น Set เพื่อกันซ้ำ
                                          .map((cd) => DropdownMenuItem<String>(
                                                value: cd,
                                                child: Text(cd),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final model =
                                              controller.models.firstWhere(
                                            (m) => m.modelCd == val,
                                            orElse: () => LeakTestRunningModel(
                                              id: 0,
                                              lineCd: '',
                                              lineName: '',
                                              modelCd: '',
                                              partNo: '',
                                            ),
                                          );
                                          controller.selectedModel.value =
                                              model;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _rowCard(
                          label: 'M/C Date',
                          boxes: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              OtpBoxesRow(
                                controllers:
                                    controller.mcDateCtrls.sublist(0, 18),
                                allowedPattern: r'[A-Za-z0-9#-]',
                                onChanged: (value) {
                                  print('MC Date changed: $value');
                                  controller.selectedMCDate.value = value;
                                  controller.checkGetGSCount();
                                },
                                onSubmitted: (value) {
                                  print('MC Date submitted: $value');
                                  if (value.isNotEmpty) {
                                    controller.selectedMCDate.value = value;
                                    controller.getGSCount();
                                    controller.checkIsEnabledButton();
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                          onScan: () =>
                              controller.scanAndFill(OcrMode.mcDate18),
                          onClear: () {
                            controller.clearMCDate();
                            controller.selectedMCDate.value = '';
                            controller.checkIsEnabledButton();
                          },
                          labelStyle: labelStyle,
                        ),
                        _rowCardSimple(
                          label: 'C/A No',
                          boxes: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OtpBoxesRow(
                                controllers: controller.caNoCtrls.sublist(0, 3),
                                allowedPattern: r'[0-9]',
                                onChanged: (value) {
                                  print('C/A No changed: $value');
                                },
                                onSubmitted: (value) {
                                  print('C/A No submitted: $value');
                                  if (value.isNotEmpty) {
                                    controller.selectedCANo.value = value;
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                          onClear: controller.clearCANo,
                          labelStyle: labelStyle,
                        ),
                        _rowCardSimple(
                          label: 'C/A Date',
                          boxes: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OtpBoxesRow(
                                controllers:
                                    controller.caDateCtrls.sublist(0, 6),
                                allowedPattern: r'[A-Za-z0-9#-]',
                                hyphenIndex: 2,
                                onChanged: (value) {
                                  print('C/A Date changed: $value');
                                },
                                onSubmitted: (value) {
                                  print('C/A Date submitted: $value');
                                  if (value.isNotEmpty) {
                                    controller.selectedCADate.value = value;
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                          onClear: controller.clearCADate,
                          labelStyle: labelStyle,
                        ),
                        _rowCard(
                          label: 'Mold No',
                          boxes: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OtpBoxesRow(
                                controllers:
                                    controller.moldCtrls.sublist(0, 12),
                                allowedPattern: r'[A-Za-z0-9#-]',
                                onChanged: (value) {
                                  print('changed yes: $value');
                                  if (value.isNotEmpty) {
                                    controller.selectedmoldCtrls.value = value;
                                  }
                                },
                                onSubmitted: (value) {
                                  print('submitted yes: $value');
                                  if (value.isNotEmpty) {
                                    controller.selectedmoldCtrls.value = value;
                                  }
                                },
                              ),
                            ],
                          ),
                          onScan: () => controller.scanAndFill(OcrMode.mold12),
                          onClear: controller.clearMold,
                          labelStyle: labelStyle,
                        ),
                        gsValue > 0
                            ? _FormRowCard(
                                label: 'G/S',
                                child: TextField(
                                  controller: controller.gsController,
                                  keyboardType: TextInputType
                                      .number, // แสดงคีย์บอร์ดตัวเลข
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // ✅ อนุญาตเฉพาะตัวเลข 0–9
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onSubmitted: (value) => {
                                    controller.gsController.text = value,
                                  },
                                  onChanged: (value) => {
                                    controller.gsController.text = value,
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: controller.isEnabled.value
                                ? controller.confirmForm
                                : null,
                            child: const Text('Confirm'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                //  ),

                // ---------- LOADING BAR ----------
                if (controller.isLoading.value)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// -------------------- helper widgets --------------------
const double kLabelWidth = 92;

class _FormRowCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormRowCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: kLabelWidth, child: Text(label, style: labelStyle)),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: kLabelWidth, child: Text(label, style: labelStyle)),
        Expanded(child: child),
      ],
    );
  }
}

Widget _rowCard({
  required String label,
  required Widget boxes,
  required VoidCallback onScan,
  required VoidCallback onClear,
  required TextStyle labelStyle,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0.5,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding:
          const EdgeInsets.fromLTRB(12, 8, 12, 12), // ✅ padding ซ้ายขวาเท่ากัน
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 72, child: Text(label, style: labelStyle)),
              const SizedBox(width: 100),
              IconButton(
                onPressed: onScan,
                icon: const Icon(Icons.center_focus_strong, color: Colors.blue),
                tooltip: 'Scan',
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Clear',
              ),
            ],
          ),

          // ---------- Boxes ----------
          LayoutBuilder(
            builder: (context, constraints) {
              // ✅ ใช้ LayoutBuilder เพื่อให้ยืดหยุ่นตามความกว้างจริงของ Card

              // เพิ่มระยะห่างขวาให้เท่ากับขอบกล่องบน
              return Padding(
                padding: const EdgeInsets.only(left: 0, top: 4),
                // ประมาณ 4% ของความกว้าง (responsive)
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: boxes,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // gs,
          // const SizedBox(height: 4),
        ],
      ),
    ),
  );
}

Widget _rowCardSimple({
  required String label,
  required Widget boxes,
  required VoidCallback onClear,
  required TextStyle labelStyle,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0.5,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // label ด้านซ้าย
              Expanded(
                child: Text(
                  label,
                  style: labelStyle,
                ),
              ),
              // ปุ่มลบด้านขวา
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Clear',
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ---------- Boxes ----------
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4),
            child: Align(
              alignment: Alignment.centerLeft, // ✅ ชิดซ้าย
              child: boxes,
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    ),
  );
}
