import 'package:json_annotation/json_annotation.dart';

part 'leak_test_running_model.g.dart';

@JsonSerializable()
class LeakTestRunningModel {
  @JsonKey(name: 'id' , defaultValue: '')
  final String id;

  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'Line_Name')
  final String lineName; 

  @JsonKey(name: 'Model_CD')
  final String modelCd;

  @JsonKey(name: 'Part_No')
  final String partNo; 


  LeakTestRunningModel({
    required this.id,
    required this.lineCd,
    required this.lineName,
    required this.modelCd,
    required this.partNo,
  });

   factory LeakTestRunningModel.fromJson(Map<String, dynamic> json) =>
      _$LeakTestRunningModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakTestRunningModelToJson(this);
}
