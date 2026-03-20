import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/util/api_config.dart';
import 'package:kmt/util/local_storage_util.dart';
import 'package:kmt/widgets/customLog.dart';

import 'inject.dart';

final baseService = getIt<BaseService>();

@lazySingleton
class BaseService {
  static const Duration _requestRefreshLeadTime = Duration(seconds: 30);
  static const Duration _refreshLeadTime = Duration(minutes: 5);

  Timer? _sessionTimer;
  Completer<String?>? _refreshCompleter;
  bool _isHandlingSessionEnd = false;

  Future<void> startSession({
    required String token,
    Map<String, dynamic>? user,
    String? selectedLine,
  }) async {
    final box = GetStorage();
    await _saveToken(token);
    box.write('token', token);
    box.write('isLoggedIn', true);
    if (user != null) {
      box.write('user', user);
    }
    if (selectedLine != null && selectedLine.isNotEmpty) {
      box.write('selectedLine', selectedLine);
    }
    _startSessionTimer(token);
  }

  Future<bool> restoreSessionFromStorage() async {
    try {
      String? token = await _getStoredToken();
      if (token == null || token.trim().isEmpty) {
        return false;
      }

      token = token.trim();
      final remaining = _remainingDurationFromToken(token);
      if (remaining == null || remaining <= _requestRefreshLeadTime) {
        final refreshed =
            await refreshAccessToken(force: true, currentToken: token);
        if ((refreshed ?? '').trim().isNotEmpty) {
          token = refreshed!.trim();
        }
      }

      final finalRemaining = _remainingDurationFromToken(token);
      if (finalRemaining == null || finalRemaining <= Duration.zero) {
        await _clearSessionStorage();
        return false;
      }

      GetStorage().write('isLoggedIn', true);
      _startSessionTimer(token);
      return true;
    } catch (e) {
      logger.e('[session][restore.error] $e');
      await _clearSessionStorage();
      return false;
    }
  }

