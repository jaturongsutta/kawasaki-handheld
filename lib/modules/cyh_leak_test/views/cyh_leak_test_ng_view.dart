import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/controllers/cyh_leak_test_ng_controller.dart';
import 'package:flutter/services.dart';
import 'package:kmt/modules/cyh_leak_test/views/ocr_view.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class CYHLeakTestNGView extends GetView<CYHLeakTestNGController> {
  const CYHLeakTestNGView({super.key});

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    // ✅ ระยะด้านล่างเมื่อคีย์บอร์ดโผล่ (ใช้ดัน ScrollView ขึ้น)
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      // ✅ เปิดให้เลื่อนอัตโนมัติเวลาเปิดคีย์บอร์ด
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'NG Leak Test',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    // ✅ กันโดนคีย์บอร์ดทับ
                    padding: EdgeInsets.only(bottom: bottomInset + 16),
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
                                  controller.dataModel.value?.machineNo ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                labelStyle: labelStyle,
                              ),
                              const SizedBox(height: 8),

                              // ================= Model =================
                              _buildRowField(
                                label: 'Model',
                                child: Text(
                                  controller.dataModel.value?.modelCd ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                labelStyle: labelStyle,
                              ),
                              const SizedBox(height: 8),

                              // ================= Serial =================
                              _buildRowField(
                                label: 'Serial',
                                child: Text(
                                  controller.dataModel.value?.serialNo ??
                                      controller.dataModel.value?.serial ??
                                      "",
                                  style: const TextStyle(fontSize: 16),
                                ),
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
                                    controller.dataModel.value?.ngP1 ?? '',
                                    controller.hexToColor(
                                      controller.dataModel.value?.ngP1Color ??
                                          '#FFFFFF',
                                    ),
                                  ),
                                  _resultButton(
                                    controller.dataModel.value?.ngP2 ?? '',
                                    controller.hexToColor(
                                      controller.dataModel.value?.ngP2Color ??
                                          '#FFFFFF',
                                    ),
                                  ),
                                  _resultButton(
                                    controller.dataModel.value?.ngP3 ?? '',
                                    controller.hexToColor(
                                      controller.dataModel.value?.ngP3Color ??
                                          '#FFFFFF',
                                    ),
                                  ),
                                  _resultButton(
                                    controller.dataModel.value?.ngP4 ?? '',
                                    controller.hexToColor(
                                      controller.dataModel.value?.ngP4Color ??
                                          '#FFFFFF',
                                    ),
                                  ),
                                  _resultButton(
                                    controller.dataModel.value?.ngTb ?? '',
                                    controller.hexToColor(
                                      controller.dataModel.value?.ngTbColor ??
                                          '#FFFFFF',
                                    ),
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
                                controllers: controller.caNoCtrls.sublist(0, 3),
                                allowedPattern: r'[0-9]',
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    controller.selectedCANo.value = value;
                                    controller.checkIsEnabledButton();
                                  }
                                },
                                onSubmitted: (value) {
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
                                controllers:
                                    controller.castingDateCtrls.sublist(0, 6),
                                allowedPattern: r'[A-Za-z0-9#-]',
                                hyphenIndex: 2,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    controller.selectedcastingDate.value =
                                        value;
                                    controller.checkIsEnabledButton();
                                  }
                                },
                                onSubmitted: (value) {
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
                                  if (value.isNotEmpty) {
                                    controller.selectedmoldCtrls.value = value;
                                    controller.checkIsEnabledButton();
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    controller.selectedmoldCtrls.value = value;
                                    controller.checkIsEnabledButton();
                                  }
                                },
                              ),
                            ],
                          ),
                          onScan: () => controller.scanAndFill(OcrMode.mold12),
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
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: controller.goToLeakTest,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.orange.shade200,
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: const Text('Later'),
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

// ====== OtpBoxesRow (Done ทุกช่อง + auto move) ======
class OtpBoxesRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final String allowedPattern; // เช่น r'[0-9]' หรือ r'[A-Za-z0-9#-]'
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

    if (widget.hyphenIndex >= 0 &&
        widget.hyphenIndex < widget.controllers.length) {
      widget.controllers[widget.hyphenIndex].text = '-';
    }

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
    if (n < _nodes.length && _isHyphen(n)) n++;
    return n;
  }

  int _prevEditable(int i) {
    var p = i - 1;
    if (p >= 0 && _isHyphen(p)) p--;
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
    const spacing = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
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

              return SizedBox(
                width: side,
                height: side,
                child: TextFormField(
                  focusNode: _nodes[i],
                  controller: c,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
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

                    if (was.isNotEmpty && val.isEmpty) {
                      final p = _prevEditable(i);
                      if (p >= 0) {
                        _nodes[p].requestFocus();
                      }
                      widget.onChanged?.call(_joined());
                      _lastValues[i] = val;
                      return;
                    }

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

                    if (_allFilled()) {
                      widget.onSubmitted?.call(_joined());
                    }

                    _lastValues[i] = c.text;
                  },
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
