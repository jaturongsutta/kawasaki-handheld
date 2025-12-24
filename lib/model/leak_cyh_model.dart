import 'package:json_annotation/json_annotation.dart';

part 'leak_cyh_model.g.dart';

@JsonSerializable()
class LeakCYH {
  @JsonKey(name: 'ID')
  final int? id;

  @JsonKey(name: 'Model_CD')
  final String? modelCd;

  @JsonKey(name: 'Machine_No')
  final String? machineNo;

  @JsonKey(name: 'Tested_Status')
  final int? testedStatus;

  @JsonKey(name: 'Casting_No')
  final int? castingNo;

  @JsonKey(name: 'Casting_Date')
  final String? castingDate;

  @JsonKey(name: 'Mold_No')
  final String? moldNo;

  const LeakCYH({
    this.id,
    this.modelCd,
    this.machineNo,
    this.testedStatus,
    this.castingNo,
    this.castingDate,
    this.moldNo,
  });

  factory LeakCYH.fromJson(Map<String, dynamic> json) =>
      _$LeakCYHFromJson(json);

  Map<String, dynamic> toJson() => _$LeakCYHToJson(this);
}
