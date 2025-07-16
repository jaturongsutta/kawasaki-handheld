import 'package:json_annotation/json_annotation.dart';

part 'ng_record_model.g.dart';

@JsonSerializable()
class NgRecordModel {
  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'Plan_Date')
  final String planDate;

  @JsonKey(name: 'Plan_Date_Stop')
  final String planDateStop;

  @JsonKey(name: 'Plan_Start_Time')
  final String planStartTime;

  @JsonKey(name: 'Plan_Stop_Time')
  final String planStopTime;

  @JsonKey(name: 'Team_Name')
  final String teamName;

  @JsonKey(name: 'Shift_Period_Name')
  final String shiftPeriodName;

  @JsonKey(name: 'B1')
  final String b1;

  @JsonKey(name: 'B2')
  final String b2;

  @JsonKey(name: 'B3')
  final String b3;

  @JsonKey(name: 'B4')
  final String b4;

  @JsonKey(name: 'OT')
  final String ot;

  @JsonKey(name: 'Model_CD')
  final String modelCd;

  @JsonKey(name: 'Cycle_Times')
  final String cycleTimes;

  @JsonKey(name: 'plan_total_time')
  final int planTotalTime;

  @JsonKey(name: 'plan_fg_amt')
  final int planFgAmt;

  @JsonKey(name: 'actual_fg_amt')
  final int? actualFgAmt;

  @JsonKey(name: 'ng_amt')
  final int? ngAmt;

  @JsonKey(name: 'line_stop')
  final int lineStop;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'status_name')
  final String statusName;

  @JsonKey(name: 'Updated_By')
  final String updatedBy;

  @JsonKey(name: 'Updated_Date')
  final String updatedDate;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'part_no')
  final String partNo;

  @JsonKey(name: 'Part_Upper')
  final String partUpper;

  @JsonKey(name: 'Part_Lower')
  final String? partLower;

  NgRecordModel({
    required this.lineCd,
    required this.planDate,
    required this.planDateStop,
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
    required this.ngAmt,
    required this.lineStop,
    required this.status,
    required this.statusName,
    required this.updatedBy,
    required this.updatedDate,
    required this.id,
    required this.partNo,
    required this.partUpper,
    required this.partLower,
  });

  factory NgRecordModel.fromJson(Map<String, dynamic> json) => _$NgRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$NgRecordModelToJson(this);
}
