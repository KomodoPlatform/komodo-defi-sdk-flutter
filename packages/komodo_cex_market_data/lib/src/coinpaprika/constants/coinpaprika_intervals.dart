/// CoinPaprika API interval constants organized by time categories.
///
/// This file defines interval constants that build on each other, organized into:
/// - 5-minute intervals: 5m, 10m, 15m, 30m, 45m
/// - Hourly intervals: 1h, 2h, 3h, 6h, 12h
/// - Daily intervals: 24h, 1d, 7d, 14d, 30d, 90d, 365d

/// 5-minute based intervals
class CoinPaprikaFiveMinuteIntervals {
  static const String fiveMinutes = '5m';
  static const String tenMinutes = '10m';
  static const String fifteenMinutes = '15m';
  static const String thirtyMinutes = '30m';
  static const String fortyFiveMinutes = '45m';

  /// All 5-minute based intervals
  static const List<String> all = [
    fiveMinutes,
    tenMinutes,
    fifteenMinutes,
    thirtyMinutes,
    fortyFiveMinutes,
  ];
}

/// Hourly based intervals
class CoinPaprikaHourlyIntervals {
  static const String oneHour = '1h';
  static const String twoHours = '2h';
  static const String threeHours = '3h';
  static const String sixHours = '6h';
  static const String twelveHours = '12h';

  /// All hourly intervals
  static const List<String> all = [
    oneHour,
    twoHours,
    threeHours,
    sixHours,
    twelveHours,
  ];
}

/// Daily based intervals
class CoinPaprikaDailyIntervals {
  static const String twentyFourHours = '24h';
  static const String oneDay = '1d';
  static const String sevenDays = '7d';
  static const String fourteenDays = '14d';
  static const String thirtyDays = '30d';
  static const String ninetyDays = '90d';
  static const String threeHundredSixtyFiveDays = '365d';

  /// All daily intervals
  static const List<String> all = [
    twentyFourHours,
    oneDay,
    sevenDays,
    fourteenDays,
    thirtyDays,
    ninetyDays,
    threeHundredSixtyFiveDays,
  ];
}

/// Combined interval constants and defaults for different API plans
class CoinPaprikaIntervals {
  /// All available intervals across all plans
  static const List<String> allIntervals = [
    ...CoinPaprikaDailyIntervals.all,
    ...CoinPaprikaHourlyIntervals.all,
    ...CoinPaprikaFiveMinuteIntervals.all,
  ];

  /// Free plan available intervals (daily only)
  static const List<String> freeDefaults = CoinPaprikaDailyIntervals.all;

  /// Starter, Pro, Business, Ultimate, and Enterprise plans intervals
  static const List<String> premiumDefaults = allIntervals;

  /// Default interval for API requests
  static const String defaultInterval = CoinPaprikaDailyIntervals.twentyFourHours;
}
