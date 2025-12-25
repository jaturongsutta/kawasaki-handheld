// lib/app/views/ocr_view.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// ---------- LOGIC SPACE ----------
const int SCREEN_WIDTH = 320;
const int SCREEN_HEIGHT = 480;
const Rect kType1RectLogical = Rect.fromLTWH(20, 190, 280, 100);

/// interval การสแกนแบบอัตโนมัติ (ms)
const int kAutoScanIntervalMs = 700;

/// งานที่ต้องการอ่าน (ไว้ใช้กรองแพทเทิร์น)
enum OcrMode { castingDate6, mcDate18, no2, serial11, mold12, machine5 }

class OcrView extends StatefulWidget {
  final OcrMode mode;
  const OcrView({super.key, required this.mode});

  @override
  State<OcrView> createState() => _OcrViewState();
}

class _OcrViewState extends State<OcrView> with WidgetsBindingObserver {
  CameraController? _camera;
  bool _isReady = false;
  bool _torchOn = false;

  // แสดงผล
  String _detectedText = ''; // raw text จาก OCR
  String _candidate = ''; // text ที่ตรงแพทเทิร์น (ถ้าเจอ)

  late final TextRecognizer _textRecognizer;

  // จับภาพหน้าจอเฉพาะกรอบแดง
  final GlobalKey _screenKey = GlobalKey();

  // Auto-scan timer
  Timer? _scanTimer;
  bool _scanBusy = false;

