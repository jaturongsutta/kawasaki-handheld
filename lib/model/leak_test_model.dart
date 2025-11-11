import 'package:json_annotation/json_annotation.dart';

part 'leak_test_model.g.dart';

@JsonSerializable()
class LeakTestModel {
  @JsonKey(name: 'Mapped_Plan_ID', defaultValue: '')
  final String mappedPlanId;

  @JsonKey(name: 'Machine_No')
  final String machineNo;

  @JsonKey(name: 'Work_Type')
  final String workType;

  @JsonKey(name: 'Model_CD')
  final String modelCd;

  @JsonKey(name: 'Serial_No')
  final String serialNo;

  @JsonKey(name: 'Scan_Date')
  final String scanDate;

  @JsonKey(name: 'CREATED_BY')
  final int createdBy;

  @JsonKey(name: 'GS_No')
  final String gsNo;

  LeakTestModel({
    required this.mappedPlanId,
    required this.machineNo,
    required this.workType,
    required this.modelCd,
    required this.serialNo,
     required this.scanDate,
      required this.createdBy,
       required this.gsNo,
  });

  factory LeakTestModel.fromJson(Map<String, dynamic> json) =>
      _$LeakTestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakTestModelToJson(this);
}
