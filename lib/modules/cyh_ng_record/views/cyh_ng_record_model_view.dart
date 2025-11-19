import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';

import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/modules/cyh_leak_test/widgets/tab_selector.dart';
import 'package:kmt/modules/cyh_ng_record/controllers/cyh_ng_record_model_controller.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class CYHNGRecordModelView extends GetView<CYHNGRecordModelController> {
  CYHNGRecordModelView({super.key});

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
        title: const Text('NG Leak Test',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Obx(() {
        return KeyenceScanner(
          onBarcodeScanned: (String scannedCode) {
            // if (scannedCode.isNotEmpty) {
            //   controller.selectedMCDate.value = scannedCode;
            //   controller.getGSCount();
            //   controller.checkIsEnabledButton();
            // }
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
                                    absorbing: false,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: false,
                                      value: controller
                                          .selectedModel.value?.modelCd,
                                      items: controller.models
                                          .map((m) => m.modelCd)
                                          .toSet() // <-- ตรงนี้แปลงเป็น Set เพื่อกันซ้ำ
                                          .map((cd) => DropdownMenuItem<String>(
                                                value: cd,
                                                child: Text(cd ?? ''),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final model =
                                              controller.models.firstWhere(
                                            (m) => m.modelCd == val,
                                            orElse: () => const LeakTestNgModel(
                                                // id: 0,
                                                // lineCd: '',
                                                // lineName: '',
                                                // modelCd: '',
                                                // partNo: '',
                                                ),
                                          );
                                          controller.selectedModel.value =
                                              model;
                                          controller.selectedSerial.value =
                                              null;
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
                                const SizedBox(height: 12),
                                _LabeledField(
                                  label: 'M/C Date',
                                  child: AbsorbPointer(
                                    absorbing: false,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: false,
                                      value: controller
                                          .selectedSerial.value?.serial,
                                      items: controller.models
                                          .where((e) =>
                                              e.modelCd ==
                                              controller
                                                  .selectedModel.value?.modelCd)
                                          .map((e) => e.serial)
                                          .toList()
                                          .toSet()
                                          .map((cd) => DropdownMenuItem<String>(
                                                value: cd,
                                                child: Text(cd ?? ''),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final serial =
                                              controller.models.firstWhere(
                                            (m) =>
                                                m.modelCd ==
                                                    controller.selectedModel
                                                        .value?.modelCd &&
                                                m.serial == val,
                                            orElse: () => const LeakTestNgModel(
                                                // id: 0,
                                                // lineCd: '',
                                                // lineName: '',
                                                // modelCd: '',
                                                // partNo: '',
                                                ),
                                          );
                                          controller.selectedSerial.value =
                                              serial;
                                          controller.checkIsEnabledButton();
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

class OtpBoxesRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final String allowedPattern; // เช่น r'[0-9]' หรือ r'[A-Za-z0-9]'
  final int hyphenIndex; // ช่องที่จะเป็นขีด (index เริ่มที่ 0), -1 = ไม่มีขีด
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

    // ถ้ามี hyphen ให้ set ก่อน
    if (widget.hyphenIndex >= 0 &&
        widget.hyphenIndex < widget.controllers.length) {
      widget.controllers[widget.hyphenIndex].text = '-';
    }

    // 🔥 สำคัญ: sync ค่าเริ่มต้นจาก controller มาที่ _lastValues
    for (var i = 0; i < widget.controllers.length; i++) {
      _lastValues[i] = widget.controllers[i].text;
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) n.dispose();
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
        final boxSide =
            ((maxW) - (spacing * 5)) / 6; // สมมติ 6 ช่อง/แถว ปรับได้
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
                  textInputAction:
                      isLast ? TextInputAction.done : TextInputAction.next,
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

                    // ❶ เคส backspace: เดิมมีตัว → ตอนนี้ว่าง → ย้ายโฟกัสไปช่องก่อนหน้า (แต่ไม่ลบช่องก่อนหน้า)
                    if (was.isNotEmpty && val.isEmpty) {
                      final p = _prevEditable(i);
                      if (p >= 0) {
                        _nodes[p].requestFocus();
                      }
                      widget.onChanged?.call(_joined());
                      _lastValues[i] = val;
                      return;
                    }

                    // ❷ พิมพ์ตัวใหม่ → ทำเป็น UPPERCASE แล้วขยับไปช่องถัดไป
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
                    if (_allFilled()) widget.onSubmitted?.call(_joined());

                    _lastValues[i] = c.text; // เก็บไว้เทียบรอบหน้า
                  },
                  onFieldSubmitted: (_) {
                    if (isLast) widget.onSubmitted?.call(_joined());
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
