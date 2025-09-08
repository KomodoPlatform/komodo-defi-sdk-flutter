// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coinpaprika_api_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FreePlan _$FreePlanFromJson(Map<String, dynamic> json) => _FreePlan(
  ohlcHistoricalDataLimit: json['ohlcHistoricalDataLimit'] == null
      ? const Duration(days: 365)
      : Duration(
          microseconds: (json['ohlcHistoricalDataLimit'] as num).toInt(),
        ),
  availableIntervals:
      (json['availableIntervals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['24h', '1d', '7d', '14d', '30d', '90d', '365d'],
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 20000,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$FreePlanToJson(_FreePlan instance) => <String, dynamic>{
  'ohlcHistoricalDataLimit': instance.ohlcHistoricalDataLimit.inMicroseconds,
  'availableIntervals': instance.availableIntervals,
  'monthlyCallLimit': instance.monthlyCallLimit,
  'runtimeType': instance.$type,
};

_StarterPlan _$StarterPlanFromJson(Map<String, dynamic> json) => _StarterPlan(
  ohlcHistoricalDataLimit: json['ohlcHistoricalDataLimit'] == null
      ? const Duration(days: 1825)
      : Duration(
          microseconds: (json['ohlcHistoricalDataLimit'] as num).toInt(),
        ),
  availableIntervals:
      (json['availableIntervals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [
        '24h',
        '1d',
        '7d',
        '14d',
        '30d',
        '90d',
        '365d',
        '1h',
        '2h',
        '3h',
        '6h',
        '12h',
        '5m',
        '10m',
        '15m',
        '30m',
        '45m',
      ],
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 400000,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$StarterPlanToJson(
  _StarterPlan instance,
) => <String, dynamic>{
  'ohlcHistoricalDataLimit': instance.ohlcHistoricalDataLimit.inMicroseconds,
  'availableIntervals': instance.availableIntervals,
  'monthlyCallLimit': instance.monthlyCallLimit,
  'runtimeType': instance.$type,
};

_ProPlan _$ProPlanFromJson(Map<String, dynamic> json) => _ProPlan(
  ohlcHistoricalDataLimit: json['ohlcHistoricalDataLimit'] == null
      ? null
      : Duration(
          microseconds: (json['ohlcHistoricalDataLimit'] as num).toInt(),
        ),
  availableIntervals:
      (json['availableIntervals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [
        '24h',
        '1d',
        '7d',
        '14d',
        '30d',
        '90d',
        '365d',
        '1h',
        '2h',
        '3h',
        '6h',
        '12h',
        '5m',
        '10m',
        '15m',
        '30m',
        '45m',
      ],
  monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 1000000,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ProPlanToJson(_ProPlan instance) => <String, dynamic>{
  'ohlcHistoricalDataLimit': instance.ohlcHistoricalDataLimit?.inMicroseconds,
  'availableIntervals': instance.availableIntervals,
  'monthlyCallLimit': instance.monthlyCallLimit,
  'runtimeType': instance.$type,
};

_BusinessPlan _$BusinessPlanFromJson(Map<String, dynamic> json) =>
    _BusinessPlan(
      ohlcHistoricalDataLimit: json['ohlcHistoricalDataLimit'] == null
          ? null
          : Duration(
              microseconds: (json['ohlcHistoricalDataLimit'] as num).toInt(),
            ),
      availableIntervals:
          (json['availableIntervals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            '24h',
            '1d',
            '7d',
            '14d',
            '30d',
            '90d',
            '365d',
            '1h',
            '2h',
            '3h',
            '6h',
            '12h',
            '5m',
            '10m',
            '15m',
            '30m',
            '45m',
          ],
      monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 5000000,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$BusinessPlanToJson(
  _BusinessPlan instance,
) => <String, dynamic>{
  'ohlcHistoricalDataLimit': instance.ohlcHistoricalDataLimit?.inMicroseconds,
  'availableIntervals': instance.availableIntervals,
  'monthlyCallLimit': instance.monthlyCallLimit,
  'runtimeType': instance.$type,
};

_UltimatePlan _$UltimatePlanFromJson(Map<String, dynamic> json) =>
    _UltimatePlan(
      ohlcHistoricalDataLimit: json['ohlcHistoricalDataLimit'] == null
          ? null
          : Duration(
              microseconds: (json['ohlcHistoricalDataLimit'] as num).toInt(),
            ),
      availableIntervals:
          (json['availableIntervals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            '24h',
            '1d',
            '7d',
            '14d',
            '30d',
            '90d',
            '365d',
            '1h',
            '2h',
            '3h',
            '6h',
            '12h',
            '5m',
            '10m',
            '15m',
            '30m',
            '45m',
          ],
      monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt() ?? 10000000,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$UltimatePlanToJson(
  _UltimatePlan instance,
) => <String, dynamic>{
  'ohlcHistoricalDataLimit': instance.ohlcHistoricalDataLimit?.inMicroseconds,
  'availableIntervals': instance.availableIntervals,
  'monthlyCallLimit': instance.monthlyCallLimit,
  'runtimeType': instance.$type,
};

_EnterprisePlan _$EnterprisePlanFromJson(Map<String, dynamic> json) =>
    _EnterprisePlan(
      ohlcHistoricalDataLimit: json['ohlcHistoricalDataLimit'] == null
          ? null
          : Duration(
              microseconds: (json['ohlcHistoricalDataLimit'] as num).toInt(),
            ),
      availableIntervals:
          (json['availableIntervals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            '24h',
            '1d',
            '7d',
            '14d',
            '30d',
            '90d',
            '365d',
            '1h',
            '2h',
            '3h',
            '6h',
            '12h',
            '5m',
            '10m',
            '15m',
            '30m',
            '45m',
          ],
      monthlyCallLimit: (json['monthlyCallLimit'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$EnterprisePlanToJson(
  _EnterprisePlan instance,
) => <String, dynamic>{
  'ohlcHistoricalDataLimit': instance.ohlcHistoricalDataLimit?.inMicroseconds,
  'availableIntervals': instance.availableIntervals,
  'monthlyCallLimit': instance.monthlyCallLimit,
  'runtimeType': instance.$type,
};
