import 'package:json_annotation/json_annotation.dart';

part 'plan_search_model.g.dart';

@JsonSerializable()
class PlanSearchModel {
  @JsonKey(name: 'Row_Num')
  final dynamic rowNum;

  @JsonKey(name: 'Line_CD', defaultValue: '')
  final String lineCd;

  @JsonKey(name: 'Plan_Date', defaultValue: '')
  final String planDate;

  @JsonKey(name: 'Plan_Start_Time', defaultValue: '')
  final String planStartTime;

  @JsonKey(name: 'Plan_Stop_Time')
  final String? planStopTime;

  @JsonKey(name: 'Team_Name', defaultValue: '')
  final String teamName;

  @JsonKey(name: 'Shift_Period_Name', defaultValue: '')
  final String shiftPeriodName;

  @JsonKey(name: 'B1', defaultValue: 'N')
  final String b1;

  @JsonKey(name: 'B2', defaultValue: 'N')
  final String b2;

  @JsonKey(name: 'B3', defaultValue: 'N')
  final String b3;

  @JsonKey(name: 'B4', defaultValue: 'N')
  final String b4;

  @JsonKey(name: 'OT', defaultValue: '')
  final String ot;

  @JsonKey(name: 'Model_CD', defaultValue: '')
  final String modelCd;

  // ถ้า BE ส่งเป็น 'cycle_times' ให้เปลี่ยน name ให้ตรง
  @JsonKey(name: 'Cycle_Times', defaultValue: '')
  final String cycleTimes;

  @JsonKey(name: 'plan_total_time', defaultValue: 0)
  final int planTotalTime;

  @JsonKey(name: 'plan_fg_amt', defaultValue: 0)
  final int planFgAmt;

  @JsonKey(name: 'actual_fg_amt', defaultValue: 0)
  final int actualFgAmt;

  // ✅ เปลี่ยนมาใช้ NG_Amt ตามที่ขอ
  @JsonKey(name: 'NG_Amt', defaultValue: 0)
  final int ngAmt;

  @JsonKey(name: 'line_stop_amt', defaultValue: 0)
  final int lineStopAmt;

  @JsonKey(name: 'status', defaultValue: '')
  final String status;

  @JsonKey(name: 'status_name', defaultValue: '')
  final String statusName;

  @JsonKey(name: 'updated_by', defaultValue: '')
  final String updatedBy;

  @JsonKey(name: 'updated_date', defaultValue: '')
  final String updatedDate;

  @JsonKey(name: 'id', defaultValue: 0)
  final int id;

  @JsonKey(name: 'OT_Value')
  final String? otValue;

  const PlanSearchModel({
    required this.rowNum,
    required this.lineCd,
    required this.planDate,
    required this.planStartTime,
    this.planStopTime,
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
    required this.ngAmt,
    required this.lineStopAmt,
    required this.status,
    required this.statusName,
    required this.updatedBy,
    required this.updatedDate,
    required this.id,
    this.otValue,
  });

  factory PlanSearchModel.fromJson(Map<String, dynamic> json) => _$PlanSearchModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanSearchModelToJson(this);
}
