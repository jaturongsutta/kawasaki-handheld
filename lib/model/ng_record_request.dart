import 'package:json_annotation/json_annotation.dart';

part 'ng_record_request.g.dart';

@JsonSerializable()
class NgRecordRequest {
  final int planId;
  final String lineCd;
  final String processCd;
  final String ngDate;
  final String ngTime;
  final int quantity;
  final String reason;
  final String comment;
  final int createdBy;

  NgRecordRequest({
    required this.planId,
    required this.lineCd,
    required this.processCd,
    required this.ngDate,
    required this.ngTime,
    required this.quantity,
    required this.reason,
    required this.comment,
    required this.createdBy,
  });

  factory NgRecordRequest.fromJson(Map<String, dynamic> json) => _$NgRecordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$NgRecordRequestToJson(this);
}
