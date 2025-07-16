import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kmt/enum/dialog_type.dart';
import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/provider/login_provider.dart';
import 'package:kmt/services/inject.dart';
import 'package:stacked_services/stacked_services.dart';

import '../base_service.dart';

class UserService {
  LoginProvider loginProvider = LoginProvider();

  Future<bool> login(String userName, String passWord) async {
    await EasyLoading.show();
    try {
      final baseService = getIt<BaseService>();
      final dialogService = getIt<DialogService>();

      var data = {"username": userName, "password": passWord};

      var response = await baseService.apiRequest(
        '/auth/loginMobile',
        data: data,
        queryType: QueryType.post,
      );
      EasyLoading.dismiss();
      if (response != null) {
        if (response['status'] == 0) {
          if (response['token'] != null && response['user'] != null) {
            loginProvider.savelogin(response);
            return true;
          }
        } else {
          await dialogService.showCustomDialog(
            variant: DialogType.icon,
            description: 'Error: Response status is ${response['message']}.',
            imageUrl: "assets/svg_images/error.svg",
          );
        }
      } else {
        await dialogService.showCustomDialog(
          variant: DialogType.icon,
          description: 'Error: No response from server.',
          imageUrl: "assets/svg_images/error.svg",
        );
      }
      return false;
    } catch (e) {
      await dialogService.showCustomDialog(
        variant: DialogType.icon,
        description: 'Error: $e',
        imageUrl: "assets/svg_images/error.svg",
      );
      return false;
    }
  }

  bindLogout() async {
    loginProvider.logout();
  }
}
