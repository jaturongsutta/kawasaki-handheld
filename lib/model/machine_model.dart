import 'package:json_annotation/json_annotation.dart';

part 'machine_model.g.dart';

@JsonSerializable()
class MachineModel {
  @JsonKey(name: 'Line_CD')
  final String? lineCd;

  @JsonKey(name: 'Model_CD')
  final String? modelCd;

  @JsonKey(name: 'Machine_No')
  final String machineNo;

  @JsonKey(name: 'Process_CD')
  final String? processCd;

  @JsonKey(name: 'WT')
  final String? wt; // เปลี่ยนจาก num เป็น String

  @JsonKey(name: 'HT')
  final String? ht;

  @JsonKey(name: 'MT')
  final String? mt;

  @JsonKey(name: 'is_Active')
  final String? isActive;

  @JsonKey(name: 'CREATED_DATE')
  final String? createdDate;

  @JsonKey(name: 'CREATED_BY')
  final String? createdBy;

  @JsonKey(name: 'UPDATED_DATE')
  final String? updatedDate;

  @JsonKey(name: 'UPDATED_BY')
  final String? updatedBy;

  MachineModel({
    this.lineCd,
    this.modelCd,
    required this.machineNo,
    this.processCd,
    this.wt,
    this.ht,
    this.mt,
    this.isActive,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => _$MachineModelFromJson(json);
  Map<String, dynamic> toJson() => _$MachineModelToJson(this);
}
