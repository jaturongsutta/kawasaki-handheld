
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LineStopInformationController extends GetxController {
  var line = 'Cylinder Head 6'.obs;
  var machineOptions = ['Machine A', 'Machine B', 'Machine C'];
  var selectedMachine = 'Machine A'.obs;

  var stopDate = DateTime.now().obs;
  final stopTimeController = TextEditingController(text: '10:35');
  final lostTimeController = TextEditingController();
  final commentController = TextEditingController();

  var reasonOptions = ['Power Loss', 'Mechanical Failure', 'Other'];
  var selectedReason = 'Other'.obs;

  void saveStop() {
    // TODO: Connect to API or save logic here
    debugPrint('--- Line Stop Info ---');
    debugPrint('Line: ${line.value}');
    debugPrint('Machine: ${selectedMachine.value}');
    debugPrint('Date: ${stopDate.value}');
    debugPrint('Time: ${stopTimeController.text}');
    debugPrint('Lost Time: ${lostTimeController.text}');
    debugPrint('Reason: ${selectedReason.value}');
    debugPrint('Comment: ${commentController.text}');
  }

  @override
  void onClose() {
    stopTimeController.dispose();
    lostTimeController.dispose();
    commentController.dispose();
    super.onClose();
  }
}
