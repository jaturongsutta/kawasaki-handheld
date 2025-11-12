import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
import 'package:get/get.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import '../controllers/cyh_leak_test_controller.dart';

class CYHLeakTestView extends GetView<CYHLeakTestController> {
  CYHLeakTestView({super.key});

  // NOTE: ในโปรดักชัน แนะนำย้าย controllers ไปไว้ใน Controller แล้ว dispose ใน onClose()
  final noCtrls = List.generate(2, (_) => TextEditingController());
  final serialCtrls = List.generate(11, (_) => TextEditingController());
  final moldCtrls = List.generate(4, (_) => TextEditingController());
  final machineCtrls = List.generate(5, (_) => TextEditingController());

  // Future<void> scanAndFill(OcrMode mode) async {
  //   final result = await Get.to<String>(() => OcrView(mode: mode));
  //   if (result == null || result.isEmpty) return;

  //   List<TextEditingController> target;
  //   int cellCount;
  //   switch (mode) {
  //     case OcrMode.mcDate18:
  //       target = noCtrls;
  //       cellCount = 18;
  //       break;
  //     case OcrMode.no2:
  //       target = noCtrls;
  //       cellCount = 2;
  //       break;
  //     case OcrMode.serial11:
  //       target = serialCtrls;
  //       cellCount = 11;
  //       break;
  //     case OcrMode.mold4:
  //       target = moldCtrls;
  //       cellCount = 4;
  //       break;
  //     case OcrMode.machine5:
  //       target = machineCtrls;
  //       cellCount = 5;
  //       break;
  //   }

  //   final chars = result.toUpperCase().characters.toList();
  //   for (var i = 0; i < cellCount; i++) {
  //     target[i].text = i < chars.length ? chars[i] : '';
  //   }
  // }

  void clearNo() => noCtrls.forEach((c) => c.clear());
  void clearSerial() => serialCtrls.forEach((c) => c.clear());
  void clearMold() => moldCtrls.forEach((c) => c.clear());
  void clearMachine() => machineCtrls.forEach((c) => c.clear());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(
      color: Colors.blue[700],
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    // ระยะ padding ด้านล่างเมื่อคีย์บอร์ดโผล่ขึ้นมา (กันล้น)
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
              controller.machineController.text = scannedCode;
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
                            onChanged: (v) => {
                                  controller.workType.value = v,
                                  controller.selectedWorkType.value = v.name
                                }),
                        _FormRowCard(
                          label: 'Machine',
                          child: TextField(
                            controller: controller.machineController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onSubmitted: (value) => {
                              controller.machineController.text = value,
                              controller.checkIsEnabledButton()
                            },
                            onChanged: (value) => {
                              controller.machineController.text = value,
                              controller.checkIsEnabledButton()
                            },
                          ),

                          //  DropdownButtonFormField<String>(
                          //   isExpanded: true,
                          //   value: controller.selectedMachineNo.value,
                          //   items: controller.machines
                          //       .map((m) => DropdownMenuItem<String>(
                          //             value: m.machineNo,
                          //             child: Text(m.machineNo),
                          //           ))
                          //       .toList(),
                          //   onChanged: (val) =>
                          //       controller.selectedMachineNo.value = val,
                          //   decoration: InputDecoration(
                          //     contentPadding: const EdgeInsets.symmetric(
                          //         horizontal: 12, vertical: 10),
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     isDense: true,
                          //   ),
                          // ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: controller.isEnabled.value
                                ? controller.goToSerial
                                : null,
                            child: const Text('Confirm'),
                          ),
                        ),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 82, child: Text(label, style: labelStyle)),
            const SizedBox(width: 8),
            Expanded(child: child), // ❗ ไม่มี SizedBox/Align ครอบ
          ],
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: boxes),
            ],
          ),
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(widget.controllers.length, (i) {
        final c = widget.controllers[i];
        final isLast = i == lastIndex;

        return SizedBox(
          width: 40,
          height: 40,
          child: TextFormField(
            focusNode: _nodes[i],
            controller: c,
            textAlign: TextAlign.center,
            textInputAction:
                isLast ? TextInputAction.done : TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.visiblePassword,
            onTap: () {
              c.selection =
                  TextSelection(baseOffset: 0, extentOffset: c.text.length);
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.allow(regex),
            ],
            onChanged: (val) {
              if (val.isEmpty) return;
              final upper = val.toUpperCase();
              if (upper != val) {
                c.value = TextEditingValue(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
              _moveToNext(i);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        );
      }),
    );
  }
}
