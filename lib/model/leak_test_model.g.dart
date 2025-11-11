// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeakTestModel _$LeakTestModelFromJson(Map<String, dynamic> json) =>
    LeakTestModel(
      mappedPlanId: json['Mapped_Plan_ID'] as String? ?? '',
      machineNo: json['Machine_No'] as String,
      workType: json['Work_Type'] as String,
      modelCd: json['Model_CD'] as String,
      serialNo: json['Serial_No'] as String,
      scanDate: json['Scan_Date'] as String,
      createdBy: json['CREATED_BY'] as int,
      gsNo: json['GS_No'] as String,
    );

Map<String, dynamic> _$LeakTestModelToJson(LeakTestModel instance) =>
    <String, dynamic>{
      'Mapped_Plan_ID': instance.mappedPlanId,
      'Machine_No': instance.machineNo,
      'Work_Type': instance.workType,
      'Model_CD': instance.modelCd,
      'Serial_No': instance.serialNo,
      'Scan_Date': instance.scanDate,
      'CREATED_BY': instance.createdBy,
      'GS_No': instance.gsNo,
    };
