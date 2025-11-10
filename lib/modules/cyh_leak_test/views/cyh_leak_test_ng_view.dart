import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
import 'package:get/get.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import '../controllers/cyh_leak_test_controller.dart';

class CYHLeakTestNGView extends GetView<CYHLeakTestController> {
  CYHLeakTestNGView({super.key});

  // NOTE: ในโปรดักชัน แนะนำย้าย controllers ไปไว้ใน Controller แล้ว dispose ใน onClose()
  final noCtrls = List.generate(2, (_) => TextEditingController());
  final serialCtrls = List.generate(12, (_) => TextEditingController());
  final moldCtrls = List.generate(12, (_) => TextEditingController());
  final machineCtrls = List.generate(5, (_) => TextEditingController());

  Future<void> scanAndFill(OcrMode mode) async {
    final result = await Get.to<String>(() => OcrView(mode: mode));
    if (result == null || result.isEmpty) return;

    List<TextEditingController> target;
    int cellCount;
    switch (mode) {
        case OcrMode.mcDate18:
        target = noCtrls;
        cellCount = 18;
        break;
      case OcrMode.no2:
        target = noCtrls;
        cellCount = 2;
        break;
      case OcrMode.serial11:
        target = serialCtrls;
        cellCount = 11;
        break;
      case OcrMode.mold4:
        target = moldCtrls;
        cellCount = 4;
        break;
      case OcrMode.machine5:
        target = machineCtrls;
        cellCount = 5;
        break;
    }

    final chars = result.toUpperCase().characters.toList();
    for (var i = 0; i < cellCount; i++) {
      target[i].text = i < chars.length ? chars[i] : '';
    }
  }

  void clearNo() => noCtrls.forEach((c) => c.clear());
  void clearSerial() => serialCtrls.forEach((c) => c.clear());
  void clearMold() => moldCtrls.forEach((c) => c.clear());
  void clearMachine() => machineCtrls.forEach((c) => c.clear());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    // ระยะ padding ด้านล่างเมื่อคีย์บอร์ดโผล่ขึ้นมา (กันล้น)
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final String model = 'LX300';
    final String serial = '28-11-09#4A';
    final String result = 'NG';
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
        final isEnabled =
            (controller.selectedWorkType.value ?? '').isNotEmpty &&
                controller.machineController.text.trim().isNotEmpty;

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

