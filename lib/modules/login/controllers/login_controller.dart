import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/model/user_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/services/inject.dart';
import 'package:kmt/widgets/customLog.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final selectedLine = ''.obs;
  final MethodChannel _channel = const MethodChannel('factory_alert_channel');
  static const MethodChannel _methodChannel = MethodChannel('factory_alert_service');

  final box = GetStorage();
  final lineList = <String>[].obs;
  final baseService = getIt<BaseService>();

  void login() async {
    // Get.offAllNamed('/menu');
    // return;

    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedLine.value.isEmpty) {
      Get.snackbar('Error', 'Please enter username, password, and select a line');
      return;
    }

    isLoading.value = true;

    try {
      final encodeData = jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'lineCd': selectedLine.value,
      });

      final response = await await baseService.apiRequest('/user/login',
          data: encodeData, queryType: QueryType.post);

      final result = response;

      if (result['result']) {
        final user = UserModel.fromJson(result['data']);

        box.write('isLoggedIn', true);
        box.write('user', user.toJson());
        box.write('selectedLine', selectedLine.value);
        await sendLineCDToNative(selectedLine.value, user.username); // ✅ ส่งไป Native
        await _startService(); // ✅ สั่งเปิด Service บนอุปกรณ์

        Get.offAllNamed('/menu');
      } else {
        Get.snackbar('Login Failed', result['message'] ?? 'Invalid login',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e, s) {
      logger.i('starce ===> $s');
      Get.snackbar('Error', 'Connection failed: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void loadLines() async {
    try {
      final response = await baseService.apiRequest('/user/lines', queryType: QueryType.post);

      if (response['result']) {
        lineList.assignAll(List<String>.from(response['data']));
        selectedLine.value = lineList.first;
      } else {
        Get.snackbar('Error', 'Failed to load lines');
      }
    } catch (e, s) {
      logger.i('starce ===> $s');
      logger.i('error ===> $e');

      Get.snackbar('Error', 'Cannot load line list: $e');
    }
  }

  Future<void> sendLineCDToNative(String lineCd, String username) async {
    try {
      await _channel.invokeMethod('setLineCD', {
        'lineCd': lineCd,
        'username': username, // ✅ เพิ่ม username ไปด้วย
      });
      print("✅ ส่ง lineCD ไปยัง Native สำเร็จ: $lineCd");
    } catch (e) {
      print("❌ ไม่สามารถส่ง lineCD ไป Native ได้: $e");
    }
  }

  Future<void> _startService() async {
    try {
      await _methodChannel.invokeMethod('startService');
      print("✅ Service started");
    } on PlatformException catch (e) {
      print("❌ ไม่สามารถเริ่ม Service: ${e.message}");
    }
  }
}
