import 'package:json_annotation/json_annotation.dart';

part 'line_stop_record_request.g.dart';

@JsonSerializable()
class LineStopRecordRequest {
  final int planId;
  final String lineCd;
  final String processCd;
  final String lineStopDate;
  final String lineStopTime;
  final int lossTime;
  final String reason;
  final String comment;
  final int createdBy;

  LineStopRecordRequest({
    required this.planId,
    required this.lineCd,
    required this.processCd,
    required this.lineStopDate,
    required this.lineStopTime,
    required this.lossTime,
    required this.reason,
    required this.comment,
    required this.createdBy,
  });

  factory LineStopRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$LineStopRecordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LineStopRecordRequestToJson(this);
}
