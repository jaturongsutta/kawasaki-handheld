// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ng_production_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NGProductionPlanModel _$NGProductionPlanModelFromJson(
        Map<String, dynamic> json) =>
    NGProductionPlanModel(
      statusName: json['status_name'] as String? ?? '',
      lineCd: json['Line_CD'] as String? ?? '',
      lineName: json['Line_Name'] as String? ?? '',
      planDate: json['Plan_Date'] as String? ?? '',
      planStartTime: json['Plan_Start_Time'] as String? ?? '',
      teamName: json['Team_Name'] as String? ?? '',
      shiftPeriodName: json['Shift_Period_Name'] as String? ?? '',
      b1: json['B1'] as String? ?? '',
      b2: json['B2'] as String? ?? '',
      b3: json['B3'] as String? ?? '',
      b4: json['B4'] as String? ?? '',
      ot: json['OT'] as String? ?? '',
      modelCd: json['Model_CD'] as String? ?? '',
      cycleTimes: json['Cycle_Times'] as String? ?? '',
      planTotalTime: (json['plan_total_time'] as num).toInt(),
      planFgAmt: (json['plan_fg_amt'] as num).toInt(),
      actualFgAmt: (json['actual_fg_amt'] as num).toInt(),
      status: json['status'] as String? ?? '',
      id: (json['id'] as num).toInt(),
      partNo: json['Part_No'] as String? ?? '',
      part1: json['Part_1'] as String? ?? '',
      part2: json['Part_2'] as String? ?? '',
    );

Map<String, dynamic> _$NGProductionPlanModelToJson(
        NGProductionPlanModel instance) =>
    <String, dynamic>{
      'status_name': instance.statusName,
      'Line_CD': instance.lineCd,
      'Line_Name': instance.lineName,
      'Plan_Date': instance.planDate,
      'Plan_Start_Time': instance.planStartTime,
      'Team_Name': instance.teamName,
      'Shift_Period_Name': instance.shiftPeriodName,
      'B1': instance.b1,
      'B2': instance.b2,
      'B3': instance.b3,
      'B4': instance.b4,
      'OT': instance.ot,
      'Model_CD': instance.modelCd,
      'Cycle_Times': instance.cycleTimes,
      'plan_total_time': instance.planTotalTime,
      'plan_fg_amt': instance.planFgAmt,
      'actual_fg_amt': instance.actualFgAmt,
      'status': instance.status,
      'id': instance.id,
      'Part_No': instance.partNo,
      'Part_1': instance.part1,
      'Part_2': instance.part2,
    };
