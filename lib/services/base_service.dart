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

  int _idleGen = 0;
  DateTime? _idleExpiresAt;

  void bumpIdle() => _startIdleTimer();

  void _startIdleTimer() {
    // 1) log ก่อน cancel
    if (_idleTimer?.isActive ?? false) {
      debugPrint('[idle] cancel timer(gen: $_idleGen) active=true');
    } else {
      debugPrint('[idle] no active timer to cancel (gen: $_idleGen)');
    }

    // 2) cancel timer เดิม
    _idleTimer?.cancel();

    // 3) เพิ่ม generation เพื่อกัน timer เก่าที่ยังยิง (เผื่อ timing race)
    _idleGen++;
    final myGen = _idleGen;

    // 4) เก็บเวลาหมดอายุไว้ debug
    _idleExpiresAt = DateTime.now().add(idleTimeout);
    debugPrint('[idle] start timer(gen: $myGen) expiresAt: $_idleExpiresAt');

    // 5) สร้าง timer ใหม่
    _idleTimer = Timer(idleTimeout, () {
      if (myGen != _idleGen) {
        debugPrint('[idle] skip stale timer fire (myGen: $myGen, currentGen: $_idleGen)');
        return;
      }
      debugPrint('[idle] timer fired (gen: $myGen) at: ${DateTime.now()}');
      _onSessionExpired();
    });
  }

  void debugIdleState() {
    debugPrint('[idle] active=${_idleTimer?.isActive ?? false}, '
        'gen=$_idleGen, expiresAt=$_idleExpiresAt, instance=${identityHashCode(this)}');
  }

  void cancelIdleTimer() {
    if (_idleTimer?.isActive ?? false) {
      debugPrint('[idle] manual cancel timer(gen: $_idleGen)');
    }
    _idleTimer?.cancel();
    _idleTimer = null;
    _idleExpiresAt = null;
  }

  void _onSessionExpired() async {
    cancelIdleTimer();
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
    print('askdaksdas');
    if (user != null) {
      _startIdleTimer();
    }

    try {
      print('bbbbb');

      final dio.Dio dioClient = dio.Dio();

      (dioClient.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };

      String? token = await LocalStorage.getLocalStorage(key: 'token');
      endpoint ??= EndpointConfig.currentEndpoint.endpoint;
      logger.i('api ==> ${endpoint + apiPath}');

      headers ??= {
        'Content-Type': 'application/json',
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };

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
