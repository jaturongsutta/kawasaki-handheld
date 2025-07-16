import 'package:get/get.dart';

class DialogController extends GetxController {
  RxBool isDialogOpen = false.obs;

  void toggleDialog() => isDialogOpen.value = !isDialogOpen.value;
}
