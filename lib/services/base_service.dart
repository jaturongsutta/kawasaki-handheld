import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:bmt_mobile/screen/LoginScreen.dart';
// import 'package:bmt_mobile/services/inject.dart';
// import 'package:bmt_mobile/services/user_service/user_service.dart';
// import 'package:dio/dio.dart' as dio;

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:kmt/enum/dialog_type.dart';
import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/util/api_config.dart';
import 'package:kmt/util/local_storage_util.dart';
import 'package:kmt/widgets/customLog.dart';
import 'package:stacked_services/stacked_services.dart';

import 'inject.dart';

final dialogService = getIt<DialogService>();
final baseService = getIt<BaseService>();

@lazySingleton
class BaseService {
  Timer? _idleTimer;
  static const Duration idleTimeout = Duration(minutes: 60);

  void _startIdleTimer() {
    print('bumpIdle');
    _idleTimer?.cancel(); // ยกเลิกตัวเดิมก่อน
    _idleTimer = Timer(idleTimeout, _onSessionExpired);
  }

  void bumpIdle() => _startIdleTimer();

  void _onSessionExpired() async {
    _idleTimer?.cancel();
    final box = Get.find<GetStorage>();
    if (EasyLoading.isShow) {
      await EasyLoading.dismiss();
    }

    await dialogService.showCustomDialog(
      variant: DialogType.icon,
      data: {
        'icon': const Icon(
          Icons.warning,
          color: Colors.red,
          size: 52,
        ),
      },
      description: 'Session Expired',
    );

    await box.erase();
    Get.offAllNamed('/login');
  }

  Future<dynamic> apiRequest(
    String apiPath, {
    String? endpoint,
    dynamic data,
    Map<String, dynamic>? headers,
    String? title,
    QueryType queryType = QueryType.get,
  }) async {
    final box = GetStorage();
    final user = box.read('user');
    if (user != null) {
      _startIdleTimer();
    }

    try {
      final dio.Dio dioClient = dio.Dio();

      (dioClient.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };

      String? token = await LocalStorage.getLocalStorage(key: 'token');
      endpoint ??= EndpointConfig.currentEndpoint.endpoint;

      headers ??= {
        'Content-Type': 'application/json',
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      logger.i('api ==> ${endpoint + apiPath}');
      logger.i('data ==> $data');

      dio.Response response;
      switch (queryType) {
        case QueryType.get:
          response = await dioClient.get(
            endpoint + apiPath,
            queryParameters: data, // ⚠️ สำหรับ GET ใช้ queryParameters
            options: dio.Options(headers: headers),
          );
          break;
        case QueryType.post:
          response = await dioClient.post(
            endpoint + apiPath,
            data: data,
            options: dio.Options(headers: headers),
          );
          break;
      }

      if (response.statusCode == 401) {
        print('Unauthorized: Token may be invalid or expired.');
        // อาจเรียก logout() ได้ที่นี่
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.toString());
      } else {
        print(response.statusMessage);
      }
    } catch (e) {
      print('catch base_service ===> $e');
      EasyLoading.dismiss();
    }
  }
}
