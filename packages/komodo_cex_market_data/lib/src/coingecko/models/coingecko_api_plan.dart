import 'package:freezed_annotation/freezed_annotation.dart';

part 'coingecko_api_plan.freezed.dart';
part 'coingecko_api_plan.g.dart';

/// Represents the different CoinGecko API plans with their specific limitations.
@freezed
abstract class CoingeckoApiPlan with _$CoingeckoApiPlan {
  /// Private constructor required for custom methods in freezed classes.
  const CoingeckoApiPlan._();

  /// Demo plan: Free (Beta)
  /// - 10,000 calls/month
  /// - 30 calls/minute rate limit
  /// - 1 year daily/hourly historical data
  /// - 1 day 5-minutely historical data
  /// - Attribution required
  const factory CoingeckoApiPlan.demo({
    @Default(10000) int monthlyCallLimit,
    @Default(30) int rateLimitPerMinute,
    @Default(true) bool attributionRequired,
  }) = _DemoPlan;

  /// Analyst plan: $129/mo ($103.2/mo yearly)
  /// - 500,000 calls/month
  /// - 500 calls/minute rate limit
  /// - Historical data from 2013 (daily), 2018 (hourly)
  /// - 1 day 5-minutely historical data
  /// - Commercial license
  const factory CoingeckoApiPlan.analyst({
    @Default(500000) int monthlyCallLimit,
    @Default(500) int rateLimitPerMinute,
    @Default(false) bool attributionRequired,
  }) = _AnalystPlan;

  /// Lite plan: $499/mo ($399.2/mo yearly)
  /// - 2,000,000 calls/month
  /// - 500 calls/minute rate limit
  /// - Historical data from 2013 (daily), 2018 (hourly)
  /// - 1 day 5-minutely historical data
  /// - Commercial license
  const factory CoingeckoApiPlan.lite({
    @Default(2000000) int monthlyCallLimit,
    @Default(500) int rateLimitPerMinute,
    @Default(false) bool attributionRequired,
  }) = _LitePlan;

  /// Pro plan: $999/mo ($799.2/mo yearly)
  /// - 5M-15M calls/month (configurable)
  /// - 1,000 calls/minute rate limit
  /// - Historical data from 2013 (daily), 2018 (hourly)
  /// - 1 day 5-minutely historical data
  /// - Commercial license
  const factory CoingeckoApiPlan.pro({
    @Default(5000000) int monthlyCallLimit,
    @Default(1000) int rateLimitPerMinute,
    @Default(false) bool attributionRequired,
  }) = _ProPlan;

  /// Enterprise plan: Custom pricing
  /// - Custom call limits
  /// - Custom rate limits
  /// - Historical data from 2013 (daily), 2018 (hourly), 2018 (5-minutely)
  /// - 99.9% uptime SLA
  /// - Custom license options
  const factory CoingeckoApiPlan.enterprise({
    int? monthlyCallLimit,
    int? rateLimitPerMinute,
    @Default(false) bool attributionRequired,
    @Default(true) bool hasSla,
  }) = _EnterprisePlan;

  /// Creates a plan from JSON representation.
  factory CoingeckoApiPlan.fromJson(Map<String, dynamic> json) =>
      _$CoingeckoApiPlanFromJson(json);

  /// Returns true if the plan has unlimited monthly API calls.
  bool get hasUnlimitedCalls => monthlyCallLimit == null;

  /// Returns true if the plan has unlimited rate limit per minute.
  bool get hasUnlimitedRateLimit => rateLimitPerMinute == null;

  /// Gets the plan name as a string.
  String get planName {
    return when(
      demo: (_, __, ___) => 'Demo',
      analyst: (_, __, ___) => 'Analyst',
      lite: (_, __, ___) => 'Lite',
      pro: (_, __, ___) => 'Pro',
      enterprise: (_, __, ___, ____) => 'Enterprise',
    );
  }

  /// Returns true if this is the default free tier plan.
  bool get isFreeTier => when(
    demo: (_, __, ___) => true,
    analyst: (_, __, ___) => false,
    lite: (_, __, ___) => false,
    pro: (_, __, ___) => false,
    enterprise: (_, __, ___, ____) => false,
  );

  /// Returns the monthly price in USD, null for custom pricing.
  double? get monthlyPriceUsd => when(
    demo: (_, __, ___) => 0.0,
    analyst: (_, __, ___) => 129.0,
    lite: (_, __, ___) => 499.0,
    pro: (_, __, ___) => 999.0,
    enterprise: (_, __, ___, ____) => null, // Custom pricing
  );

  /// Returns the yearly price in USD (with discount), null for custom pricing.
  double? get yearlyPriceUsd => when(
    demo: (_, __, ___) => 0.0,
    analyst: (_, __, ___) => 1238.4, // $103.2/mo * 12
    lite: (_, __, ___) => 4790.4, // $399.2/mo * 12
    pro: (_, __, ___) => 9590.4, // $799.2/mo * 12
    enterprise: (_, __, ___, ____) => null, // Custom pricing
  );

