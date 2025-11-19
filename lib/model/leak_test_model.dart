import 'package:json_annotation/json_annotation.dart';

part 'leak_test_model.g.dart';

@JsonSerializable()
class LeakTestModel {
  @JsonKey(name: 'Mapped_Plan_ID', defaultValue: '')
  final int mappedPlanId;

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

  @JsonKey(name: 'UPDATED_BY')
  final int updatedBy;

  @JsonKey(name: 'GS_No')
  final String gsNo;

  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'NG_Id')
  final String ngId;

  @JsonKey(name: 'Plan_Id')
  final int planId;

  @JsonKey(name: 'Mold_No')
  final String moldNo;

  @JsonKey(name: 'CA_No')
  final String caNo;

  @JsonKey(name: 'CA_Date')
  final String caDate;

  LeakTestModel(
      {required this.mappedPlanId,
      required this.machineNo,
      required this.workType,
      required this.modelCd,
      required this.serialNo,
      required this.scanDate,
      required this.createdBy,
      required this.updatedBy,
      required this.gsNo,
      required this.lineCd,
      required this.ngId,
      required this.planId,
      required this.moldNo,
      required this.caDate,
      required this.caNo});

  factory LeakTestModel.fromJson(Map<String, dynamic> json) =>
      _$LeakTestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakTestModelToJson(this);
}
