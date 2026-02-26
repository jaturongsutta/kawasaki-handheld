import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui';

enum LineType { singleLine, doubleLine }

class OcrLineResult {
  final LineType type;
  final String line1;
  final String? line2;

  OcrLineResult({required this.type, required this.line1, this.line2});

  @override
  String toString() => 'type=$type, line1="$line1", line2="$line2"';
}

class _LineItem {
  final String text;
  final Rect box;

  _LineItem(this.text, this.box);

  double get centerY => box.top + box.height / 2.0;
  double get centerX => box.left + box.width / 2.0;
}

/// ปรับความเข้มงวดด้วยพารามิเตอร์นี้:
/// - minGapFactor: ยิ่งมาก = ต้องห่างกันมากถึงจะนับเป็น 2 บรรทัด
/// - maxLinesToKeep: จำกัดจำนวน line ที่เอามาคิด (กัน noise)
Future<OcrLineResult> detectLineTypeByBoundingBox(
  String imagePath, {
  double minGapFactor = 0.55,
  int maxLinesToKeep = 8,
}) async {
  final recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final input = InputImage.fromFilePath(imagePath);

  final RecognizedText result = await recognizer.processImage(input);
  await recognizer.close();

  // 1) เก็บทุก TextLine ที่มี boundingBox
  final items = <_LineItem>[];
  for (final block in result.blocks) {
    for (final line in block.lines) {
      final t = line.text.trim();
      final b = line.boundingBox;
      if (t.isEmpty) continue;
      if (b.left.isNaN || b.top.isNaN || b.width.isNaN || b.height.isNaN)
        continue;
      if (b.width <= 1 || b.height <= 1) continue;
      items.add(_LineItem(t, b));
    }
  }

  if (items.isEmpty) {
    return OcrLineResult(type: LineType.singleLine, line1: '');
  }

  // 2) กัน noise: ถ้ามี line เยอะ ให้เอาเฉพาะ line ที่ "ใหญ่" (พื้นที่มาก) ก่อน
  items.sort(
    (a, b) =>
        (b.box.width * b.box.height).compareTo(a.box.width * a.box.height),
  );
  final topItems = items.take(min(items.length, maxLinesToKeep)).toList();

  // 3) เรียงตามแกน Y จากบนลงล่าง
  topItems.sort((a, b) => a.centerY.compareTo(b.centerY));

  // 4) คำนวณ "ค่ากลาง" ของความสูงบรรทัด เพื่อใช้เป็น threshold
  final heights = topItems.map((e) => e.box.height).toList()..sort();
  final medianH = heights[heights.length ~/ 2]; // median line height
  final minGap = max(
    6.0,
    medianH * minGapFactor,
  ); // gap threshold (adaptive + min 6px)

  // 5) หา gap Y ที่มากที่สุดระหว่าง line ที่เรียงแล้ว
  double bestGap = 0;
  int bestSplitIndex = -1;

  for (int i = 0; i < topItems.length - 1; i++) {
    final gap = topItems[i + 1].centerY - topItems[i].centerY;
    if (gap > bestGap) {
      bestGap = gap;
      bestSplitIndex = i;
    }
  }

  // 6) ตัดสิน 1 หรือ 2 บรรทัดจาก bestGap
  final isTwoLines = bestGap >= minGap;

  if (!isTwoLines) {
    // ---- SINGLE LINE ----
    // รวมข้อความแบบซ้าย→ขวา (จาก centerX) เพื่อให้เป็นระเบียบ
    final sameLine = [...topItems]
      ..sort((a, b) => a.centerX.compareTo(b.centerX));
    final merged = _mergeTexts(sameLine.map((e) => e.text).toList());

    // fallback: ถ้าข้อความมีเว้นวรรคและรูปแบบคุณมักเป็น 2 บรรทัด
    // (เช่น "A05-015 2606A") ให้แยกเป็น 2 บรรทัดแบบ heuristic
    final parts =
        merged.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 2 &&
        _looksLikeLine1(parts[0]) &&
        _looksLikeLine2(parts[1])) {
      return OcrLineResult(
        type: LineType.doubleLine,
        line1: parts[0],
        line2: parts[1],
      );
    }

    return OcrLineResult(type: LineType.singleLine, line1: merged);
  }

  // ---- DOUBLE LINE ----
  // split เป็น 2 กลุ่ม: [0..bestSplitIndex] กับ [bestSplitIndex+1..]
  final group1 = topItems.sublist(0, bestSplitIndex + 1);
  final group2 = topItems.sublist(bestSplitIndex + 1);

  // เรียงในแต่ละกลุ่มซ้าย→ขวา แล้วรวม text
  group1.sort((a, b) => a.centerX.compareTo(b.centerX));
  group2.sort((a, b) => a.centerX.compareTo(b.centerX));

  final line1 = _mergeTexts(group1.map((e) => e.text).toList());
  final line2 = _mergeTexts(group2.map((e) => e.text).toList());

  // กันเคสกลับด้าน (rare) ถ้า line1 ดูเหมือน line2
  if (_looksLikeLine2(line1) && _looksLikeLine1(line2)) {
    return OcrLineResult(type: LineType.doubleLine, line1: line2, line2: line1);
  }

  return OcrLineResult(type: LineType.doubleLine, line1: line1, line2: line2);
}

String _mergeTexts(List<String> parts) {
  final cleaned =
      parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  // รวมด้วยช่องว่าง 1 ตัว และลด space ซ้ำ
  return cleaned.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// ปรับให้เข้ากับ pattern ของคุณได้
bool _looksLikeLine1(String s) {
  // ตัวอย่างรูปแรก: A05-015 (มี - และตัวอักษร+เลข)
  return RegExp(r'^[A-Z0-9]{1,4}\d{1,3}[-_]\d{1,4}[A-Z0-9]*$').hasMatch(s) ||
      RegExp(r'^[A-Z0-9]{2,}[-_][A-Z0-9]{2,}$').hasMatch(s);
}

bool _looksLikeLine2(String s) {
  // ตัวอย่างรูปแรก: 2606A (เลข 4 ตัว + ตัวอักษรท้าย)
  return RegExp(r'^\d{3,6}[A-Z]{0,2}$').hasMatch(s);
}
