import 'package:json_annotation/json_annotation.dart';

part 'production_detail_model.g.dart';

@JsonSerializable()
class ProductionDetailModel {
  final String lineCd;
  final String lineName;
  final String pkCd;
  final String planDate;
  final String planStartTime;
  final int as400PlantAmt;
  final String teamName;
  final String shiftPeriodName;
  final String shiftPeriod;
  final String b1, b2, b3, b4, ot;
  final String modelCd;
  final String productCd;
  final String partNo;
  final String partUpper;
  final String partLower;
  final String cycleTime;
  final int manPower;
  int planTotalTime;
  final int planFgAmt;
  final int operator;
  final int leader;
  final String status;
  final String statusName;
  final String updatedBy;
  final String updatedDate;
  final int id;
  final String actualStartDt;
  final String actualStopDt;
  final int actualTotalTime;
  final int setupTime;
  final int actualFgAmt;
  final int okAmt;
  final int ngAmt;
  final String as400ProductCD;

  ProductionDetailModel({
    required this.lineCd,
    required this.lineName,
    required this.pkCd,
    required this.planDate,
    required this.planStartTime,
    required this.as400PlantAmt,
    required this.teamName,
    required this.shiftPeriodName,
    required this.shiftPeriod,
    required this.b1,
    required this.b2,
    required this.b3,
    required this.b4,
    required this.ot,
    required this.modelCd,
    required this.productCd,
    required this.partNo,
    required this.partUpper,
    required this.partLower,
    required this.cycleTime,
    required this.manPower,
    required this.planTotalTime,
    required this.planFgAmt,
    required this.operator,
    required this.leader,
    required this.status,
    required this.statusName,
    required this.updatedBy,
    required this.updatedDate,
    required this.id,
    required this.actualStartDt,
    required this.actualStopDt,
    required this.actualTotalTime,
    required this.setupTime,
    required this.actualFgAmt,
    required this.okAmt,
    required this.ngAmt,
    required this.as400ProductCD,
  });

  factory ProductionDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductionDetailModel(
      lineCd: json['Line_CD'] ?? '',
      lineName: json['Line_Name'] ?? '',
      pkCd: json['PK_CD'] ?? '',
      planDate: json['Plan_Date'] ?? '',
      planStartTime: json['Plan_Start_Time'] ?? '',
      as400PlantAmt: json['AS400_Plant_Amt'] ?? 0,
      teamName: json['Team_Name'] ?? '',
      shiftPeriodName: json['Shift_Period_Name'] ?? '',
      shiftPeriod: json['Shift_Period'] ?? '',
      b1: json['B1'] ?? 'N',
      b2: json['B2'] ?? 'N',
      b3: json['B3'] ?? 'N',
      b4: json['B4'] ?? 'N',
      ot: json['OT'] ?? 'N',
      modelCd: json['Model_CD'] ?? '',
      productCd: json['Product_CD'] ?? '',
      partNo: json['Part_No'] ?? '',
      partUpper: json['Part_Upper'] ?? '',
      partLower: json['Part_Lower'] ?? '',
      cycleTime: json['Cycle_Time'] ?? '',
      manPower: json['Man_Power'] ?? 0,
      planTotalTime: json['plan_total_time'] ?? 0,
      planFgAmt: json['plan_fg_amt'] ?? 0,
      operator: json['Operator'] ?? 0,
      leader: json['Leader'] ?? 0,
      status: json['status'] ?? '',
      statusName: json['status_name'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      updatedDate: json['updated_date'] ?? '',
      id: json['id'] ?? 0,
      actualStartDt: json['Actual_Start_DT'] ?? '',
      actualStopDt: json['Actual_Stop_DT'] ?? '',
      actualTotalTime: json['Actual_Total_Time'] ?? 0,
      setupTime: json['Setup_Time'] ?? 0,
      actualFgAmt: json['Actual_FG_Amt'] ?? 0,
      okAmt: json['OK_Amt'] ?? 0,
      ngAmt: json['NG_Amt'] ?? 0,
      as400ProductCD: json['AS400_Product_CD'] ?? '',
    );
  }
}
