import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
import 'package:get/get.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_serial_controller.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class CYHLeakTestSerialView extends GetView<CYHLeakTestSerialController> {
  CYHLeakTestSerialView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initFormFromArgs();

    const labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    // ระยะ padding ด้านล่างเมื่อคีย์บอร์ดโผล่ขึ้นมา (กันล้น + กันโดนทับ)
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      // ✅ ให้ Scaffold ขยับตามคีย์บอร์ด
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Leak Test',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // ✅ เอามาไว้ใน Obx เพื่อให้ react ตามค่า gsCheck
        final gsText = controller.gsCheck.value.trim();
        final gsValue = int.tryParse(gsText) ?? 0;

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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    // ✅ กันโดนคีย์บอร์ดทับ + เลื่อนให้พ้น
                    padding: EdgeInsets.only(bottom: bottomInset + 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkTypeSelector(
                          value: controller.workType.value,
                          onChanged: (v) => {},
                        ),
                        Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                                  BorderRadius.circular(8),
                                            ),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                controller.isModelReadOnly.value
                                    ? _buildRowField(
                                        label: 'Model',
                                        child: Text(
                                          controller.selectedModel.value
                                                  ?.modelCd ??
                                              '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        labelStyle: labelStyle,
                                      )
                                    : _LabeledField(
                                        label: 'Model',
                                        child: AbsorbPointer(
                                          absorbing:
                                              controller.isModelReadOnly.value,
                                          child: DropdownButtonFormField<String>(
                                            isExpanded: controller
                                                .isModelReadOnly.value,
                                            value: controller
                                                .selectedModel.value?.modelCd,
                                            items: controller.models
                                                .map((m) => m.modelCd)
                                                .where((cd) => cd.isNotEmpty)
                                                .toSet()
                                                .map(
                                                  (cd) => DropdownMenuItem<
                                                      String>(
                                                    value: cd,
                                                    child: Text(cd),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                final model = controller.models
                                                    .firstWhere(
                                                  (m) => m.modelCd == val,
                                                  orElse: () =>
                                                      LeakTestRunningModel(
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
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
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
                                  controller.selectedMCDate.value = value;
                                  controller.checkGetGSCount();
                                },
                                onSubmitted: (value) {
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
                                  controller.selectedCANo.value = value;
                                },
                                onSubmitted: (value) {
                                  controller.selectedCANo.value = value;
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
                                  controller.selectedCADate.value = value;
                                },
                                onSubmitted: (value) {
                                  controller.selectedCADate.value = value;
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
                                  if (value.isNotEmpty) {
                                    controller.selectedmoldCtrls.value = value;
                                  }
                                },
                                onSubmitted: (value) {
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
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    controller.gsController.text = value;
                                  },
                                  onChanged: (value) {
                                    controller.gsController.text = value;
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

Widget _buildRowField({
  required String label,
  required Widget child,
  required TextStyle labelStyle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: kLabelWidth,
        child: Text(label, style: labelStyle),
      ),
      Expanded(child: child),
    ],
  );
}

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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
              return Padding(
                padding: const EdgeInsets.only(left: 0, top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: boxes,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
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
              Expanded(
                child: Text(
                  label,
                  style: labelStyle,
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Clear',
              ),
            ],
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: boxes,
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    ),
  );
}

class OtpBoxesRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final String allowedPattern; // เช่น r'[0-9]' หรือ r'[A-Za-z0-9#-]'
  final int hyphenIndex;       // ช่องที่จะเป็นขีด (index เริ่มที่ 0), -1 = ไม่มีขีด
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const OtpBoxesRow({
    required this.controllers,
    required this.allowedPattern,
    this.onChanged,
    this.onSubmitted,
    this.hyphenIndex = -1,
  });

  @override
  State<OtpBoxesRow> createState() => _OtpBoxesRowState();
}

class _OtpBoxesRowState extends State<OtpBoxesRow> {
  late final List<FocusNode> _nodes;
  late final List<String> _lastValues;

  bool _isHyphen(int i) => i == widget.hyphenIndex;

  @override
  void initState() {
    super.initState();
    _nodes = List.generate(widget.controllers.length, (_) => FocusNode());
    _lastValues = List.generate(widget.controllers.length, (_) => '');

    // ถ้ามี hyphen ให้เซ็ตค่าเป็น '-' ตั้งแต่แรก
    if (widget.hyphenIndex >= 0 &&
        widget.hyphenIndex < widget.controllers.length) {
      widget.controllers[widget.hyphenIndex].text = '-';
    }

    // sync ค่าเริ่มต้นจาก controller มาที่ _lastValues
    for (var i = 0; i < widget.controllers.length; i++) {
      _lastValues[i] = widget.controllers[i].text;
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  int _nextEditable(int i) {
    var n = i + 1;
    if (n < _nodes.length && _isHyphen(n)) n++; // ข้ามช่องขีด
    return n;
  }

  int _prevEditable(int i) {
    var p = i - 1;
    if (p >= 0 && _isHyphen(p)) p--; // ข้ามช่องขีด
    return p;
  }

  void _moveToNext(int i) {
    final n = _nextEditable(i);
    if (n < _nodes.length) {
      _nodes[n].requestFocus();
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
        // สมมติประมาณ 6 ช่องต่อแถว (ปรับได้ตามดีไซน์)
        final boxSide = (maxW - (spacing * 5)) / 6;
        final side = boxSide.clamp(32.0, 56.0);

        return SizedBox(
          width: maxW,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(widget.controllers.length, (i) {
              final c = widget.controllers[i];
              final isLast = i == lastIndex;

              // ---------- ช่องขีด ----------
              if (_isHyphen(i)) {
                return SizedBox(
                  width: side,
                  height: side,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        '-',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }

              // ---------- ช่องปกติ ----------
              return SizedBox(
                width: side,
                height: side,
                child: TextFormField(
                  focusNode: _nodes[i],
                  controller: c,
                  textAlign: TextAlign.center,
                  textInputAction:TextInputAction.done ,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.allow(regex),
                  ],
                  onTap: () => c.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: c.text.length,
                  ),
                  onChanged: (val) {
                    final was = _lastValues[i];

                    // เคส backspace: เดิมมีตัว → ตอนนี้ว่าง → ย้ายโฟกัสไปช่องก่อนหน้า
                    if (was.isNotEmpty && val.isEmpty) {
                      final p = _prevEditable(i);
                      if (p >= 0) {
                        _nodes[p].requestFocus();
                      }
                      widget.onChanged?.call(_joined());
                      _lastValues[i] = val;
                      return;
                    }

                    // ถ้าพิมพ์ตัวใหม่ → บังคับเป็น uppercase แล้วเลื่อนไปช่องถัดไป
                    if (val.isNotEmpty) {
                      final upper = val.toUpperCase();
                      if (upper != val) {
                        c.value = TextEditingValue(
                          text: upper,
                          selection: TextSelection.collapsed(
                            offset: upper.length,
                          ),
                        );
                      }
                      _moveToNext(i);
                    }

                    widget.onChanged?.call(_joined());

                    // ถ้าทุกช่องไม่ว่างแล้วให้ยิง onSubmitted ด้วย (เช่น auto confirm)
                    if (_allFilled()) {
                      widget.onSubmitted?.call(_joined());
                    }

                    _lastValues[i] = c.text;
                  },
                  // ✅ กด Done จากช่องไหนก็ยิง onSubmitted ได้เลย
                  onFieldSubmitted: (_) {
                    widget.onSubmitted?.call(_joined());
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
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