  Future<void> logout({
    bool redirectToLogin = true,
    bool showExpiredMessage = false,
  }) async {
    if (_isHandlingSessionEnd) {
      return;
    }
    _isHandlingSessionEnd = true;
    try {
      _sessionTimer?.cancel();
      _sessionTimer = null;
      _refreshCompleter = null;
      await _clearSessionStorage();
      if (showExpiredMessage) {
        await EasyLoading.showInfo('Session หมดเวลา กรุณาเข้าสู่ระบบใหม่');
      }
      if (redirectToLogin && Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } finally {
      _isHandlingSessionEnd = false;
    }
  }

  Future<void> _handleSessionExpired() async {
    await logout(
      redirectToLogin: true,
      showExpiredMessage: true,
    );
  }

  void _startSessionTimer(String token) {
    _sessionTimer?.cancel();
    final remaining = _remainingDurationFromToken(token);
    if (remaining == null || remaining <= Duration.zero) {
      scheduleMicrotask(() async {
        await _handleSessionExpired();
      });
      return;
    }
    _sessionTimer = Timer(remaining, () async {
      await _handleSessionExpired();
    });
  }

  Duration? _remainingDurationFromToken(String token) {
    try {
      final payload = _decodeJwtPayload(token);
      if (payload == null) {
        return null;
      }
      final exp = payload['exp'];
      if (exp == null) {
        return null;
      }
      final seconds = exp is int ? exp : int.tryParse(exp.toString());
      if (seconds == null) {
        return null;
      }
      final expDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return expDate.difference(DateTime.now());
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return null;
      }
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) {
        return json;
      }
      if (json is Map) {
        return Map<String, dynamic>.from(json);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _requiresAuth(String apiPath) {
    return apiPath != '/user/login' &&
        apiPath != '/auth/login' &&
        apiPath != '/auth/refresh-token';
  }

  dio.Dio _createDioClient() {
    final dioClient = dio.Dio();
    dioClient.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
    return dioClient;
  }

  Future<dio.Response> _executeRequest(
    dio.Dio client, {
    required String apiPath,
    required String endpoint,
    required QueryType queryType,
    required dynamic data,
    required Map<String, dynamic> headers,
  }) async {
    switch (queryType) {
      case QueryType.get:
        return client.get(
          endpoint + apiPath,
          queryParameters: data,
          options: dio.Options(headers: headers),
        );
      case QueryType.post:
        return client.post(
          endpoint + apiPath,
          data: data,
          options: dio.Options(headers: headers),
        );
    }
  }

  dynamic _decodeResponseData(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    final decoded = _decodeResponseData(data);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  Future<void> _saveToken(String token) async {
    await LocalStorage.setLocalStorage(key: 'token', object: token);
  }

  Future<String?> _getStoredToken() async {
    final token = await LocalStorage.getLocalStorage(key: 'token');
    if (token is String && token.trim().isNotEmpty) {
      return token.trim();
    }
    final tokenFromBox = GetStorage().read('token');
    if (tokenFromBox is String && tokenFromBox.trim().isNotEmpty) {
      return tokenFromBox.trim();
    }
    return null;
  }

  Future<void> _clearSessionStorage() async {
    final box = GetStorage();
    await LocalStorage.removeLocalStorage(key: 'token');
    box.remove('token');
    box.remove('isLoggedIn');
    await box.erase();
  }

  Future<String?> refreshAccessToken({
    bool force = false,
    String? currentToken,
  }) async {
    Completer<String?>? ownerCompleter;
    try {
      String token = (currentToken ?? await _getStoredToken() ?? '').trim();
      if (token.isEmpty) {
        return null;
      }

      if (!force) {
        final remaining = _remainingDurationFromToken(token);
        if (remaining != null && remaining > _refreshLeadTime) {
          return token;
        }
      }

      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        return _refreshCompleter!.future;
      }

      ownerCompleter = Completer<String?>();
      _refreshCompleter = ownerCompleter;

      final dioClient = _createDioClient();
      final endpoint = EndpointConfig.currentEndpoint.endpoint;

      final response = await dioClient.get(
        '$endpoint/auth/refresh-token',
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final json = _asMap(response.data);
      final status = json?['status'];
      final accessToken = (json?['accessToken'] ?? '').toString().trim();
      final isSuccess = status == 0 ||
          status == '0' ||
          status == true ||
          (status is String && status.toLowerCase() == 'success');
      if (!isSuccess || accessToken.isEmpty) {
        if (!ownerCompleter.isCompleted) {
          ownerCompleter.complete(null);
        }
        return null;
      }

      await _saveToken(accessToken);
      GetStorage().write('token', accessToken);
      _startSessionTimer(accessToken);
      if (!ownerCompleter.isCompleted) {
        ownerCompleter.complete(accessToken);
      }
      return accessToken;
    } catch (e) {
      logger.e('[session][refresh.error] $e');
      if (ownerCompleter != null && !ownerCompleter.isCompleted) {
        ownerCompleter.complete(null);
      }
      return null;
    } finally {
      if (ownerCompleter != null &&
          identical(_refreshCompleter, ownerCompleter)) {
        _refreshCompleter = null;
      }
    }
  }

  Future<dynamic> apiRequest(
    String apiPath, {
    String? endpoint,
    dynamic data,
    Map<String, dynamic>? headers,
    String? title,
    QueryType queryType = QueryType.get,
  }) async {
    try {
      final dio.Dio dioClient = _createDioClient();
      endpoint ??= EndpointConfig.currentEndpoint.endpoint;
      logger.i('api ==> ${endpoint + apiPath}');

      final requiresAuth = _requiresAuth(apiPath);
      String token = (await _getStoredToken() ?? '').trim();
      if (requiresAuth && token.isNotEmpty) {
        final remaining = _remainingDurationFromToken(token);
        if (remaining == null || remaining <= _requestRefreshLeadTime) {
          final refreshed =
              await refreshAccessToken(force: true, currentToken: token);
          if ((refreshed ?? '').trim().isNotEmpty) {
            token = refreshed!.trim();
          }
        }
      }

      headers ??= {
        'Content-Type': 'application/json',
        'accept': '*/*',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      logger.i('data ==> $data');

      dio.Response response = await _executeRequest(
        dioClient,
        apiPath: apiPath,
        endpoint: endpoint,
        queryType: queryType,
        data: data,
        headers: headers,
      );

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed =
            await refreshAccessToken(force: true, currentToken: token);
        if ((refreshed ?? '').trim().isNotEmpty) {
          final retryHeaders = Map<String, dynamic>.from(headers);
          retryHeaders['Authorization'] = 'Bearer ${refreshed!.trim()}';
          final retryResponse = await _executeRequest(
            dioClient,
            apiPath: apiPath,
            endpoint: endpoint,
            queryType: queryType,
            data: data,
            headers: retryHeaders,
          );
          if (retryResponse.statusCode == 200 ||
              retryResponse.statusCode == 201) {
            return _decodeResponseData(retryResponse.data);
          }
          return _decodeResponseData(retryResponse.data);
        }
        await _handleSessionExpired();
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _decodeResponseData(response.data);
      }

      print(response.statusMessage);
      return _decodeResponseData(response.data);
    } catch (e) {
      print('catch base_service ===> $e');
      EasyLoading.dismiss();
      return null;
    }
  }
}
