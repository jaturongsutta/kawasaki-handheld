// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductionDetailModel _$ProductionDetailModelFromJson(
        Map<String, dynamic> json) =>
    ProductionDetailModel(
      lineCd: json['Line_CD'] as String,
      lineName: json['Line_Name'] as String,
      pkCd: json['PK_CD'] as String,
      planDate: json['Plan_Date'] as String,
      planStartTime: json['Plan_Start_Time'] as String,
      as400PlantAmt: (json['AS400_Plant_Amt'] as num?)?.toInt(),
      teamName: json['Team_Name'] as String,
      shiftPeriodName: json['Shift_Period_Name'] as String,
      shiftPeriod: json['Shift_Period'] as String,
      b1: json['B1'] as String,
      b2: json['B2'] as String,
      b3: json['B3'] as String,
      b4: json['B4'] as String,
      ot: json['OT'] as String,
      modelCd: json['Model_CD'] as String,
      productCd: json['Product_CD'] as String,
      partNo: json['Part_No'] as String,
      partUpper: json['Part_Upper'] as String,
      partLower: json['Part_Lower'] as String?,
      cycleTime: json['Cycle_Time'] as String,
      manPower: (json['Man_Power'] as num).toInt(),
      planTotalTime: (json['plan_total_time'] as num).toInt(),
      planFgAmt: (json['plan_fg_amt'] as num).toInt(),
      operator: (json['Operator'] as num).toInt(),
      leader: (json['Leader'] as num).toInt(),
      status: json['status'] as String,
      statusName: json['status_name'] as String,
      updatedBy: json['updated_by'] as String,
      updatedDate: json['updated_date'] as String,
      id: (json['id'] as num).toInt(),
      actualStartDt: json['Actual_Start_DT'] as String?,
      actualStopDt: json['Actual_Stop_DT'] as String?,
      actualTotalTime: (json['Actual_Total_Time'] as num?)?.toInt(),
      setupTime: (json['Setup_Time'] as num?)?.toInt(),
      actualFgAmt: (json['Actual_FG_Amt'] as num?)?.toInt(),
      okAmt: (json['OK_Amt'] as num?)?.toInt(),
      ngAmt: (json['NG_Amt'] as num?)?.toInt(),
      as400ProductCD: json['AS400_Product_CD'] as String?,
      cycletTimes: (json['cycle_times'] as num?)?.toInt(),
      startDT: json['start_dt'] == null
          ? null
          : DateTime.parse(json['start_dt'] as String),
      endDT: json['end_dt'] == null
          ? null
          : DateTime.parse(json['end_dt'] as String),
    );

Map<String, dynamic> _$ProductionDetailModelToJson(
        ProductionDetailModel instance) =>
    <String, dynamic>{
      'Line_CD': instance.lineCd,
      'Line_Name': instance.lineName,
      'PK_CD': instance.pkCd,
      'Plan_Date': instance.planDate,
      'Plan_Start_Time': instance.planStartTime,
      'AS400_Plant_Amt': instance.as400PlantAmt,
      'Team_Name': instance.teamName,
      'Shift_Period_Name': instance.shiftPeriodName,
      'Shift_Period': instance.shiftPeriod,
      'B1': instance.b1,
      'B2': instance.b2,
      'B3': instance.b3,
      'B4': instance.b4,
      'OT': instance.ot,
      'Model_CD': instance.modelCd,
      'Product_CD': instance.productCd,
      'Part_No': instance.partNo,
      'Part_Upper': instance.partUpper,
      'Part_Lower': instance.partLower,
      'Cycle_Time': instance.cycleTime,
      'Man_Power': instance.manPower,
      'plan_total_time': instance.planTotalTime,
      'plan_fg_amt': instance.planFgAmt,
      'Operator': instance.operator,
      'Leader': instance.leader,
      'status': instance.status,
      'status_name': instance.statusName,
      'updated_by': instance.updatedBy,
      'updated_date': instance.updatedDate,
      'id': instance.id,
      'Actual_Start_DT': instance.actualStartDt,
      'Actual_Stop_DT': instance.actualStopDt,
      'Actual_Total_Time': instance.actualTotalTime,
      'Setup_Time': instance.setupTime,
      'Actual_FG_Amt': instance.actualFgAmt,
      'OK_Amt': instance.okAmt,
      'NG_Amt': instance.ngAmt,
      'AS400_Product_CD': instance.as400ProductCD,
      'cycle_times': instance.cycletTimes,
      'start_dt': instance.startDT?.toIso8601String(),
      'end_dt': instance.endDT?.toIso8601String(),
    };
