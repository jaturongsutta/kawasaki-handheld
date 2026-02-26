import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class OcrMenuConfig {
  final String id;
  final String title;
  final int minBytes;
  final int maxBytes;
  final String endpointPath;
  final String ocrModel;
  final Rect cropLogicalRect;
  final ResolutionPreset resolutionPreset;

  const OcrMenuConfig({
    required this.id,
    required this.title,
    required this.minBytes,
    required this.maxBytes,
    required this.endpointPath,
    this.ocrModel = 'model_all',
    required this.cropLogicalRect,
    required this.resolutionPreset,
  });
}
