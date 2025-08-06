// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanSearchModel _$PlanSearchModelFromJson(Map<String, dynamic> json) =>
    PlanSearchModel(
      rowNum: (json['rowNum'] as num).toInt(),
      lineCd: json['lineCd'] as String,
      planDate: json['planDate'] as String,
      planStartTime: json['planStartTime'] as String,
      planStopTime: json['planStopTime'] as String?,
      teamName: json['teamName'] as String,
      shiftPeriodName: json['shiftPeriodName'] as String,
      b1: json['b1'] as String,
      b2: json['b2'] as String,
      b3: json['b3'] as String,
      b4: json['b4'] as String,
      ot: json['ot'] as String,
      modelCd: json['modelCd'] as String,
      cycleTimes: json['cycleTimes'] as String,
      planTotalTime: (json['planTotalTime'] as num).toInt(),
      planFgAmt: (json['planFgAmt'] as num).toInt(),
      actualFgAmt: (json['actualFgAmt'] as num).toInt(),
      ngAmt: (json['ngAmt'] as num).toInt(),
      lineStopAmt: (json['lineStopAmt'] as num).toInt(),
      status: json['status'] as String,
      statusName: json['statusName'] as String,
      updatedBy: json['updatedBy'] as String,
      updatedDate: json['updatedDate'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$PlanSearchModelToJson(PlanSearchModel instance) =>
    <String, dynamic>{
      'rowNum': instance.rowNum,
      'lineCd': instance.lineCd,
      'planDate': instance.planDate,
      'planStartTime': instance.planStartTime,
      'planStopTime': instance.planStopTime,
      'teamName': instance.teamName,
      'shiftPeriodName': instance.shiftPeriodName,
      'b1': instance.b1,
      'b2': instance.b2,
      'b3': instance.b3,
      'b4': instance.b4,
      'ot': instance.ot,
      'modelCd': instance.modelCd,
      'cycleTimes': instance.cycleTimes,
      'planTotalTime': instance.planTotalTime,
      'planFgAmt': instance.planFgAmt,
      'actualFgAmt': instance.actualFgAmt,
      'ngAmt': instance.ngAmt,
      'lineStopAmt': instance.lineStopAmt,
      'status': instance.status,
      'statusName': instance.statusName,
      'updatedBy': instance.updatedBy,
      'updatedDate': instance.updatedDate,
      'id': instance.id,
    };
