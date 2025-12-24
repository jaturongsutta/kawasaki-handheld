// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_cyh_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeakCYH _$LeakCYHFromJson(Map<String, dynamic> json) => LeakCYH(
      id: json['ID'] as int?,
      modelCd: json['Model_CD'] as String?,
      machineNo: json['Machine_No'] as String?,
      testedStatus: json['Tested_Status'] as int?,
      castingNo: json['Casting_No'] as int?,
      castingDate: json['Casting_Date'] as String?,
      moldNo: json['Mold_No'] as String?,
    );

Map<String, dynamic> _$LeakCYHToJson(LeakCYH instance) => <String, dynamic>{
      'ID': instance.id,
      'Model_CD': instance.modelCd,
      'Machine_No': instance.machineNo,
      'Tested_Status': instance.testedStatus,
      'Casting_No': instance.castingNo,
      'Casting_Date': instance.castingDate,
      'Mold_No': instance.moldNo,
    };
