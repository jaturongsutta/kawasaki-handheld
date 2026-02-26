import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/capture/constants.dart';
import 'package:kmt/modules/cyh_leak_test/capture/ocr_menu_config.dart';
import 'package:kmt/modules/cyh_leak_test/services/check_line_service.dart';
import 'package:kmt/modules/cyh_leak_test/services/ocr_service.dart';
import 'package:path_provider/path_provider.dart';

import 'image_pipeline.dart';

class CaptureController extends GetxController {
  final OcrMenuConfig config;
  CaptureController(this.config);

  final ocrService = OcrService();

  final isReady = false.obs;
  final isBusy = false.obs;
  final isTorchOn = false.obs;

  final detectedText = ''.obs;
  final previewBytes = Rxn<Uint8List>();
  final previewRawBytes = Rxn<Uint8List>();
  final previewFile = Rxn<File>();

  CameraController? cam;

  @override
  void onInit() {
    super.onInit();
    _initCam();
  }

  Future<void> _initCam() async {
    final cams = await availableCameras();
    final back = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );

    cam = CameraController(
      back,
      config.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await cam!.initialize();

    // ป้องกันบางเครื่องค้าง flash mode
    try {
      await cam!.setFlashMode(FlashMode.off);
      isTorchOn.value = false;
    } catch (_) {}

    isReady.value = true;
  }

  @override
  void onClose() {
    // ปิด torch กันไฟค้าง
    try {
      cam?.setFlashMode(FlashMode.off);
    } catch (_) {}
    cam?.dispose();
    super.onClose();
  }

  Future<void> toggleTorch() async {
    if (cam == null || !cam!.value.isInitialized) return;
    if (isBusy.value) return;

    try {
      final nextOn = !isTorchOn.value;
      await cam!.setFlashMode(nextOn ? FlashMode.torch : FlashMode.off);
      isTorchOn.value = nextOn;
    } catch (e) {
      Get.snackbar(
        'Flash',
        'เปิด/ปิดแฟลชไม่ได้: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ถ่าย -> crop -> compress -> upload OCR อัตโนมัติ (ไม่เซฟแกลเลอรี)
  Future<void> snapCropAndUpload() async {
    if (cam == null || !cam!.value.isInitialized) return;
    if (isBusy.value) return;

    isBusy.value = true;
    detectedText.value = '';

    // clear preview เก่า
    previewBytes.value = null;
    previewRawBytes.value = null;
    previewFile.value = null;

    try {
      // 1) ถ่าย
      final xfile = await cam!.takePicture();
      final rawBytes = await File(xfile.path).readAsBytes();
      previewRawBytes.value = rawBytes;

      // 2) map logical rect -> pixel rect
      final decodedSize = await _getImageSize(rawBytes);
      final cropPx = _mapLogicalToPixelRect(
        logical: config.cropLogicalRect,
        imageW: decodedSize.$1,
        imageH: decodedSize.$2,
      );

      // 3) crop
      final cropped = ImagePipeline.cropJpegBytes(
        srcBytes: rawBytes,
        x: cropPx.left.toInt(),
        y: cropPx.top.toInt(),
        w: cropPx.width.toInt(),
        h: cropPx.height.toInt(),
      );

      // 4) compress
      final compressed = await ImagePipeline.compressToMaxBytes(
        input: cropped,
        maxBytes: config.maxBytes,
      );

      // 5) เขียนไฟล์ temp เพื่อใช้ upload
      final uploadFile = await _writeTemp(
        compressed,
        fileName: "ocr_${config.id}_crop.jpg",
      );

      // set preview เป็นรูปที่ crop+compress แล้ว
      previewBytes.value = compressed;
      previewFile.value = uploadFile;

      final res = await detectLineTypeByBoundingBox(uploadFile.path);

      String ocrModel = config.ocrModel;

      if (res.type == LineType.doubleLine) {
        ocrModel = 'model_all';
        print("2 บรรทัด: ${res.line1} / ${res.line2}");
      } else {
        print("1 บรรทัด: ${res.line1}");
      }

      // 6) Upload OCR
      final text = await ocrService.uploadImage(
        endpointPath: config.endpointPath,
        file: uploadFile,
        ocrModel: ocrModel,
      );

      detectedText.value = text;
    } catch (e) {
      detectedText.value = 'ERROR: $e';
    } finally {
      isBusy.value = false;
    }
  }

  void clearPreview() {
    previewBytes.value = null;
    previewRawBytes.value = null;
    previewFile.value = null;
    detectedText.value = '';
  }

  Future<(int, int)> _getImageSize(Uint8List bytes) async {
    final im = await decodeImageFromList(bytes);
    return (im.width, im.height);
  }

  Rect _mapLogicalToPixelRect({
    required Rect logical,
    required int imageW,
    required int imageH,
  }) {
    final x = logical.left / SCREEN_WIDTH * imageW;
    final y = logical.top / SCREEN_HEIGHT * imageH;
    final w = logical.width / SCREEN_WIDTH * imageW;
    final h = logical.height / SCREEN_HEIGHT * imageH;

    final left = x.clamp(0, imageW.toDouble() - 1).toDouble();
    final top = y.clamp(0, imageH.toDouble() - 1).toDouble();
    final width = w.clamp(1, imageW.toDouble() - left).toDouble();
    final height = h.clamp(1, imageH.toDouble() - top).toDouble();

    return Rect.fromLTWH(left, top, width, height);
  }

  Future<File> _writeTemp(Uint8List bytes, {String? fileName}) async {
    final dir = await getTemporaryDirectory();
    final fallback = 'ocr_${config.id}.jpg';
    final safeName = _normalizeFileName(fileName ?? fallback);
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _normalizeFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      return 'ocr_${config.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
    final lower = trimmed.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png')) {
      return trimmed;
    }
    return '$trimmed.jpg';
  }
}