                  //  child: Container(
                  //    decoration: BoxDecoration(
                  //      color: Colors.white,
                  //      borderRadius: const BorderRadius.only(
                  //        topLeft: Radius.circular(24),
                  //        topRight: Radius.circular(24),
                  //        bottomLeft: Radius.circular(12),
                  //        bottomRight: Radius.circular(12),
                  //      ),
                  //      boxShadow: [
                  //        BoxShadow(
                  //          color: Colors.black.withOpacity(0.04),
                  //          blurRadius: 8,
                  //          offset: const Offset(0, 2),
                  //        ),
                  //      ],
                  //    ),
                  // ✅ เปลี่ยนจาก Column เป็น SingleChildScrollView เพื่อให้เลื่อนทั้งหน้า
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(0),
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
                              // margin: const EdgeInsets.symmetric(
                              //     horizontal: 12, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildRowField(
                                    label: 'Machine',
                                    child: TextField(
                                      controller: controller.machineController,
                                      readOnly: true, // ✅ อ่านได้อย่างเดียว
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                      ),
                                    ),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 8),

                                  // ================= Model =================
                                  _buildRowField(
                                    label: 'Model',
                                    child: Text(model,
                                        style: const TextStyle(fontSize: 16)),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 8),

                                  // ================= Serial =================
                                  _buildRowField(
                                    label: 'Serial',
                                    child: Text(serial,
                                        style: const TextStyle(fontSize: 16)),
                                    labelStyle: labelStyle,
                                  ),
                                  const SizedBox(height: 8),

                                  // ================= Result =================
                                  _buildRowField(
                                    label: 'Result',
                                    child: Text(
                                      result,
                                      style: const TextStyle(
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
                                      _resultButton('P1 (OH)', Colors.red),
                                      _resultButton('P2 (WJ)', Colors.green),
                                      _resultButton(
                                          'P3 (CC)', Colors.green.shade700),
                                      _resultButton('P4', Colors.white,
                                          borderColor: Colors.grey.shade400,
                                          textColor: Colors.black),
                                      _resultButton('T/B', Colors.white,
                                          borderColor: Colors.grey.shade400,
                                          textColor: Colors.black),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _rowCardSimple(
                              label: 'Casting Date',
                              boxes: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _OtpBoxesRow(
                                    controllers: serialCtrls.sublist(0, 6),
                                    allowedPattern: r'[A-Za-z0-9#-]',
                                  ),
                                ],
                              ),
                              onClear: clearSerial,
                              labelStyle: labelStyle,
                            ),
                            _rowCard(
                              label: 'Mold No',
                              boxes: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _OtpBoxesRow(
                                    controllers: serialCtrls.sublist(0, 12),
                                    allowedPattern: r'[A-Za-z0-9#-]',
                                  ),
                               
                                ],
                              ),
                              onScan: () => scanAndFill(OcrMode.serial11),
                              onClear: clearSerial,
                              labelStyle: labelStyle,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed:
                                    isEnabled ? controller.goToSerial : null,
                                child: const Text('Confirm'),
                              ),
                            ),
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: borderColor ?? bgColor, width: 1),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: textColor ?? Colors.white,
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
              final availableWidth = constraints.maxWidth;
              // เพิ่มระยะห่างขวาให้เท่ากับขอบกล่องบน
              return Padding(
                padding: EdgeInsets.only(right: availableWidth * 0.10),
                // ประมาณ 4% ของความกว้าง (responsive)
                child: Align(
                  alignment: Alignment.centerRight,
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
              // IconButton(
              //   onPressed: onScan,
              //   icon: const Icon(Icons.center_focus_strong, color: Colors.blue),
              //   tooltip: 'Scan',
              // ),
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
              final availableWidth = constraints.maxWidth;
              // เพิ่มระยะห่างขวาให้เท่ากับขอบกล่องบน
              return Padding(
                padding: EdgeInsets.only(right: availableWidth * 0.10),
                // ประมาณ 4% ของความกว้าง (responsive)
                child: Align(
                  alignment: Alignment.centerRight,
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

/// กล่องกรอกแบบ OTP: 1 ช่อง = 1 ตัวอักษร
class _OtpBoxesRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final String allowedPattern;

  const _OtpBoxesRow({
    required this.controllers,
    required this.allowedPattern,
  });

  @override
  State<_OtpBoxesRow> createState() => _OtpBoxesRowState();
}

class _OtpBoxesRowState extends State<_OtpBoxesRow> {
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = List.generate(widget.controllers.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _moveToNext(int i) {
    if (i + 1 < _nodes.length) {
      _nodes[i + 1].requestFocus();
    } else {
      _nodes[i].unfocus();
    }
  }

@override
Widget build(BuildContext context) {
  final regex = RegExp(widget.allowedPattern);
  final lastIndex = widget.controllers.length - 1;
  const spacing = 8.0;

  return LayoutBuilder(
    builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final boxSide = ((maxW) - (spacing * 5)) / 6; // 6 ช่อง/แถว
      final side = boxSide.clamp(32.0, 56.0);

      return SizedBox(
        width: maxW, // กว้างเต็ม เพื่อให้ alignment มีผล
        child: Wrap(
          alignment: WrapAlignment.end, // ✅ ชิดขวา
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(widget.controllers.length, (i) {
            final c = widget.controllers[i];
            final isLast = i == lastIndex;
            return SizedBox(
              width: side,
              height: side,
              child: TextFormField(
                focusNode: _nodes[i],
                controller: c,
                textAlign: TextAlign.center,
                textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.visiblePassword,
                onTap: () => c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.allow(regex),
                ],
                onChanged: (val) {
                  if (val.isEmpty) return;
                  final upper = val.toUpperCase();
                  if (upper != val) {
                    c.value = TextEditingValue(text: upper, selection: TextSelection.collapsed(offset: upper.length));
                  }
                  _moveToNext(i);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            );
          }),
        ),
      );
    },
  );
}

}
