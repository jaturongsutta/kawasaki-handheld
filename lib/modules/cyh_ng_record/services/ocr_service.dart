import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class OcrService {
  /// คัดลอกไฟล์ traineddata จาก assets ไปยังโฟลเดอร์เขียนได้ (ครั้งแรก)
  Future<String> ensureTrainedData(String lang) async {
    final dir = await getApplicationDocumentsDirectory();
    final tessDir = Directory('${dir.path}/tessdata');
    if (!await tessDir.exists()) {
      await tessDir.create(recursive: true);
    }

    final target = File('${tessDir.path}/$lang.traineddata');
    if (!await target.exists()) {
      final bytes = await rootBundle.load('assets/tessdata/$lang.traineddata');
      await target.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }
    return dir.path; // คืน path โฟลเดอร์หลัก (มี sub dir tessdata อยู่แล้ว)
  }
}
