import 'package:json_annotation/json_annotation.dart';

part 'plan_search_model.g.dart';

@JsonSerializable()
class PlanSearchModel {
  final int rowNum;
  final String lineCd;
  final String planDate;
  final String planStartTime;
  final String? planStopTime;
  final String teamName;
  final String shiftPeriodName;
  final String b1;
  final String b2;
  final String b3;
  final String b4;
  final String ot;
  final String modelCd;
  final String cycleTimes;
  final int planTotalTime;
  final int planFgAmt;
  final int actualFgAmt;
  final int ngAmt;
  final int lineStopAmt;
  final String status;
  final String statusName;
  final String updatedBy;
  final String updatedDate;
  final int id;

  PlanSearchModel({
    required this.rowNum,
    required this.lineCd,
    required this.planDate,
    required this.planStartTime,
    this.planStopTime,
    required this.teamName,
    required this.shiftPeriodName,
    required this.b1,
    required this.b2,
    required this.b3,
    required this.b4,
    required this.ot,
    required this.modelCd,
    required this.cycleTimes,
    required this.planTotalTime,
    required this.planFgAmt,
    required this.actualFgAmt,
    required this.ngAmt,
    required this.lineStopAmt,
    required this.status,
    required this.statusName,
    required this.updatedBy,
    required this.updatedDate,
    required this.id,
  });

  factory PlanSearchModel.fromJson(Map<String, dynamic> json) => PlanSearchModel(
        rowNum: int.tryParse(json['Row_Num'].toString()) ?? 0,
        lineCd: json['Line_CD'] ?? '',
        planDate: json['Plan_Date'] ?? '',
        planStartTime: json['Plan_Start_Time'] ?? '',
        planStopTime: json['Plan_Stop_Time'],
        teamName: json['Team_Name'] ?? '',
        shiftPeriodName: json['Shift_Period_Name'] ?? '',
        b1: json['B1'] ?? 'N',
        b2: json['B2'] ?? 'N',
        b3: json['B3'] ?? 'N',
        b4: json['B4'] ?? 'N',
        ot: json['OT'] ?? '',
        modelCd: json['Model_CD'] ?? '',
        cycleTimes: json['Cycle_Times'] ?? '',
        planTotalTime: json['plan_total_time'] ?? 0,
        planFgAmt: json['plan_fg_amt'] ?? 0,
        actualFgAmt: json['actual_fg_amt'] ?? 0,
        ngAmt: json['ng_amt'] ?? 0,
        lineStopAmt: json['line_stop_amt'] ?? 0,
        status: json['status'] ?? '',
        statusName: json['status_name'] ?? '',
        updatedBy: json['updated_by'] ?? '',
        updatedDate: json['updated_date'] ?? '',
        id: json['id'] ?? 0,
      );
}
