import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/capture/constants.dart';
import 'package:kmt/modules/cyh_leak_test/capture/ocr_menu_config.dart';

import 'capture_controller.dart';
import 'overlay_painter.dart';

class CaptureView extends GetView<CaptureController> {
  const CaptureView({super.key});

  static Widget withConfig() {
    const config = OcrMenuConfig(
      id: 't1',
      title: 'Scan M/C Date',
      minBytes: 1,
      maxBytes: 250 * 1024,
      endpointPath: '/scan_text/',
      cropLogicalRect: kType1RectLogical,
      resolutionPreset: ResolutionPreset.low,
    );

    return GetBuilder<CaptureController>(
      init: CaptureController(config),
      builder: (_) => const CaptureView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.config.title)),
      body: Obx(() {
        if (!controller.isReady.value || controller.cam == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final preview = controller.previewBytes.value;

        final Widget content = (preview != null)
            ? const _PreviewPane()
            : _CameraPane(cam: controller.cam!);

        return Stack(
          children: [
            Positioned.fill(child: content),

            // Loading overlay
            if (controller.isBusy.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _CameraPane extends GetView<CaptureController> {
  final CameraController cam;
  const _CameraPane({required this.cam});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(cam)),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: OverlayPainter(
                detectedText: controller.detectedText.value,
                cropLogicalRect: controller.config.cropLogicalRect,
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Flash toggle (ซ้าย)
                  Expanded(
                    child: Obx(() {
                      final on = controller.isTorchOn.value;
                      return ElevatedButton.icon(
                        onPressed: controller.isBusy.value
                            ? null
                            : controller.toggleTorch,
                        icon: Icon(on ? Icons.flash_on : Icons.flash_off),
                        label: Text(on ? 'ปิดแฟลช' : 'เปิดแฟลช'),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),

                  // Capture (ขวา)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isBusy.value
                          ? null
                          : controller.snapCropAndUpload,
                      icon: const Icon(Icons.camera),
                      label: const Text('ถ่ายภาพ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewPane extends GetView<CaptureController> {
  const _PreviewPane();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bytes = controller.previewBytes.value;
      if (bytes == null) return const SizedBox.shrink();

      final raw = controller.detectedText.value;
      final text = raw.trim();
      final hasValue = text.isNotEmpty;

      // ถ้าไม่มีค่า ให้โชว์เป็น "-"
      final displayText = hasValue ? text : '-';

      return Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),

          // ======= RESULT PANEL: โชว์เสมอ =======
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'ผลลัพธ์',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      // copy เฉพาะตอนมีค่า
                      if (hasValue)
                        IconButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: text));
                            Get.snackbar(
                              'คัดลอกแล้ว',
                              'คัดลอกผลลัพธ์ไปยังคลิปบอร์ด',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'คัดลอก',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        displayText,
                        textAlign: TextAlign.left,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======= ACTIONS =======
          Padding(
            padding: const EdgeInsets.all(16),
            child: hasValue
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isBusy.value
                              ? null
                              : controller.clearPreview,
                          child: const Text('ถ่ายใหม่'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.isBusy.value
                              ? null
                              : () {
                                  // ✅ ยืนยัน: ส่งค่ากลับหน้าก่อน
                                  Get.back(result: text);
                                },
                          child: const Text('ยืนยัน'),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.isBusy.value
                          ? null
                          : controller.clearPreview,
                      child: const Text('ถ่ายใหม่'),
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
