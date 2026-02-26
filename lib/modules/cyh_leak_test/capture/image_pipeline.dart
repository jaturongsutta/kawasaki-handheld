import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

class ImagePipeline {
  static Uint8List cropJpegBytes({
    required Uint8List srcBytes,
    required int x,
    required int y,
    required int w,
    required int h,
  }) {
    final decoded = img.decodeImage(srcBytes);
    if (decoded == null) throw Exception('Cannot decode image');

    final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    return Uint8List.fromList(img.encodeJpg(cropped, quality: 95));
  }

  static Future<Uint8List> compressToMaxBytes({
    required Uint8List input,
    required int maxBytes,
  }) async {
    int quality = 95;
    Uint8List out = input;

    while (out.lengthInBytes > maxBytes && quality >= 20) {
      final compressed = await FlutterImageCompress.compressWithList(
        out,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      out = Uint8List.fromList(compressed);
      quality -= 8;
    }

    if (out.lengthInBytes > maxBytes) {
      final compressed = await FlutterImageCompress.compressWithList(
        out,
        quality: 35,
        minWidth: 1200,
        minHeight: 1200,
        format: CompressFormat.jpeg,
      );
      out = Uint8List.fromList(compressed);
    }

    return out;
  }
}
