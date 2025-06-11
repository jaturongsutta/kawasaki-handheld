import 'package:get/get.dart';

class ProductionStatusModel {
  final String line;
  final String planDate;
  final String shift;
  final String shiftTime;
  final String ot;
  final String model;
  final String status;

  ProductionStatusModel({
    required this.line,
    required this.planDate,
    required this.shift,
    required this.shiftTime,
    required this.ot,
    required this.model,
    required this.status,
  });
}

class ProductionStatusListController extends GetxController {
  var statusList = <ProductionStatusModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }

  void fetchStatus() {
    statusList.value = [
      ProductionStatusModel(
        line: 'Cylinder Head 6',
        planDate: '03/04/2025 08:00',
        shift: 'Team A',
        shiftTime: 'Day (08:00 - 20:00)',
        ot: 'Yes OT',
        model: 'EX400',
        status: 'Running',
      ),
      ProductionStatusModel(
        line: 'Cylinder Head 6',
        planDate: '03/04/2025 20:00',
        shift: 'Team B',
        shiftTime: 'Night (20:00 - 08:00)',
        ot: 'No',
        model: 'EX400',
        status: 'Next Production',
      ),
    ];
  }
}
