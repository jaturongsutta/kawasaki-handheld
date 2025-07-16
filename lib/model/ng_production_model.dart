import 'package:json_annotation/json_annotation.dart';

part 'ng_production_model.g.dart';

@JsonSerializable()
class NGProductionPlanModel {
  @JsonKey(name: 'status_name', defaultValue: '')
  final String statusName;

  @JsonKey(name: 'Line_CD', defaultValue: '')
  final String lineCd;

  @JsonKey(name: 'Line_Name', defaultValue: '')
  final String lineName;

  @JsonKey(name: 'Plan_Date', defaultValue: '')
  final String planDate;

  @JsonKey(name: 'Plan_Start_Time', defaultValue: '')
  final String planStartTime;

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

  @JsonKey(name: 'Cycle_Times', defaultValue: '')
  final String cycleTimes;

  @JsonKey(name: 'plan_total_time')
  final int planTotalTime;

  @JsonKey(name: 'plan_fg_amt')
  final int planFgAmt;

  @JsonKey(name: 'actual_fg_amt')
  final int actualFgAmt;

  @JsonKey(name: 'status', defaultValue: '')
  final String status;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'Part_No', defaultValue: '')
  final String partNo;

  @JsonKey(name: 'Part_1', defaultValue: '')
  final String part1;

  @JsonKey(name: 'Part_2', defaultValue: '')
  final String part2;

  NGProductionPlanModel({
    required this.statusName,
    required this.lineCd,
    required this.lineName,
    required this.planDate,
    required this.planStartTime,
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
    required this.partNo,
    required this.part1,
    required this.part2,
  });

  factory NGProductionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$NGProductionPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$NGProductionPlanModelToJson(this);
}
