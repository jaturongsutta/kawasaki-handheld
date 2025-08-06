import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(name: 'Row_Num')
  final int rowNum;

  @JsonKey(name: 'ID')
  final int id;

  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'Info_Alert')
  final String title;

  @JsonKey(name: 'Alert_Start_Date')
  final String startDate;

  @JsonKey(name: 'Alert_Start_Time')
  final String startTime;

  @JsonKey(name: 'Alert_End_Date')
  final String endDate;

  @JsonKey(name: 'Alert_End_Time')
  final String endTime;

  @JsonKey(name: 'Alert_Type')
  final String level;

  @JsonKey(name: 'Header_Alert')
  final String header;

  @JsonKey(name: 'Updated_By')
  final String updatedBy;

  @JsonKey(name: 'Updated_Date')
  final String updatedDate;

  @JsonKey(name: 'Is_Reads')
  final String isReads;

  NotificationModel({
    required this.rowNum,
    required this.id,
    required this.lineCd,
    required this.title,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.level,
    required this.header,
    required this.updatedBy,
    required this.updatedDate,
    required this.isReads,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      rowNum: _toInt(json['Row_Num']),
      id: _toInt(json['ID']),
      lineCd: (json['Line_CD'] as String?) ?? '',
      title: (json['Info_Alert'] as String?) ?? '',
      startDate: (json['Alert_Start_Date'] as String?) ?? '',
      startTime: (json['Alert_Start_Time'] as String?) ?? '',
      endDate: (json['Alert_End_Date'] as String?) ?? '',
      endTime: (json['Alert_End_Time'] as String?) ?? '',
      level: (json['Alert_Type'] as String?) ?? '',
      header: (json['Header_Alert'] as String?) ?? '',
      updatedBy: (json['Updated_By'] as String?) ?? '',
      updatedDate: (json['Updated_Date'] as String?) ?? '',
      isReads: (json['Is_Reads'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Helper: แปลงอะไรก็ตามให้เป็น int อย่างปลอดภัย
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
