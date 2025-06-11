import 'package:get/get.dart';

class AlertController extends GetxController {
  final alertHistory = <String>[].obs;

  void addAlert(String message) {
    alertHistory.insert(0, message);
  }
}
