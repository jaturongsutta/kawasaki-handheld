import 'package:json_annotation/json_annotation.dart';

part 'production_detail_model.g.dart';

@JsonSerializable()
class ProductionDetailModel {
  @JsonKey(name: 'Line_CD')
  final String lineCd;

  @JsonKey(name: 'Line_Name')
  final String lineName;

  @JsonKey(name: 'PK_CD')
  final String pkCd;

  @JsonKey(name: 'Plan_Date')
  final String planDate;

  @JsonKey(name: 'Plan_Start_Time')
  final String planStartTime;

  @JsonKey(name: 'AS400_Plant_Amt')
  final int? as400PlantAmt; // nullable

  @JsonKey(name: 'Team_Name')
  final String teamName;

  @JsonKey(name: 'Shift_Period_Name')
  final String shiftPeriodName;

  @JsonKey(name: 'Shift_Period')
  final String shiftPeriod;

  @JsonKey(name: 'B1')
  String b1;

  @JsonKey(name: 'B2')
  String b2;

  @JsonKey(name: 'B3')
  String b3;

  @JsonKey(name: 'B4')
  String b4;

  @JsonKey(name: 'OT')
  String ot;

  @JsonKey(name: 'Model_CD')
  final String modelCd;

  @JsonKey(name: 'Product_CD')
  final String productCd;

  @JsonKey(name: 'Part_No')
  final String partNo;

  @JsonKey(name: 'Part_Upper')
  final String partUpper;

  @JsonKey(name: 'Part_Lower')
  final String? partLower; // nullable

  @JsonKey(name: 'Cycle_Time')
  final String cycleTime;

  @JsonKey(name: 'Man_Power')
  final int manPower;

  @JsonKey(name: 'plan_total_time')
  final int planTotalTime;

  @JsonKey(name: 'plan_fg_amt')
  final int planFgAmt;

  @JsonKey(name: 'Operator')
  final int operator;

  @JsonKey(name: 'Leader')
  final int leader;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'status_name')
  final String statusName;

  @JsonKey(name: 'updated_by')
  final String updatedBy;

  @JsonKey(name: 'updated_date')
  final String updatedDate;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'Actual_Start_DT')
  final String? actualStartDt;

  @JsonKey(name: 'Actual_Stop_DT')
  final String? actualStopDt; // nullable

  @JsonKey(name: 'Actual_Total_Time')
  final int? actualTotalTime; // nullable

  @JsonKey(name: 'Setup_Time')
  final int? setupTime; // nullable

  @JsonKey(name: 'Actual_FG_Amt')
  final int? actualFgAmt;

  @JsonKey(name: 'OK_Amt')
  final int? okAmt; // nullable

  @JsonKey(name: 'NG_Amt')
  final int? ngAmt; // nullable

  @JsonKey(name: 'AS400_Product_CD')
  final String? as400ProductCD; // nullable

  @JsonKey(name: 'cycle_times')
  final int? cycletTimes; // nullable

  @JsonKey(name: 'start_dt')
  final DateTime? startDT;

  @JsonKey(name: 'end_dt')
  final DateTime? endDT;

  ProductionDetailModel({
    required this.lineCd,
    required this.lineName,
    required this.pkCd,
    required this.planDate,
    required this.planStartTime,
    this.as400PlantAmt,
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
    this.partLower,
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
    this.actualStopDt,
    this.actualTotalTime,
    this.setupTime,
    required this.actualFgAmt,
    this.okAmt,
    this.ngAmt,
    this.as400ProductCD,
    this.cycletTimes,
    this.startDT,
    this.endDT,
  });

  factory ProductionDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ProductionDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionDetailModelToJson(this);
}
