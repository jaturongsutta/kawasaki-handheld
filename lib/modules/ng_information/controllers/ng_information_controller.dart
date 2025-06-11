import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NgInformationController extends GetxController {
  var line = 'Cylinder Head 6'.obs;
  var model = 'EX400'.obs;

  final partNoController = TextEditingController(text: '1000203-09475');
  final partUpperController = TextEditingController(text: '1000003-00475');
  final partLowerController = TextEditingController(text: '1000013-08985');
  final ngDate = DateTime.now().obs;
  final ngTimeController = TextEditingController(text: '10:35');
  final quantityController = TextEditingController(text: '1');
  final commentController = TextEditingController();

  var reasonOptions = ['Blow Hole', 'Crack', 'Scratch', 'Other'];
  var selectedReason = 'Blow Hole'.obs;

  void save() {
    // TODO: implement save logic
    print('NG Saved: ${partNoController.text}, Reason: ${selectedReason.value}');
  }

  @override
  void onClose() {
    partNoController.dispose();
    partUpperController.dispose();
    partLowerController.dispose();
    ngTimeController.dispose();
    quantityController.dispose();
    commentController.dispose();
    super.onClose();
  }
}
