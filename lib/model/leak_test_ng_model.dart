import 'package:json_annotation/json_annotation.dart';

part 'leak_test_ng_model.g.dart';

@JsonSerializable()
class LeakTestNgModel {
  @JsonKey(name: 'Id')
  final String? id;

  @JsonKey(name: 'Machine_No')
  final String? machineNo;

  @JsonKey(name: 'Model_CD')
  final String? modelCd;

  @JsonKey(name: 'Serial_No')
  final String? serial;

  @JsonKey(name: 'Result')
  final String? result;

  @JsonKey(name: 'NG_P1')
  final String? ngP1;

  @JsonKey(name: 'NG_P1_color')
  final String? ngP1Color;

  @JsonKey(name: 'NG_P2')
  final String? ngP2;

  @JsonKey(name: 'NG_P2_color')
  final String? ngP2Color;

  @JsonKey(name: 'NG_P3')
  final String? ngP3;

  @JsonKey(name: 'NG_P3_color')
  final String? ngP3Color;

  @JsonKey(name: 'NG_P4')
  final String? ngP4;

  @JsonKey(name: 'NG_P4_color')
  final String? ngP4Color;

  @JsonKey(name: 'NG_TB')
  final String? ngTb;

  @JsonKey(name: 'NG_TB_color')
  final String? ngTbColor;

  @JsonKey(name: 'CA_No')
  final String? caNo;

  @JsonKey(name: 'CA_Date')
  final String? caDate;

  @JsonKey(name: 'Mold_No')
  final String? moldNo;

  // ✅ Constructor ไม่ต้อง required
  const LeakTestNgModel({
    this.id,
    this.machineNo,
    this.modelCd,
    this.serial,
    this.result,
    this.ngP1,
    this.ngP1Color,
    this.ngP2,
    this.ngP2Color,
    this.ngP3,
    this.ngP3Color,
    this.ngP4,
    this.ngP4Color,
    this.ngTb,
    this.ngTbColor,
    this.caNo,
    this.caDate,
    this.moldNo,
  });

  factory LeakTestNgModel.fromJson(Map<String, dynamic> json) =>
      _$LeakTestNgModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakTestNgModelToJson(this);
}
