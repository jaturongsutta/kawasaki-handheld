import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:bmt_mobile/screen/LoginScreen.dart';
// import 'package:bmt_mobile/services/inject.dart';
// import 'package:bmt_mobile/services/user_service/user_service.dart';
// import 'package:dio/dio.dart' as dio;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:kmt/enum/dialog_type.dart';
import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/services/user_service/user_service.dart';
import 'package:kmt/util/api_config.dart';
import 'package:kmt/util/local_storage_util.dart';
import 'package:kmt/widgets/customLog.dart';
import 'package:stacked_services/stacked_services.dart';

import 'inject.dart';

final dialogService = getIt<DialogService>();
final baseService = getIt<BaseService>();

@lazySingleton
class BaseService {
  Timer? apiRequestTimer; // Timer variable to keep track of the timeout

  Future<dynamic> apiRequest(
    String apiPath, {
    String? endpoint,
    dynamic data,
    Map<String, dynamic>? headers,
    String? title,
    QueryType queryType = QueryType.get,
  }) async {
    try {
      final dio = Dio();

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };

      String? token = await LocalStorage.getLocalStorage(key: 'token');

      endpoint ??= EndpointConfig.currentEndpoint.endpoint;

      apiRequestTimer?.cancel();
      // apiRequestTimer = Timer(const Duration(minutes: 60), () async {
      //   UserService userService = UserService();
      //   await userService.bindLogout();
      //   if (EasyLoading.isShow) {
      //     await EasyLoading.dismiss();
      //   }
      //   await dialogService.showCustomDialog(
      //     variant: DialogType.icon,
      //     description: 'Session Expired',
      //     imageUrl: "assets/svg_images/error.svg",
      //   );
      //   // await Get.offAll(const LoginScreen());
      //   return;
      // });
      if (token != null) {
        // bool hasExpired = JwtDecoder.isExpired(token);
        // if (hasExpired) {
        //   UserService userService = UserService();
        //   await userService.bindLogout();
        //   if (EasyLoading.isShow) {
        //     await EasyLoading.dismiss();
        //     await dialogService.showCustomDialog(
        //       variant: DialogType.icon,
        //       description: 'Error',
        //       imageUrl: "assets/svg_images/error.svg",
        //     );
        //   }
        //   await Get.offAll(const LoginScreen());
        //   return;
        // } else {
        //   headers ??= {
        //     'Content-Type': 'application/json',
        //     'accept': '*/*',
        //     'Authorization': 'Bearer $token',
        //   };
        // }

        headers ??= {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        };
      } else {
        headers ??= {
          'Content-Type': 'application/json',
          'accept': '*/*',
        };
      }

      print(endpoint + apiPath);

      print("token ===> $token");
      logger.i('api ==> ${endpoint + apiPath}');
      logger.i('data ==> $data');

      var response;
      switch (queryType) {
        case QueryType.get:
          response = await dio.get(
            endpoint + apiPath,
            data: data,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case QueryType.post:
          response = await dio.post(
            endpoint + apiPath,
            data: data,
            options: Options(
              headers: headers,
            ),
          );
          break;
      }
      logger.i(response);
      print('response ===> ${response} ');
      if (response.statusCode == 401) {
        // Handle 401 Unauthoriz   Navigator.of(context).pushReplacement(
        print('Unauthorized: Token may be invalid or expired. 401');
        // MaterialPageRoute(
        //   builder: (context) => const LoginScreen(),
        // );

        print('Unauthorized: Token may be invalid or expired.');
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