  // กันกด Enter / Continue ซ้ำ ๆ
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _init();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    try {
      _camera?.setFlashMode(FlashMode.off);
    } catch (_) {}
    _camera?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _init() async {
    final perm = await Permission.camera.request();
    if (!perm.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ต้องอนุญาตสิทธิ์กล้อง')),
        );
      }
      return;
    }

    final cams = await availableCameras();
    if (cams.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบกล้องบนอุปกรณ์')),
        );
      }
      return;
    }

    _camera = CameraController(
      cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      ),
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _camera!.initialize();

    if (mounted) setState(() => _isReady = true);

    // เริ่มสแกนอัตโนมัติจาก “หน้าจอเฉพาะกรอบ”
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: kAutoScanIntervalMs),
      (_) async {
        if (!mounted || _scanBusy || _finishing) return;
        _scanBusy = true;
        try {
          await _captureScreenRoiAndOcr();
        } finally {
          _scanBusy = false;
        }
      },
    );
  }

  Future<void> _toggleTorch() async {
    if (_camera == null) return;
    try {
      await _camera!.setFlashMode(_torchOn ? FlashMode.off : FlashMode.torch);
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สลับแฟลชไม่สำเร็จ: $e')),
      );
    }
  }

  /// ===== OCR จาก "ภาพหน้าจอในกรอบแดง" (Real-time) =====
  Future<void> _captureScreenRoiAndOcr() async {
    try {
      // 1) จับภาพทั้ง Stack
      final boundary = _screenKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return; // ยังวาดไม่เสร็จ

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final ui.Image uiImg = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await uiImg.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      // 2) คำนวณพิกัดกรอบบนพิกเซลจริง
      final renderBox =
          _screenKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size; // dp
      final wRatio = size.width / SCREEN_WIDTH;
      final hRatio = size.height / SCREEN_HEIGHT;

      final rectDp = Rect.fromLTWH(
        kType1RectLogical.left * wRatio,
        kType1RectLogical.top * hRatio,
        kType1RectLogical.width * wRatio,
        kType1RectLogical.height * hRatio,
      );

      final rectPx = Rect.fromLTWH(
        rectDp.left * pixelRatio,
        rectDp.top * pixelRatio,
        rectDp.width * pixelRatio,
        rectDp.height * pixelRatio,
      );

      // 3) ครอปเฉพาะกรอบ
      final decoded = img.decodePng(pngBytes);
      if (decoded == null) return;

      // clamp ให้ไม่เกินขอบภาพ
      final left = rectPx.left.clamp(0, decoded.width.toDouble() - 1);
      final top = rectPx.top.clamp(0, decoded.height.toDouble() - 1);
      final right = rectPx.right.clamp(1, decoded.width.toDouble());
      final bottom = rectPx.bottom.clamp(1, decoded.height.toDouble());

      final w = (right - left).clamp(1, decoded.width.toDouble()).round();
      final h = (bottom - top).clamp(1, decoded.height.toDouble()).round();

      final cropped = img.copyCrop(
        decoded,
        x: left.round(),
        y: top.round(),
        width: w,
        height: h,
      );

      // 4) เขียนไฟล์ temp แล้ว OCR ด้วย MLKit
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/screen_roi_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(outPath).writeAsBytes(img.encodePng(cropped), flush: true);

      final input = InputImage.fromFilePath(outPath);
      final result = await _textRecognizer.processImage(input);
      final rawText = result.text.trim();

      if (!mounted) return;

      if (rawText.isNotEmpty) {
        // เก็บ raw และ candidate (จะกรองตอนกด Continue)
        setState(() {
          _detectedText = rawText;
          _candidate = rawText;
        });
      }
    } catch (_) {
      // เงียบเพื่อให้สแกนรอบถัดไป
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;

    try {
      await _camera?.setFlashMode(FlashMode.off);
    } catch (_) {}

    if (!mounted) return;

    final out = _extractPattern(widget.mode, _candidate) ?? _candidate;
    Navigator.of(context).pop(out);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modeLabel = {
      OcrMode.castingDate6: 'Scan Casting Date',
      OcrMode.mcDate18: 'Scan M/C Date',
      OcrMode.no2: 'Scan No. (2 digits)',
      OcrMode.serial11: 'Scan Serial (12-34-56#4A)',
      OcrMode.mold12: 'Scan Mold No',
      OcrMode.machine5: 'Scan Machine (เช่น KMT-7)',
    }[widget.mode]!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(modeLabel)),

      // ✅ จับ Enter / NumpadEnter จาก hardkey แล้วเรียก _finish()
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final k = event.logicalKey;
            if (k == LogicalKeyboardKey.enter ||
                k == LogicalKeyboardKey.numpadEnter) {
              _finish();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: RepaintBoundary(
          key: _screenKey,
          child: Stack(
            children: [
              // กล้อง: ใช้เล็งอย่างเดียว (ไม่สตรีมเข้า MLKit)
              Positioned.fill(
                child: _camera == null
                    ? const SizedBox()
                    : FullscreenCameraPreview(controller: _camera!),
              ),

              // มาส์กดำทึบ + กรอบแดง
              Positioned.fill(
                child: CustomPaint(
                  painter: _OverlayPainter(
                    detectedText:
                        _candidate.isEmpty ? _detectedText : _candidate,
                  ),
                ),
              ),

              // แผงผลลัพธ์ด้านล่าง
              Positioned(
                left: 12,
                right: 12,
                bottom: 94,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'พบ: ${_candidate.isEmpty ? '-' : _candidate}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _detectedText,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ปุ่มล่าง (แฟลช / Continue)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        minimum: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'flash',
              onPressed: _toggleTorch,
              icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
              label: Text(_torchOn ? 'แฟลช: เปิด' : 'แฟลช: ปิด'),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              heroTag: 'ok',
              onPressed: _finish,
              icon: const Icon(Icons.check),
              label: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== กรองแพทเทิร์นตามงาน =====
  String? _extractPattern(OcrMode mode, String plain) {
    final text = plain.toUpperCase();
    switch (mode) {
      case OcrMode.castingDate6:
        return RegExp(r'\b\d{2}-\d{2}-\d{2}#[A-Z0-9]{2}\b')
            .firstMatch(text)
            ?.group(0);
      case OcrMode.mcDate18:
        return RegExp(r'\b\d{2}-\d{2}-\d{2}#[A-Z0-9]{2}\b')
            .firstMatch(text)
            ?.group(0);
      case OcrMode.no2:
        return RegExp(r'\b\d{2}\b').firstMatch(text)?.group(0);
      case OcrMode.serial11:
        // รูปแบบ 12-34-56#4A
        return RegExp(r'\b\d{2}-\d{2}-\d{2}#[A-Z0-9]{2}\b')
            .firstMatch(text)
            ?.group(0);
      case OcrMode.mold12:
        // ตัวอย่าง K9,3
        return RegExp(r'\b[A-Z0-9][0-9],[0-9]\b')
            .firstMatch(text)
            ?.group(0);
      case OcrMode.machine5:
        // ตัวอย่าง KMT-7
        return RegExp(r'\b[A-Z0-9]{3}-[A-Z0-9]\b')
            .firstMatch(text)
            ?.group(0);
    }
  }
}

/// ===== กล้องเต็มจอ (ตอนนี้ใช้ CameraPreview ตรง ๆ) =====
class FullscreenCameraPreview extends StatelessWidget {
  final CameraController controller;
  const FullscreenCameraPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CameraPreview(controller);
  }
}

/// ===== มาส์กดำทึบ + กรอบแดง =====
class _OverlayPainter extends CustomPainter {
  final String detectedText;
  _OverlayPainter({required this.detectedText});

  final Paint _rectPaint = Paint()
    ..color = Colors.red.withOpacity(0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final Paint _maskPaint = Paint()..color = Colors.black.withOpacity(0.65);

  final TextPainter _tp = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    final wRatio = size.width / SCREEN_WIDTH;
    final hRatio = size.height / SCREEN_HEIGHT;

    final rect = Rect.fromLTWH(
      kType1RectLogical.left * wRatio,
      kType1RectLogical.top * hRatio,
      kType1RectLogical.width * wRatio,
      kType1RectLogical.height * hRatio,
    );

    // มาส์กดำทึบ (นอกกรอบทั้งหมด)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, rect.top), _maskPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, rect.top, rect.left, rect.height), _maskPaint);
    canvas.drawRect(
        Rect.fromLTWH(rect.right, rect.top, size.width - rect.right, rect.height),
        _maskPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, rect.bottom, size.width, size.height - rect.bottom),
        _maskPaint);

    // กรอบสีแดง
    canvas.drawRect(rect, _rectPaint);

    // ข้อความ debug ด้านบน
    final textOffset = Offset(20 * wRatio, 100 * hRatio);
    _tp.text = TextSpan(
      style: const TextStyle(color: Colors.red, fontSize: 16),
      text: detectedText,
    );
    _tp.layout(maxWidth: size.width - textOffset.dx - 16);
    _tp.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.detectedText != detectedText;
}
