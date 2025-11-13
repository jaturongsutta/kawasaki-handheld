import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_ng_controller.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/otp_boxes_row.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class CYHLeakTestNGView extends GetView<CYHLeakTestNGController> {
  const CYHLeakTestNGView({super.key});

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      // เปิดให้เลื่อนอัตโนมัติเวลาเปิดคีย์บอร์ด
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('NG Leak Test',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Obx(() {
        return KeyenceScanner(
          onBarcodeScanned: (String scannedCode) {
            controller.scanQrForMachine(scannedCode);
          },
          child: SafeArea(
            child: Stack(
              children: [
                // ---------- BODY ----------
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(0),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // ✅ พื้นหลังสีขาว
                                borderRadius:
                                    BorderRadius.circular(12), // ✅ มุมโค้ง
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildRowField(
                                    label: 'Machine',
                                    child: Text(
                                        controller.dataModel.value?.machineNo ??
                                            '',
                                        style: const TextStyle(fontSize: 16)),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 8),

                                  // ================= Model =================
                                  _buildRowField(
                                    label: 'Model',
                                    child: Text(
                                        controller.dataModel.value?.modelCd ??
                                            '',
                                        style: const TextStyle(fontSize: 16)),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 8),

                                  // ================= Serial =================
                                  _buildRowField(
                                    label: 'Serial',
                                    child: Text(
                                        controller.dataModel.value?.serial ??
                                            '',
                                        style: const TextStyle(fontSize: 16)),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 8),

                                  // ================= Result =================
                                  _buildRowField(
                                    label: 'Result',
                                    child: const Text(
                                      'NG',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 12),

                                  // ================= Buttons =================
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _resultButton(
                                          controller.dataModel.value?.ngP1 ??
                                              '',
                                          controller.hexToColor(controller
                                                  .dataModel.value?.ngP1Color ??
                                              '#FFFFFF')),
                                      _resultButton(
                                          controller.dataModel.value?.ngP2 ??
                                              '',
                                          controller.hexToColor(controller
                                                  .dataModel.value?.ngP2Color ??
                                              '#FFFFFF')),
                                      _resultButton(
                                          controller.dataModel.value?.ngP3 ??
                                              '',
                                          controller.hexToColor(controller
                                                  .dataModel.value?.ngP3Color ??
                                              '#FFFFFF')),
                                      _resultButton(
                                          controller.dataModel.value?.ngP4 ??
                                              '',
                                          controller.hexToColor(controller
                                                  .dataModel.value?.ngP4Color ??
                                              '#FFFFFF')),
                                      _resultButton(
                                        controller.dataModel.value?.ngTb ?? '',
                                        controller.hexToColor(controller
                                                .dataModel.value?.ngTbColor ??
                                            '#FFFFFF'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _rowCardSimple(
                              label: 'C/A No',
                              boxes: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OtpBoxesRow(
                                    controllers:
                                        controller.caNoCtrls.sublist(0, 3),
                                    allowedPattern: r'[0-9]',
                                    onChanged: (value) {
                                      print('changed yes: $value');
                                      if (value.isNotEmpty) {
                                        controller.selectedCANo.value = value;
                                        controller.checkIsEnabledButton();
                                      }
                                    },
                                    onSubmitted: (value) {
                                      print('submitted yes: $value');
                                      if (value.isNotEmpty) {
                                        controller.selectedCANo.value = value;
                                        controller.checkIsEnabledButton();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onClear: () {
                                controller.clearCANo();
                                controller.selectedCANo.value = '';
                                controller.checkIsEnabledButton();
                              },
                              labelStyle: labelStyle,
                            ),
                            _rowCardSimple(
                              label: 'C/A Date',
                              boxes: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OtpBoxesRow(
                                    controllers: controller.castingDateCtrls
                                        .sublist(0, 6),
                                    allowedPattern: r'[A-Za-z0-9#-]',
                                    hyphenIndex: 2,
                                    onChanged: (value) {
                                      print('changed yes: $value');
                                      if (value.isNotEmpty) {
                                        controller.selectedcastingDate.value =
                                            value;
                                        controller.checkIsEnabledButton();
                                      }
                                    },
                                    onSubmitted: (value) {
                                      print('submitted yes: $value');
                                      if (value.isNotEmpty) {
                                        controller.selectedcastingDate.value =
                                            value;
                                        controller.checkIsEnabledButton();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onClear: () {
                                controller.clearCastingDate();
                                controller.selectedcastingDate.value = '';
                                controller.checkIsEnabledButton();
                              },
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
                                        controller.selectedmoldCtrls.value =
                                            value;
                                        controller.checkIsEnabledButton();
                                      }
                                    },
                                    onSubmitted: (value) {
                                      print('submitted yes: $value');
                                      if (value.isNotEmpty) {
                                        controller.selectedmoldCtrls.value =
                                            value;
                                        controller.checkIsEnabledButton();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onScan: () =>
                                  controller.scanAndFill(OcrMode.mold12),
                              onClear: () {
                                controller.clearMold();
                                controller.selectedmoldCtrls.value = '';
                                controller.checkIsEnabledButton();
                              },
                              labelStyle: labelStyle,
                            ),
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
                          ])),
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
// ----------------- Helper: Label + Field -----------------
Widget _buildRowField({
  required String label,
  required Widget child,
  required TextStyle labelStyle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 92,
        child: Text(label, style: labelStyle),
      ),
      Expanded(child: child),
    ],
  );
}

// ----------------- Helper: Button -----------------
Widget _resultButton(
  String text,
  Color bgColor, {
  Color? textColor,
  Color? borderColor,
}) {
  // ตรวจว่าพื้นหลังเป็นสีขาวหรือไม่ (รวมถึง #FFFFFF, 0xFFFFFFFF)
  final bool isWhite = bgColor.value == const Color(0xFFFFFFFF).value;

  final effectiveBorderColor =
      isWhite ? Colors.grey.shade400 : (borderColor ?? bgColor);
  final effectiveTextColor =
      isWhite ? Colors.black : (textColor ?? Colors.white);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: effectiveBorderColor, width: 1),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: effectiveTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
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

          const SizedBox(height: 4),
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
