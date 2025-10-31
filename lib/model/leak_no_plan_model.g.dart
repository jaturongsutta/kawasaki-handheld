// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leak_no_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeakNoPlanModel _$LeakNoPlanModelFromJson(Map<String, dynamic> json) =>
    LeakNoPlanModel(
      id: (json['Id'] as num).toInt(),
      machineNo: json['Machine_No'] as String,
      startDate: json['Start_Date'] as String,
      startTime: json['Start_Time'] as String,
      endDate: json['End_Date'] as String,
      endTime: json['End_Time'] as String,
      lossTime: (json['Loss_Time'] as num).toDouble(),
      createdDate: json['CREATED_DATE'] as String,
      createdBy: (json['CREATED_BY'] as num).toInt(),
      updatedDate: json['UPDATED_DATE'] as String,
      updatedBy: (json['UPDATED_BY'] as num).toInt(),
    );

Map<String, dynamic> _$LeakNoPlanModelToJson(LeakNoPlanModel instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Machine_No': instance.machineNo,
      'Start_Date': instance.startDate,
      'Start_Time': instance.startTime,
      'End_Date': instance.endDate,
      'End_Time': instance.endTime,
      'Loss_Time': instance.lossTime,
      'CREATED_DATE': instance.createdDate,
      'CREATED_BY': instance.createdBy,
      'UPDATED_DATE': instance.updatedDate,
      'UPDATED_BY': instance.updatedBy,
    };
