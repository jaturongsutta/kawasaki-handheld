// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_stop_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStopRecordModel _$LineStopRecordModelFromJson(Map<String, dynamic> json) =>
    LineStopRecordModel(
      lineCd: json['Line_CD'] as String,
      planDate: json['Plan_Date'] as String,
      planDateStop: json['Plan_Date_Stop'] as String,
      planStartTime: json['Plan_Start_Time'] as String,
      planStopTime: json['Plan_Stop_Time'] as String,
      teamName: json['Team_Name'] as String,
      shiftPeriodName: json['Shift_Period_Name'] as String,
      b1: json['B1'] as String,
      b2: json['B2'] as String,
      b3: json['B3'] as String,
      b4: json['B4'] as String,
      ot: json['OT'] as String,
      modelCd: json['Model_CD'] as String,
      cycleTimes: json['Cycle_Times'] as String,
      planTotalTime: (json['plan_total_time'] as num).toInt(),
      planFgAmt: (json['plan_fg_amt'] as num).toInt(),
      actualFgAmt: (json['actual_fg_amt'] as num?)?.toInt(),
      ngAmt: (json['ng_amt'] as num?)?.toInt(),
      lineStop: (json['line_stop'] as num).toInt(),
      status: json['status'] as String,
      statusName: json['status_name'] as String,
      updatedBy: json['Updated_By'] as String,
      updatedDate: json['Updated_Date'] as String,
      id: (json['id'] as num).toInt(),
      partNo: json['part_no'] as String,
      partUpper: json['Part_Upper'] as String,
      partLower: json['Part_Lower'] as String?,
    );

Map<String, dynamic> _$LineStopRecordModelToJson(
        LineStopRecordModel instance) =>
    <String, dynamic>{
      'Line_CD': instance.lineCd,
      'Plan_Date': instance.planDate,
      'Plan_Date_Stop': instance.planDateStop,
      'Plan_Start_Time': instance.planStartTime,
      'Plan_Stop_Time': instance.planStopTime,
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
      'ng_amt': instance.ngAmt,
      'line_stop': instance.lineStop,
      'status': instance.status,
      'status_name': instance.statusName,
      'Updated_By': instance.updatedBy,
      'Updated_Date': instance.updatedDate,
      'id': instance.id,
      'part_no': instance.partNo,
      'Part_Upper': instance.partUpper,
      'Part_Lower': instance.partLower,
    };
