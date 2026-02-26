import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kmt/util/api_config.dart';
import 'package:path_provider/path_provider.dart';

class OcrService {
  final Dio dio;

  OcrService()
      : dio = Dio(
          BaseOptions(
            baseUrl: EndpointConfig.currentEndpoint.endpointOCR,
            headers: {
              'Authorization':
                  'Bearer ${EndpointConfig.currentEndpoint.bearerTokenOCR}',
            },
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(minutes: 2),
          ),
        );

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

  Future<String> uploadImage({
    required String endpointPath,
    required File file,
    String ocrModel = 'model1',
  }) async {
    try {
      final form = FormData.fromMap({
        'image_file':
            await MultipartFile.fromFile(file.path, filename: 'crop.jpg'),
        'ocr_model': ocrModel,
      });
      print('object');
      print('uploadImage');
      final res = await dio.post(
        endpointPath,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      print('object');

      print('res ===> $res');
      final data = res.data;
      if (data is Map) {
        if (data['text'] != null) {
          return data['text'].toString();
        }
        final inner = data['data'];
        if (inner is Map && inner['text'] != null) {
          return inner['text'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['detail'] != null) {
          return data['detail'].toString();
        }
      }
      return data.toString();
    } on DioException catch (e) {
      print('error ===> $e');
      final data = e.response?.data;
      if (data is Map) {
        if (data['detail'] != null) {
          return data['detail'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      return e.message ?? e.toString();
    }
  }
}
