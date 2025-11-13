// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_test_ng_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeakTestNgModel _$LeakTestNgModelFromJson(Map<String, dynamic> json) =>
    LeakTestNgModel(
      id: json['Id'].toString(),
      machineNo: json['Machine_No'] as String?,
      modelCd: json['Model_CD'] as String?,
      serial: json['Serial'] as String?,
      result: json['Result'] as String?,
      ngP1: json['NG_P1'] as String?,
      ngP1Color: json['NG_P1_color'] as String?,
      ngP2: json['NG_P2'] as String?,
      ngP2Color: json['NG_P2_color'] as String?,
      ngP3: json['NG_P3'] as String?,
      ngP3Color: json['NG_P3_color'] as String?,
      ngP4: json['NG_P4'] as String?,
      ngP4Color: json['NG_P4_color'] as String?,
      ngTb: json['NG_TB'] as String?,
      ngTbColor: json['NG_TB_color'] as String?,
      caNo: json['CA_No'].toString(),
      caDate: json['CA_Date'] as String?,
      moldNo: json['Mold_No'] as String?,
    );

Map<String, dynamic> _$LeakTestNgModelToJson(LeakTestNgModel instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Machine_No': instance.machineNo,
      'Model_CD': instance.modelCd,
      'Serial': instance.serial,
      'Result': instance.result,
      'NG_P1': instance.ngP1,
      'NG_P1_color': instance.ngP1Color,
      'NG_P2': instance.ngP2,
      'NG_P2_color': instance.ngP2Color,
      'NG_P3': instance.ngP3,
      'NG_P3_color': instance.ngP3Color,
      'NG_P4': instance.ngP4,
      'NG_P4_color': instance.ngP4Color,
      'NG_TB': instance.ngTb,
      'NG_TB_color': instance.ngTbColor,
      'CA_No': instance.caNo,
      'CA_Date': instance.caDate,
      'Mold_No': instance.moldNo,
    };
