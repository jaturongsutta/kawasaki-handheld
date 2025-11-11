import 'package:json_annotation/json_annotation.dart';

part 'leak_test_ng_model.g.dart';

@JsonSerializable()
class LeakTestNgModel {
  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'Machine_No')
  final String machineNo;

  @JsonKey(name: 'Model_CD')
  final String modelCd;

  @JsonKey(name: 'Serial')
  final String serial;

  @JsonKey(name: 'Result')
  final String result;

  @JsonKey(name: 'NG_P1')
  final String ngP1;

  @JsonKey(name: 'NG_P1_color')
  final String ngP1Color;

  @JsonKey(name: 'NG_P2')
  final String ngP2;

  @JsonKey(name: 'NG_P2_color')
  final String ngP2Color;

  @JsonKey(name: 'NG_P3')
  final String ngP3;

  @JsonKey(name: 'NG_P3_color')
  final String ngP3Color;

  @JsonKey(name: 'NG_TB')
  final String ngTb;

  @JsonKey(name: 'NG_TB_color')
  final String ngTbColor;

  LeakTestNgModel({
    required this.id,
    required this.machineNo,
    required this.modelCd,
    required this.serial,
    required this.result,
    required this.ngP1,
    required this.ngP1Color,
    required this.ngP2,
    required this.ngP2Color,
    required this.ngP3,
    required this.ngP3Color,
    required this.ngTb,
    required this.ngTbColor,
  });

  factory LeakTestNgModel.fromJson(Map<String, dynamic> json) =>
      _$LeakTestNgModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakTestNgModelToJson(this);
}
