import 'package:json_annotation/json_annotation.dart';
import 'package:kmt/model/ng_init_data_model.dart';
import 'ng_production_model.dart';

part 'line_stop_init_data_model.g.dart';

@JsonSerializable()
class LineStopInitDataModel {
  final List<String> process;
  final List<ReasonModel> reason;
  final NGProductionPlanModel? plan;
  final DefaultNgValues? defaults;

  LineStopInitDataModel({
    required this.process,
    required this.reason,
    required this.plan,
    required this.defaults,
  });

  factory LineStopInitDataModel.fromJson(Map<String, dynamic> json) =>
      _$LineStopInitDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$LineStopInitDataModelToJson(this);
}
