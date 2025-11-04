import 'package:json_annotation/json_annotation.dart';
import 'package:kmt/model/leak_history_item_model.dart';

part 'leak_history_response_model.g.dart';

@JsonSerializable()
class LeakHistoryResponseModel {
  @JsonKey(name: 'items')
  final List<LeakHistoryItemModel> items;

  @JsonKey(name: 'total_loss_time')
  final num totalLossTime;

  @JsonKey(name: 'total_records')
  final int? totalRecords;

  LeakHistoryResponseModel({
    required this.items,
    required this.totalLossTime,
    this.totalRecords,
  });

  factory LeakHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LeakHistoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakHistoryResponseModelToJson(this);
}
