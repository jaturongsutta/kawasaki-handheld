// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_stop_historical_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStopHistoricalRecordModel _$LineStopHistoricalRecordModelFromJson(
        Map<String, dynamic> json) =>
    LineStopHistoricalRecordModel(
      lineCd: json['Line_CD'] as String,
      processCd: json['Process_CD'] as String?,
      lineStopDate: json['Line_Stop_Date'] as String?,
      lineStopTime: json['Line_Stop_Time'] as String?,
      lossTime: (json['Loss_Time'] as num?)?.toInt() ?? 0,
      reasonCode: json['reason'] as String?,
      reasonName: json['Reason_name'] as String?,
      comment: json['comment'] as String?,
      status: json['status'] as String?,
      statusName: json['Status_Name'] as String?,
      type: json['Type'] as String?,
      idRef: (json['ID_Ref'] as num?)?.toInt(),
      planTotalTime: (json['plan_total_time'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num).toInt(),
      planDate: json['Plan_Date'] as String?,
      planStartTime: json['Plan_Start_Time'] as String?,
      planStopTime: json['Plan_Stop_Time'] as String?,
      teamName: json['Team_Name'] as String?,
      modelCd: json['Model_CD'] as String?,
      updatedBy: json['Updated_By'] as String?,
      updatedDate: json['Updated_Date'] as String?,
    );

Map<String, dynamic> _$LineStopHistoricalRecordModelToJson(
        LineStopHistoricalRecordModel instance) =>
    <String, dynamic>{
      'Line_CD': instance.lineCd,
      'Process_CD': instance.processCd,
      'Line_Stop_Date': instance.lineStopDate,
      'Line_Stop_Time': instance.lineStopTime,
      'Loss_Time': instance.lossTime,
      'reason': instance.reasonCode,
      'Reason_name': instance.reasonName,
      'comment': instance.comment,
      'status': instance.status,
      'Status_Name': instance.statusName,
      'Type': instance.type,
      'ID_Ref': instance.idRef,
      'plan_total_time': instance.planTotalTime,
      'id': instance.id,
      'Plan_Date': instance.planDate,
      'Plan_Start_Time': instance.planStartTime,
      'Plan_Stop_Time': instance.planStopTime,
      'Team_Name': instance.teamName,
      'Model_CD': instance.modelCd,
      'Updated_By': instance.updatedBy,
      'Updated_Date': instance.updatedDate,
    };
