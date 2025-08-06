import 'package:get/get.dart';

class LoadingController extends GetxController {
  final isLoading = false.obs;

  void showLoading() => isLoading.value = true;

  void hideLoading() => isLoading.value = false;
}
