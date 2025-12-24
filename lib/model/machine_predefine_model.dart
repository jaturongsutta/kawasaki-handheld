import 'package:json_annotation/json_annotation.dart';

part 'machine_predefine_model.g.dart';

@JsonSerializable()
class MachinePredefineModel {
  @JsonKey(name: 'Title')
  final String? title;

  @JsonKey(name: 'Value')
  final String? value;

  const MachinePredefineModel({
    this.title,
    this.value,
  });

  factory MachinePredefineModel.fromJson(Map<String, dynamic> json) =>
      _$MachinePredefineModelFromJson(json);

  Map<String, dynamic> toJson() => _$MachinePredefineModelToJson(this);
}
