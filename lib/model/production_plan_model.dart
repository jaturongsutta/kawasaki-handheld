import 'package:json_annotation/json_annotation.dart';

part 'production_plan_model.g.dart';

@JsonSerializable()
class ProductionPlanModel {
  final String statusName;
  final String lineCd;
  final String? lineName;
  final String planDate;
  final String planStartTime;
  final String planStopTime;
  final String teamName;
  final String shiftPeriodName;
  final String b1;
  final String b2;
  final String b3;
  final String b4;
  final String ot;
  final String modelCd;
  final String cycleTimes;
  final int planTotalTime;
  final int planFgAmt;
  final int actualFgAmt;
  final String status;
  final int id;
  final String? planDt;

  ProductionPlanModel({
    required this.statusName,
    required this.lineCd,
    required this.planDate,
    required this.planStartTime,
    required this.planStopTime,
    required this.teamName,
    required this.shiftPeriodName,
    required this.b1,
    required this.b2,
    required this.b3,
    required this.b4,
    required this.ot,
    required this.modelCd,
    required this.cycleTimes,
    required this.planTotalTime,
    required this.planFgAmt,
    required this.actualFgAmt,
    required this.status,
    required this.id,
    this.planDt,
    this.lineName,
  });

  factory ProductionPlanModel.fromJson(Map<String, dynamic> json) {
    return ProductionPlanModel(
      statusName: json['status_name'] ?? '',
      lineCd: json['Line_CD'] ?? '',
      planDate: json['Plan_Date'] ?? '',
      planStartTime: json['Plan_Start_Time'] ?? '',
      planStopTime: json['Plan_Stop_Time'] ?? '',
      teamName: json['Team_Name'] ?? '',
      shiftPeriodName: json['Shift_Period_Name'] ?? '',
      b1: json['B1'] ?? '',
      b2: json['B2'] ?? '',
      b3: json['B3'] ?? '',
      b4: json['B4'] ?? '',
      ot: json['OT'] ?? '',
      modelCd: json['Model_CD'] ?? '',
      cycleTimes: json['Cycle_Times'] ?? '',
      planTotalTime: json['plan_total_time'] ?? 0,
      planFgAmt: json['plan_fg_amt'] ?? 0,
      actualFgAmt: json['actual_fg_amt'] ?? 0,
      status: json['status'] ?? '',
      id: json['id'] ?? 0,
      planDt: json['plan_dt'],
      lineName: json['Line_Name'], // เพิ่มในกรณีมีอยู่ใน query
    );
  }
}