  /// Gets a human-readable description of the monthly call limit.
  String get monthlyCallLimitDescription {
    if (hasUnlimitedCalls) {
      return 'Custom call credits';
    }

    final limit = monthlyCallLimit!;
    if (limit >= 1000000) {
      return '${(limit / 1000000).toStringAsFixed(limit % 1000000 == 0 ? 0 : 1)}M calls/month';
    } else if (limit >= 1000) {
      return '${(limit / 1000).toStringAsFixed(limit % 1000 == 0 ? 0 : 1)}K calls/month';
    } else {
      return '$limit calls/month';
    }
  }

  /// Gets a human-readable description of the rate limit.
  String get rateLimitDescription {
    if (hasUnlimitedRateLimit) {
      return 'Custom rate limit';
    }

    return '$rateLimitPerMinute calls/minute';
  }

  /// Gets the daily historical data availability description.
  String get dailyHistoricalDataDescription => when(
    demo: (_, __, ___) => '1 year of daily historical data',
    analyst: (_, __, ___) => 'Daily historical data from 2013',
    lite: (_, __, ___) => 'Daily historical data from 2013',
    pro: (_, __, ___) => 'Daily historical data from 2013',
    enterprise: (_, __, ___, ____) => 'Daily historical data from 2013',
  );

  /// Gets the hourly historical data availability description.
  String get hourlyHistoricalDataDescription => when(
    demo: (_, __, ___) => '1 year of hourly historical data',
    analyst: (_, __, ___) => 'Hourly historical data from 2018',
    lite: (_, __, ___) => 'Hourly historical data from 2018',
    pro: (_, __, ___) => 'Hourly historical data from 2018',
    enterprise: (_, __, ___, ____) => 'Hourly historical data from 2018',
  );

  /// Gets the 5-minutely historical data availability description.
  String get fiveMinutelyHistoricalDataDescription => when(
    demo: (_, __, ___) => '1 day of 5-minutely historical data',
    analyst: (_, __, ___) => '1 day of 5-minutely historical data',
    lite: (_, __, ___) => '1 day of 5-minutely historical data',
    pro: (_, __, ___) => '1 day of 5-minutely historical data',
    enterprise: (_, __, ___, ____) => '5-minutely historical data from 2018',
  );

  /// Gets the daily historical data cutoff date based on the plan's limitations.
  /// Returns null for plans with full historical access.
  DateTime? getDailyHistoricalDataCutoff() {
    return when(
      demo: (_, __, ___) =>
          DateTime.now().toUtc().subtract(const Duration(days: 365)),
      analyst: (_, __, ___) => DateTime.utc(2013),
      lite: (_, __, ___) => DateTime.utc(2013),
      pro: (_, __, ___) => DateTime.utc(2013),
      enterprise: (_, __, ___, ____) => DateTime.utc(2013),
    );
  }

  /// Gets the hourly historical data cutoff date based on the plan's limitations.
  /// Returns null for plans with full historical access.
  DateTime? getHourlyHistoricalDataCutoff() {
    return when(
      demo: (_, __, ___) =>
          DateTime.now().toUtc().subtract(const Duration(days: 365)),
      analyst: (_, __, ___) => DateTime.utc(2018),
      lite: (_, __, ___) => DateTime.utc(2018),
      pro: (_, __, ___) => DateTime.utc(2018),
      enterprise: (_, __, ___, ____) => DateTime.utc(2018),
    );
  }

  /// Gets the 5-minutely historical data cutoff date based on the plan's limitations.
  /// Returns null for plans with unlimited access.
  DateTime? get5MinutelyHistoricalDataCutoff() {
    return when(
      demo: (_, __, ___) =>
          DateTime.now().toUtc().subtract(const Duration(days: 1)),
      analyst: (_, __, ___) =>
          DateTime.now().toUtc().subtract(const Duration(days: 1)),
      lite: (_, __, ___) =>
          DateTime.now().toUtc().subtract(const Duration(days: 1)),
      pro: (_, __, ___) =>
          DateTime.now().toUtc().subtract(const Duration(days: 1)),
      enterprise: (_, __, ___, ____) => DateTime.utc(2018),
    );
  }

  /// Returns true if the plan includes SLA (Service Level Agreement).
  bool get hasSlaSupport => when(
    demo: (_, __, ___) => false,
    analyst: (_, __, ___) => false,
    lite: (_, __, ___) => false,
    pro: (_, __, ___) => false,
    enterprise: (_, __, ___, hasSla) => hasSla,
  );

  /// Validates if the given timestamp is within the plan's daily historical data limits.
  bool isWithinDailyHistoricalLimit(DateTime timestamp) {
    final cutoff = getDailyHistoricalDataCutoff();
    return cutoff == null || !timestamp.isBefore(cutoff);
  }

  /// Validates if the given timestamp is within the plan's hourly historical data limits.
  bool isWithinHourlyHistoricalLimit(DateTime timestamp) {
    final cutoff = getHourlyHistoricalDataCutoff();
    return cutoff == null || !timestamp.isBefore(cutoff);
  }

  /// Validates if the given timestamp is within the plan's 5-minutely historical data limits.
  bool isWithin5MinutelyHistoricalLimit(DateTime timestamp) {
    final cutoff = get5MinutelyHistoricalDataCutoff();
    return cutoff == null || !timestamp.isBefore(cutoff);
  }
}
