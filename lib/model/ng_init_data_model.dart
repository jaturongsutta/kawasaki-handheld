import 'package:json_annotation/json_annotation.dart';
import 'ng_production_model.dart';

part 'ng_init_data_model.g.dart';

@JsonSerializable()
class NgInitDataModel {
  final List<String> process;
  final List<ReasonModel> reason;
  final NGProductionPlanModel? plan;
  final DefaultNgValues? defaults;

  NgInitDataModel({
    required this.process,
    required this.reason,
    required this.plan,
    required this.defaults,
  });

  factory NgInitDataModel.fromJson(Map<String, dynamic> json) => _$NgInitDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$NgInitDataModelToJson(this);
}

@JsonSerializable()
class ReasonModel {
  final String code;
  final String label;

  ReasonModel({required this.code, required this.label});

  factory ReasonModel.fromJson(Map<String, dynamic> json) => _$ReasonModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReasonModelToJson(this);
}

@JsonSerializable()
class DefaultNgValues {
  final String ngDate;
  final String ngTime;
  final int quantity;

  DefaultNgValues({
    required this.ngDate,
    required this.ngTime,
    required this.quantity,
  });

  factory DefaultNgValues.fromJson(Map<String, dynamic> json) => _$DefaultNgValuesFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultNgValuesToJson(this);
}
