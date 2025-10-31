import 'package:json_annotation/json_annotation.dart';

part 'leak_no_plan_model.g.dart';

@JsonSerializable()
class LeakNoPlanModel {
  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Machine_No')
  final String machineNo;

  @JsonKey(name: 'Start_Date')
  final String startDate; // yyyy-MM-dd

  @JsonKey(name: 'Start_Time')
  final String startTime; // HH:mm

  @JsonKey(name: 'End_Date')
  final String endDate; // yyyy-MM-dd

  @JsonKey(name: 'End_Time')
  final String endTime; // HH:mm

  @JsonKey(name: 'Loss_Time')
  final double lossTime; // นาทีหรือชั่วโมง (คุณกำหนดเองได้)

  @JsonKey(name: 'CREATED_DATE')
  final String createdDate; // yyyy-MM-dd HH:mm:ss

  @JsonKey(name: 'CREATED_BY')
  final int createdBy;

  @JsonKey(name: 'UPDATED_DATE')
  final String updatedDate; // yyyy-MM-dd HH:mm:ss

  @JsonKey(name: 'UPDATED_BY')
  final int updatedBy;

  LeakNoPlanModel({
    required this.id,
    required this.machineNo,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.lossTime,
    required this.createdDate,
    required this.createdBy,
    required this.updatedDate,
    required this.updatedBy,
  });

  factory LeakNoPlanModel.fromJson(Map<String, dynamic> json) => _$LeakNoPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakNoPlanModelToJson(this);
}
