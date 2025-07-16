// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ng_init_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NgInitDataModel _$NgInitDataModelFromJson(Map<String, dynamic> json) =>
    NgInitDataModel(
      process:
          (json['process'] as List<dynamic>).map((e) => e as String).toList(),
      reason: (json['reason'] as List<dynamic>)
          .map((e) => ReasonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      plan: json['plan'] == null
          ? null
          : NGProductionPlanModel.fromJson(
              json['plan'] as Map<String, dynamic>),
      defaults: json['defaults'] == null
          ? null
          : DefaultNgValues.fromJson(json['defaults'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NgInitDataModelToJson(NgInitDataModel instance) =>
    <String, dynamic>{
      'process': instance.process,
      'reason': instance.reason,
      'plan': instance.plan,
      'defaults': instance.defaults,
    };

ReasonModel _$ReasonModelFromJson(Map<String, dynamic> json) => ReasonModel(
      code: json['code'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$ReasonModelToJson(ReasonModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'label': instance.label,
    };

DefaultNgValues _$DefaultNgValuesFromJson(Map<String, dynamic> json) =>
    DefaultNgValues(
      ngDate: json['ngDate'] as String,
      ngTime: json['ngTime'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$DefaultNgValuesToJson(DefaultNgValues instance) =>
    <String, dynamic>{
      'ngDate': instance.ngDate,
      'ngTime': instance.ngTime,
      'quantity': instance.quantity,
    };
