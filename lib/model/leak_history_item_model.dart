import 'package:json_annotation/json_annotation.dart';

part 'leak_history_item_model.g.dart';

@JsonSerializable()
class LeakHistoryItemModel {
  @JsonKey(name: 'Machine_No')
  final String machineNo;

  @JsonKey(name: 'Start_datetime')
  final String startDateTimeRaw;

  @JsonKey(name: 'End_datetime')
  final String endDateTimeRaw;

  @JsonKey(name: 'Loss_Time')
  final int lossTime;

  LeakHistoryItemModel({
    required this.machineNo,
    required this.startDateTimeRaw,
    required this.endDateTimeRaw,
    required this.lossTime,
  });

  factory LeakHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$LeakHistoryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeakHistoryItemModelToJson(this);
}
