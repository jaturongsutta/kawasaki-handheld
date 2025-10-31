// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachineModel _$MachineModelFromJson(Map<String, dynamic> json) => MachineModel(
      lineCd: json['Line_CD'] as String?,
      modelCd: json['Model_CD'] as String?,
      machineNo: json['Machine_No'] as String,
      processCd: json['Process_CD'] as String?,
      wt: json['WT'] as String?,
      ht: json['HT'] as String?,
      mt: json['MT'] as String?,
      isActive: json['is_Active'] as String?,
      createdDate: json['CREATED_DATE'] as String?,
      createdBy: json['CREATED_BY'] as String?,
      updatedDate: json['UPDATED_DATE'] as String?,
      updatedBy: json['UPDATED_BY'] as String?,
    );

Map<String, dynamic> _$MachineModelToJson(MachineModel instance) =>
    <String, dynamic>{
      'Line_CD': instance.lineCd,
      'Model_CD': instance.modelCd,
      'Machine_No': instance.machineNo,
      'Process_CD': instance.processCd,
      'WT': instance.wt,
      'HT': instance.ht,
      'MT': instance.mt,
      'is_Active': instance.isActive,
      'CREATED_DATE': instance.createdDate,
      'CREATED_BY': instance.createdBy,
      'UPDATED_DATE': instance.updatedDate,
      'UPDATED_BY': instance.updatedBy,
    };
