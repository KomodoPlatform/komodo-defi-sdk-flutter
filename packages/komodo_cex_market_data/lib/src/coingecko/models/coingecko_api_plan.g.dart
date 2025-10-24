// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coingecko_api_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DemoPlan _$DemoPlanFromJson(Map<String, dynamic> json) => _DemoPlan(
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 10000,
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt() ?? 30,
  attributionRequired: json['attributionRequired'] as bool? ?? true,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$DemoPlanToJson(_DemoPlan instance) => <String, dynamic>{
  'monthlyCallLimit': instance.monthlyCallLimit,
  'rateLimitPerMinute': instance.rateLimitPerMinute,
  'attributionRequired': instance.attributionRequired,
  'runtimeType': instance.$type,
};

_AnalystPlan _$AnalystPlanFromJson(Map<String, dynamic> json) => _AnalystPlan(
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 500000,
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt() ?? 500,
  attributionRequired: json['attributionRequired'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$AnalystPlanToJson(_AnalystPlan instance) =>
    <String, dynamic>{
      'monthlyCallLimit': instance.monthlyCallLimit,
      'rateLimitPerMinute': instance.rateLimitPerMinute,
      'attributionRequired': instance.attributionRequired,
      'runtimeType': instance.$type,
    };

_LitePlan _$LitePlanFromJson(Map<String, dynamic> json) => _LitePlan(
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 2000000,
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt() ?? 500,
  attributionRequired: json['attributionRequired'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$LitePlanToJson(_LitePlan instance) => <String, dynamic>{
  'monthlyCallLimit': instance.monthlyCallLimit,
  'rateLimitPerMinute': instance.rateLimitPerMinute,
  'attributionRequired': instance.attributionRequired,
  'runtimeType': instance.$type,
};

_ProPlan _$ProPlanFromJson(Map<String, dynamic> json) => _ProPlan(
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 5000000,
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt() ?? 1000,
  attributionRequired: json['attributionRequired'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ProPlanToJson(_ProPlan instance) => <String, dynamic>{
  'monthlyCallLimit': instance.monthlyCallLimit,
  'rateLimitPerMinute': instance.rateLimitPerMinute,
  'attributionRequired': instance.attributionRequired,
  'runtimeType': instance.$type,
};

_EnterprisePlan _$EnterprisePlanFromJson(Map<String, dynamic> json) =>
    _EnterprisePlan(
      monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt(),
      rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt(),
      attributionRequired: json['attributionRequired'] as bool? ?? false,
      hasSla: json['hasSla'] as bool? ?? true,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$EnterprisePlanToJson(_EnterprisePlan instance) =>
    <String, dynamic>{
      'monthlyCallLimit': instance.monthlyCallLimit,
      'rateLimitPerMinute': instance.rateLimitPerMinute,
      'attributionRequired': instance.attributionRequired,
      'hasSla': instance.hasSla,
      'runtimeType': instance.$type,
    };
