// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeakTestModel _$LeakTestModelFromJson(Map<String, dynamic> json) =>
    LeakTestModel(
      mappedPlanId: (json['Mapped_Plan_ID'] as num).toInt(),
      machineNo: json['Machine_No'] as String,
      workType: json['Work_Type'] as String,
      modelCd: json['Model_CD'] as String,
      serialNo: json['Serial_No'] as String,
      scanDate: json['Scan_Date'] as String,
      createdBy: (json['CREATED_BY'] as num).toInt(),
      updatedBy: (json['UPDATED_BY'] as num).toInt(),
      gsNo: json['GS_No'] as String,
      lineCd: json['Line_CD'] as String,
      ngId: json['NG_Id'] as String,
      plantId: (json['Plant_Id'] as num).toInt(),
      moldNo: json['Mold_No'] as String,
      caDate: json['CA_Date'] as String,
      caNo: json['CA_No'] as String,
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
      'UPDATED_BY': instance.updatedBy,
      'GS_No': instance.gsNo,
      'Line_CD': instance.lineCd,
      'NG_Id': instance.ngId,
      'Plant_Id': instance.plantId,
      'Mold_No': instance.moldNo,
      'CA_No': instance.caNo,
      'CA_Date': instance.caDate,
    };
