import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path_provider/path_provider.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import '../services/ocr_service.dart';
import 'package:image/image.dart' as img;

class OcrController extends GetxController {
  final OcrService service;
  OcrController(this.service);

  final isReady = false.obs;
  final isBusy = false.obs;
  final recognizedText = ''.obs;

  CameraController? cam;
  late List<CameraDescription> _cameras;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _prepare();
  }

  Future<void> _prepare() async {
    isBusy.value = true;

    // ขอสิทธิ์กล้อง
    await [Permission.camera].request();

    // เตรียมกล้อง
    _cameras = await availableCameras();
    cam = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cam!.initialize();

    // คัดลอก eng.traineddata ไปยังโฟลเดอร์เขียนได้ (ครั้งแรก)
    await service.ensureTrainedData('eng');

    isReady.value = true;
    isBusy.value = false;
  }

  Future<void> captureAndOcr() async {
    if (cam == null || !cam!.value.isInitialized) return;
    isBusy.value = true;
    try {
      final shot = await cam!.takePicture();
      final processedPath = await _preprocessImage(shot.path);
      final text = await _runTesseract(processedPath);
      recognizedText.value = text.trim();
    } finally {
      isBusy.value = false;
    }
  }

  Future<String> _preprocessImage(String inputPath) async {
    final tempDir = await getTemporaryDirectory();
    final outPath = '${tempDir.path}/ocr_preprocessed.png';

    // อ่านภาพจากไฟล์
    final bytes = await File(inputPath).readAsBytes();
    final src = img.decodeImage(bytes)!;

    final gray = img.grayscale(src);

    final hist = List<int>.filled(256, 0);
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        final p = gray.getPixel(x, y);
        final luma = img.getLuminance(p);
        hist[luma.toInt()]++; // ✅ แปลงเป็น int
      }
    }

    int sum = 0, count = 0;
    for (var i = 0; i < 256; i++) {
      sum += i * hist[i];
      count += hist[i];
    }
    final avg = count == 0 ? 128 : (sum ~/ count).toInt();

    final bin = img.Image.from(gray);
    for (var y = 0; y < bin.height; y++) {
      for (var x = 0; x < bin.width; x++) {
        final p = bin.getPixel(x, y);
        final luma = img.getLuminance(p);
        final color = luma < avg ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255);
        bin.setPixel(x, y, color);
      }
    }

    final outBytes = img.encodePng(bin);
    await File(outPath).writeAsBytes(outBytes);

    return outPath;
  }

  Future<String> _runTesseract(String imagePath) async {
    try {
      print('imagePath ===> $imagePath');
      final text = await TesseractOcr.extractText(imagePath);
      return text ?? '';
    } catch (e) {
      print('eerrrorr===> $e');
      return 'Error';
    }
  }

  @override
  void onClose() {
    cam?.dispose();
    super.onClose();
  }
}
