import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
import 'package:get/get.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_serial_controller.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class CYHLeakTestSerialView extends GetView<CYHLeakTestSerialController> {
  CYHLeakTestSerialView({super.key});

  // NOTE: ในโปรดักชัน แนะนำย้าย controllers ไปไว้ใน Controller แล้ว dispose ใน onClose()

  // final noCtrls = List.generate(2, (_) => TextEditingController());
  // final serialCtrls = List.generate(12, (_) => TextEditingController());
  // final moldCtrls = List.generate(4, (_) => TextEditingController());
  // final machineCtrls = List.generate(5, (_) => TextEditingController());

  // void clearNo() => noCtrls.forEach((c) => c.clear());
  // void clearSerial() => serialCtrls.forEach((c) => c.clear());
  // void clearMold() => moldCtrls.forEach((c) => c.clear());
  // void clearMachine() => machineCtrls.forEach((c) => c.clear());

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

    final gsText = controller.gsController.text.trim();
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
                        _FormRowCard(
                          label: 'Work Type',
                          child: TextField(
                            readOnly: true,
                            controller: controller.workTypeController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                          ),
                        ),
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

                                // แถว Model (Dropdown)
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
                                          .map((m) => DropdownMenuItem<String>(
                                                value: m.modelCd,
                                                child: Text(m.modelCd ?? ''),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final model =
                                              controller.models.firstWhere(
                                            (m) => m.modelCd == val,
                                            orElse: () => LeakTestRunningModel(
                                              id: '',
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
                              _OtpBoxesRow(
                                controllers:
                                    controller.mcDateCtrls.sublist(0, 18),
                                allowedPattern: r'[A-Za-z0-9#-]',
                                onSubmitted: (value) {
                                   print('MC Date submitted: $value');
                                  if (value.isNotEmpty) {
                                    controller.selectedMCDate.value =
                                        value;
                                    controller.getGSCount();
                                    controller.checkIsEnabledButton();
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              // _OtpBoxesRow(
                              //   controllers: serialCtrls.sublist(6, 12),
                              //   allowedPattern: r'[A-Za-z0-9#-]',
                              // ),
                              // const SizedBox(height: 8),
                            ],
                          ),
                          onScan: () =>
                              controller.scanAndFill(OcrMode.mcDate18),
                          onClear: controller.clearMCDate,
                          labelStyle: labelStyle,
                          gs: gsValue > 0
                              ?
                              // ---------- แถว G/S ----------
                              // ให้จัดแนว/ขอบซ้ายขวาเท่ากับ input ด้านบน
                              Padding(
                                  padding: const EdgeInsets.only(
                                      right: 0), // ถ้าต้องเว้นเพิ่ม ปรับได้
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ความกว้าง label ให้เท่ากับแถว Machine/Model (เช่น 92 หรือ 110)
                                      const SizedBox(
                                        width: kLabelWidth,
                                        child: Text(
                                          'G/S',
                                          style:
                                              labelStyle, // ใช้สไตล์เดียวกับ label ในการ์ด
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                keyboardType: TextInputType
                                                    .number, // แสดงคีย์บอร์ดตัวเลข
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // ✅ อนุญาตเฉพาะตัวเลข 0–9
                                                ],
                                                controller:
                                                    controller.gsController,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 10),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
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
  required Widget gs,
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
          const SizedBox(height: 12),
          gs,
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

  /// เรียกเมื่อผู้ใช้กด `Done` ที่ช่องสุดท้าย
  /// หรือเมื่อทุกช่องถูกกรอกครบแล้ว (เรียกจาก onChanged)
  final ValueChanged<String>? onSubmitted;

  const _OtpBoxesRow({
    required this.controllers,
    required this.allowedPattern,
    this.onSubmitted,
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

  bool _allFilled() =>
      widget.controllers.every((c) => c.text.trim().isNotEmpty);

  String _joined() => widget.controllers.map((c) => c.text).join();

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
          width: maxW,
          child: Wrap(
            alignment: WrapAlignment.end, // ชิดขวา
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
                  textInputAction:
                      isLast ? TextInputAction.done : TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.visiblePassword,
                  onTap: () => c.selection =
                      TextSelection(baseOffset: 0, extentOffset: c.text.length),
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
                        selection:
                            TextSelection.collapsed(offset: upper.length),
                      );
                    }
                    _moveToNext(i);

                    // ถ้ากรอกครบทุกช่องแล้ว ยิง callback ทันที
                    if (_allFilled()) {
                      widget.onSubmitted?.call(_joined());
                    }
                  },
                  onFieldSubmitted: (_) {
                    // กด Done ที่ช่องสุดท้าย → ยิง callback
                    if (isLast) {
                      widget.onSubmitted?.call(_joined());
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
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
