import 'package:json_annotation/json_annotation.dart';

part 'production_plan_model.g.dart';

@JsonSerializable()
class ProductionPlanModel {
  @JsonKey(name: 'status_name', defaultValue: '')
  final String statusName;

  @JsonKey(name: 'Line_CD', defaultValue: '')
  final String lineCd;

  @JsonKey(name: 'Line_Name')
  final String? lineName;

  @JsonKey(name: 'Plan_Date', defaultValue: '')
  final String planDate;

  @JsonKey(name: 'Plan_Start_Time', defaultValue: '')
  final String planStartTime;

  @JsonKey(name: 'Plan_Stop_Time', defaultValue: '')
  final String planStopTime;

  @JsonKey(name: 'Team_Name', defaultValue: '')
  final String teamName;

  @JsonKey(name: 'Shift_Period_Name', defaultValue: '')
  final String shiftPeriodName;

  @JsonKey(name: 'B1', defaultValue: '')
  final String b1;

  @JsonKey(name: 'B2', defaultValue: '')
  final String b2;

  @JsonKey(name: 'B3', defaultValue: '')
  final String b3;

  @JsonKey(name: 'B4', defaultValue: '')
  final String b4;

  @JsonKey(name: 'OT', defaultValue: '')
  final String ot;

  @JsonKey(name: 'Model_CD', defaultValue: '')
  final String modelCd;

  // ถ้า backend ส่งเป็น 'cycle_times' ให้เปลี่ยน name ให้ตรง
  @JsonKey(name: 'Cycle_Times', defaultValue: '')
  final String cycleTimes;

  @JsonKey(name: 'plan_total_time', defaultValue: 0)
  final int planTotalTime;

  @JsonKey(name: 'plan_fg_amt', defaultValue: 0)
  final int planFgAmt;

  @JsonKey(name: 'actual_fg_amt', defaultValue: 0)
  final int actualFgAmt;

  // ✅ map NG_Amt -> ngAmt
  @JsonKey(name: 'NG_Amt', defaultValue: 0)
  final int ngAmt;

  @JsonKey(name: 'status', defaultValue: '')
  final String status;

  @JsonKey(name: 'id', defaultValue: 0)
  final int id;

  @JsonKey(name: 'plan_dt')
  final String? planDt;

  @JsonKey(name: 'OT_Value')
  final String? otValue;

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
    this.ngAmt = 0,
    required this.status,
    required this.id,
    this.planDt,
    this.lineName,
    this.otValue,
  });

  factory ProductionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$ProductionPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionPlanModelToJson(this);
}
