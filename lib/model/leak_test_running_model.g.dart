// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_test_running_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeakTestRunningModel _$LeakTestRunningModelFromJson(
        Map<String, dynamic> json) =>
    LeakTestRunningModel(
      id: json['id'] as String,
      lineCd: json['Line_CD'] as String,
      lineName: json['Line_Name'] as String,
      modelCd: json['Model_CD'] as String,
      partNo: json['Part_No'] as String,
    );

Map<String, dynamic> _$LeakTestRunningModelToJson(
        LeakTestRunningModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Line_CD': instance.lineCd,
      'Line_Name': instance.lineName,
      'Model_CD': instance.modelCd,
      'Part_No': instance.partNo,
    };
