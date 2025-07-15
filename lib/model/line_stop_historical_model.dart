import 'package:json_annotation/json_annotation.dart';

part 'line_stop_historical_model.g.dart';

@JsonSerializable()
class LineStopHistoricalRecordModel {
  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'Plan_Date')
  final String planDate;

  @JsonKey(name: 'Plan_Start_Time')
  final String planStartTime;

  @JsonKey(name: 'Team_Name')
  final String? teamName; // เปลี่ยนเป็น nullable

  @JsonKey(name: 'Model_CD')
  final String? modelCd;

  @JsonKey(name: 'Process_CD')
  final String? processCd;

  @JsonKey(name: 'NG_Date')
  final String ngDate;

  @JsonKey(name: 'NG_Time')
  final String ngTime;

  final int quantity;

  @JsonKey(name: 'Reason_name')
  final String? reasonName; // เปลี่ยนเป็น nullable

  final String? comment; // เปลี่ยนเป็น nullable

  @JsonKey(name: 'Status_Name')
  final String? statusName; // เปลี่ยนเป็น nullable

  LineStopHistoricalRecordModel({
    required this.lineCd,
    required this.planDate,
    required this.planStartTime,
    this.teamName,
    this.modelCd,
    this.processCd,
    required this.ngDate,
    required this.ngTime,
    required this.quantity,
    this.reasonName,
    this.comment,
    this.statusName,
  });

  factory LineStopHistoricalRecordModel.fromJson(Map<String, dynamic> json) =>
      _$LineStopHistoricalRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$LineStopHistoricalRecordModelToJson(this);
}
