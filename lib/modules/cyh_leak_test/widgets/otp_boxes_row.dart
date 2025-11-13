import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
