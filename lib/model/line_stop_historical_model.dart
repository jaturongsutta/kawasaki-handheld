import 'package:json_annotation/json_annotation.dart';

part 'line_stop_historical_model.g.dart';

@JsonSerializable()
class LineStopHistoricalRecordModel {
  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'Process_CD')
  final String? processCd;

  @JsonKey(name: 'Line_Stop_Date')
  final String? lineStopDate;

  @JsonKey(name: 'Line_Stop_Time')
  final String? lineStopTime;

  @JsonKey(name: 'Loss_Time', defaultValue: 0)
  final int lossTime;

  @JsonKey(name: 'reason')
  final String? reasonCode;

  @JsonKey(name: 'Reason_name')
  final String? reasonName;

  final String? comment;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'Status_Name')
  final String? statusName;

  @JsonKey(name: 'Type')
  final String? type;

  @JsonKey(name: 'ID_Ref')
  final int? idRef;

  @JsonKey(name: 'plan_total_time', defaultValue: 0)
  final int planTotalTime;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'Plan_Date')
  final String? planDate;

  @JsonKey(name: 'Plan_Start_Time')
  final String? planStartTime;

  @JsonKey(name: 'Plan_Stop_Time')
  final String? planStopTime;

  @JsonKey(name: 'Team_Name')
  final String? teamName;

  @JsonKey(name: 'Model_CD')
  final String? modelCd;

  @JsonKey(name: 'Updated_By')
  final String? updatedBy;

  @JsonKey(name: 'Updated_Date')
  final String? updatedDate;

  LineStopHistoricalRecordModel({
    required this.lineCd,
    this.processCd,
    this.lineStopDate,
    this.lineStopTime,
    required this.lossTime,
    this.reasonCode,
    this.reasonName,
    this.comment,
    this.status,
    this.statusName,
    this.type,
    this.idRef,
    required this.planTotalTime,
    required this.id,
    this.planDate,
    this.planStartTime,
    this.planStopTime,
    this.teamName,
    this.modelCd,
    this.updatedBy,
    this.updatedDate,
  });

  factory LineStopHistoricalRecordModel.fromJson(Map<String, dynamic> json) =>
      _$LineStopHistoricalRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$LineStopHistoricalRecordModelToJson(this);
}
