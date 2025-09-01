import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_cex_market_data/src/coingecko/models/coingecko_api_plan.dart';

void main() {
  group('CoingeckoApiPlan', () {
    group('Demo Plan (Free Tier)', () {
      late CoingeckoApiPlan demoPlan;

      setUp(() {
        demoPlan = const CoingeckoApiPlan.demo();
      });

      test('should have correct default values', () {
        expect(demoPlan.monthlyCallLimit, equals(10000));
        expect(demoPlan.rateLimitPerMinute, equals(30));
        expect(demoPlan.attributionRequired, isTrue);
      });

      test('should be identified as free tier', () {
        expect(demoPlan.isFreeTier, isTrue);
      });

      test('should have correct plan name', () {
        expect(demoPlan.planName, equals('Demo'));
      });

      test('should have correct pricing', () {
        expect(demoPlan.monthlyPriceUsd, equals(0.0));
        expect(demoPlan.yearlyPriceUsd, equals(0.0));
      });

      test('should have correct call limit description', () {
        expect(demoPlan.monthlyCallLimitDescription, equals('10K calls/month'));
      });

      test('should have correct rate limit description', () {
        expect(demoPlan.rateLimitDescription, equals('30 calls/minute'));
      });

      test('should have limited historical data access', () {
        expect(
          demoPlan.dailyHistoricalDataDescription,
          equals('1 year of daily historical data'),
        );
        expect(
          demoPlan.hourlyHistoricalDataDescription,
          equals('1 year of hourly historical data'),
        );
        expect(
          demoPlan.fiveMinutelyHistoricalDataDescription,
          equals('1 day of 5-minutely historical data'),
        );
      });

      test('should not have SLA support', () {
        expect(demoPlan.hasSlaSupport, isFalse);
      });

      test('should have correct historical data cutoffs', () {
        final now = DateTime.now().toUtc();
        final dailyCutoff = demoPlan.getDailyHistoricalDataCutoff();
        final hourlyCutoff = demoPlan.getHourlyHistoricalDataCutoff();
        final fiveMinutelyCutoff = demoPlan.get5MinutelyHistoricalDataCutoff();

        expect(dailyCutoff, isNotNull);
        expect(hourlyCutoff, isNotNull);
        expect(fiveMinutelyCutoff, isNotNull);

        // Daily and hourly cutoffs should be approximately 1 year ago
        final oneYearAgo = now.subtract(const Duration(days: 365));
        expect(dailyCutoff!.difference(oneYearAgo).inDays.abs(), lessThan(2));
        expect(hourlyCutoff!.difference(oneYearAgo).inDays.abs(), lessThan(2));

        // 5-minutely cutoff should be approximately 1 day ago
        final oneDayAgo = now.subtract(const Duration(days: 1));
        expect(
          fiveMinutelyCutoff!.difference(oneDayAgo).inDays.abs(),
          lessThan(2),
        );
      });

      test('should validate historical data limits correctly', () {
        final now = DateTime.now().toUtc();
        final twoYearsAgo = now.subtract(const Duration(days: 730));
        final sixMonthsAgo = now.subtract(const Duration(days: 180));
        final twoDaysAgo = now.subtract(const Duration(days: 2));

        expect(demoPlan.isWithinDailyHistoricalLimit(sixMonthsAgo), isTrue);
        expect(demoPlan.isWithinDailyHistoricalLimit(twoYearsAgo), isFalse);

        expect(demoPlan.isWithinHourlyHistoricalLimit(sixMonthsAgo), isTrue);
        expect(demoPlan.isWithinHourlyHistoricalLimit(twoYearsAgo), isFalse);

        expect(demoPlan.isWithin5MinutelyHistoricalLimit(now), isTrue);
        expect(demoPlan.isWithin5MinutelyHistoricalLimit(twoDaysAgo), isFalse);
      });
    });

    group('Analyst Plan', () {
      late CoingeckoApiPlan analystPlan;

      setUp(() {
        analystPlan = const CoingeckoApiPlan.analyst();
      });

      test('should have correct default values', () {
        expect(analystPlan.monthlyCallLimit, equals(500000));
        expect(analystPlan.rateLimitPerMinute, equals(500));
        expect(analystPlan.attributionRequired, isFalse);
      });

      test('should not be free tier', () {
        expect(analystPlan.isFreeTier, isFalse);
      });

      test('should have correct plan name', () {
        expect(analystPlan.planName, equals('Analyst'));
      });

      test('should have correct pricing', () {
        expect(analystPlan.monthlyPriceUsd, equals(129.0));
        expect(analystPlan.yearlyPriceUsd, equals(1238.4));
      });

      test('should have correct call limit description', () {
        expect(
          analystPlan.monthlyCallLimitDescription,
          equals('500K calls/month'),
        );
      });

      test('should have extended historical data access', () {
        expect(
          analystPlan.dailyHistoricalDataDescription,
          equals('Daily historical data from 2013'),
        );
        expect(
          analystPlan.hourlyHistoricalDataDescription,
          equals('Hourly historical data from 2018'),
        );
        expect(
          analystPlan.fiveMinutelyHistoricalDataDescription,
          equals('1 day of 5-minutely historical data'),
        );
      });

      test('should have correct historical data cutoffs', () {
        final dailyCutoff = analystPlan.getDailyHistoricalDataCutoff();
        final hourlyCutoff = analystPlan.getHourlyHistoricalDataCutoff();

        expect(dailyCutoff, equals(DateTime(2013, 1, 1)));
        expect(hourlyCutoff, equals(DateTime(2018, 1, 1)));
      });
    });

    group('Lite Plan', () {
      late CoingeckoApiPlan litePlan;

      setUp(() {
        litePlan = const CoingeckoApiPlan.lite();
      });

      test('should have correct default values', () {
        expect(litePlan.monthlyCallLimit, equals(2000000));
        expect(litePlan.rateLimitPerMinute, equals(500));
        expect(litePlan.attributionRequired, isFalse);
      });

      test('should have correct pricing', () {
        expect(litePlan.monthlyPriceUsd, equals(499.0));
        expect(litePlan.yearlyPriceUsd, equals(4790.4));
      });

      test('should have correct call limit description', () {
        expect(litePlan.monthlyCallLimitDescription, equals('2M calls/month'));
      });
    });

    group('Pro Plan', () {
      late CoingeckoApiPlan proPlan;

      setUp(() {
        proPlan = const CoingeckoApiPlan.pro();
      });

      test('should have correct default values', () {
        expect(proPlan.monthlyCallLimit, equals(5000000));
        expect(proPlan.rateLimitPerMinute, equals(1000));
        expect(proPlan.attributionRequired, isFalse);
      });

      test('should allow custom call limits', () {
        final pro8M = const CoingeckoApiPlan.pro(monthlyCallLimit: 8000000);
        final pro10M = const CoingeckoApiPlan.pro(monthlyCallLimit: 10000000);
        final pro15M = const CoingeckoApiPlan.pro(monthlyCallLimit: 15000000);

        expect(pro8M.monthlyCallLimit, equals(8000000));
        expect(pro10M.monthlyCallLimit, equals(10000000));
        expect(pro15M.monthlyCallLimit, equals(15000000));

        expect(pro8M.monthlyCallLimitDescription, equals('8M calls/month'));
        expect(pro10M.monthlyCallLimitDescription, equals('10M calls/month'));
        expect(pro15M.monthlyCallLimitDescription, equals('15M calls/month'));
      });

      test('should have correct pricing', () {
        expect(proPlan.monthlyPriceUsd, equals(999.0));
        expect(proPlan.yearlyPriceUsd, equals(9590.4));
      });

      test('should have higher rate limit', () {
        expect(proPlan.rateLimitDescription, equals('1000 calls/minute'));
      });
    });

    group('Enterprise Plan', () {
      late CoingeckoApiPlan enterprisePlan;

      setUp(() {
        enterprisePlan = const CoingeckoApiPlan.enterprise();
      });

      test('should have unlimited calls and rate limits by default', () {
        expect(enterprisePlan.monthlyCallLimit, isNull);
        expect(enterprisePlan.rateLimitPerMinute, isNull);
        expect(enterprisePlan.hasUnlimitedCalls, isTrue);
        expect(enterprisePlan.hasUnlimitedRateLimit, isTrue);
      });

      test('should support custom limits', () {
        final customEnterprise = const CoingeckoApiPlan.enterprise(
          monthlyCallLimit: 50000000,
          rateLimitPerMinute: 5000,
        );

        expect(customEnterprise.monthlyCallLimit, equals(50000000));
        expect(customEnterprise.rateLimitPerMinute, equals(5000));
        expect(customEnterprise.hasUnlimitedCalls, isFalse);
        expect(customEnterprise.hasUnlimitedRateLimit, isFalse);
      });

      test('should have SLA support by default', () {
        expect(enterprisePlan.hasSlaSupport, isTrue);
      });

      test('should allow disabling SLA', () {
        final noSlaEnterprise = const CoingeckoApiPlan.enterprise(
          hasSla: false,
        );
        expect(noSlaEnterprise.hasSlaSupport, isFalse);
      });

      test('should have custom pricing', () {
        expect(enterprisePlan.monthlyPriceUsd, isNull);
        expect(enterprisePlan.yearlyPriceUsd, isNull);
      });

      test('should have custom descriptions for unlimited plans', () {
        expect(
          enterprisePlan.monthlyCallLimitDescription,
          equals('Custom call credits'),
        );
        expect(
          enterprisePlan.rateLimitDescription,
          equals('Custom rate limit'),
        );
      });

      test('should have extended 5-minutely historical data access', () {
        expect(
          enterprisePlan.fiveMinutelyHistoricalDataDescription,
          equals('5-minutely historical data from 2018'),
        );

        final fiveMinutelyCutoff = enterprisePlan
            .get5MinutelyHistoricalDataCutoff();
        expect(fiveMinutelyCutoff, equals(DateTime(2018, 1, 1)));
      });
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize demo plan correctly', () {
        const original = CoingeckoApiPlan.demo();
        final json = original.toJson();
        final restored = CoingeckoApiPlan.fromJson(json);

        expect(restored.monthlyCallLimit, equals(original.monthlyCallLimit));
        expect(
          restored.rateLimitPerMinute,
          equals(original.rateLimitPerMinute),
        );
        expect(
          restored.attributionRequired,
          equals(original.attributionRequired),
        );
        expect(restored.planName, equals(original.planName));
      });

      test('should serialize and deserialize enterprise plan correctly', () {
        const original = CoingeckoApiPlan.enterprise(
          monthlyCallLimit: 100000000,
          rateLimitPerMinute: 10000,
          hasSla: false,
        );
        final json = original.toJson();
        final restored = CoingeckoApiPlan.fromJson(json);

        expect(restored.monthlyCallLimit, equals(original.monthlyCallLimit));
        expect(
          restored.rateLimitPerMinute,
          equals(original.rateLimitPerMinute),
        );
        expect(
          restored.attributionRequired,
          equals(original.attributionRequired),
        );
        expect(restored.hasSlaSupport, equals(original.hasSlaSupport));
      });
    });

    group('Call Limit Descriptions', () {
      test('should format small numbers correctly', () {
        const plan = CoingeckoApiPlan.demo(monthlyCallLimit: 500);
        expect(plan.monthlyCallLimitDescription, equals('500 calls/month'));
      });

      test('should format thousands correctly', () {
        const plan = CoingeckoApiPlan.demo(monthlyCallLimit: 1500);
        expect(plan.monthlyCallLimitDescription, equals('1.5K calls/month'));
      });

      test('should format millions correctly', () {
        const plan = CoingeckoApiPlan.demo(monthlyCallLimit: 2500000);
        expect(plan.monthlyCallLimitDescription, equals('2.5M calls/month'));
      });

      test('should format whole thousands without decimals', () {
        const plan = CoingeckoApiPlan.demo(monthlyCallLimit: 1000);
        expect(plan.monthlyCallLimitDescription, equals('1K calls/month'));
      });

      test('should format whole millions without decimals', () {
        const plan = CoingeckoApiPlan.demo(monthlyCallLimit: 5000000);
        expect(plan.monthlyCallLimitDescription, equals('5M calls/month'));
      });
    });

    group('Historical Data Validation', () {
      test('should validate timestamps correctly for different plans', () {
        const demo = CoingeckoApiPlan.demo();
        const analyst = CoingeckoApiPlan.analyst();
        const enterprise = CoingeckoApiPlan.enterprise();

        final now = DateTime.now().toUtc();
        final oldDate = DateTime(2010, 1, 1);
        final sixMonthsAgo = now.subtract(const Duration(days: 180));
        final twoYearsAgo = now.subtract(const Duration(days: 730));

        // Demo plan should reject old dates but accept recent ones
        expect(demo.isWithinDailyHistoricalLimit(oldDate), isFalse);
        expect(demo.isWithinDailyHistoricalLimit(twoYearsAgo), isFalse);
        expect(demo.isWithinDailyHistoricalLimit(sixMonthsAgo), isTrue);

        // Analyst plan should accept dates from 2013
        expect(analyst.isWithinDailyHistoricalLimit(oldDate), isFalse);
        expect(
          analyst.isWithinDailyHistoricalLimit(DateTime(2014, 1, 1)),
          isTrue,
        );

        // Enterprise plan should accept dates from 2013
        expect(
          enterprise.isWithinDailyHistoricalLimit(DateTime(2014, 1, 1)),
          isTrue,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle null values in enterprise plan correctly', () {
        const enterprise = CoingeckoApiPlan.enterprise();

        expect(enterprise.hasUnlimitedCalls, isTrue);
        expect(enterprise.hasUnlimitedRateLimit, isTrue);
        expect(
          enterprise.monthlyCallLimitDescription,
          equals('Custom call credits'),
        );
        expect(enterprise.rateLimitDescription, equals('Custom rate limit'));
      });

      test('should handle custom enterprise plan with specific limits', () {
        const enterprise = CoingeckoApiPlan.enterprise(
          monthlyCallLimit: 25000000,
          rateLimitPerMinute: 2500,
        );

        expect(enterprise.hasUnlimitedCalls, isFalse);
        expect(enterprise.hasUnlimitedRateLimit, isFalse);
        expect(
          enterprise.monthlyCallLimitDescription,
          equals('25M calls/month'),
        );
        expect(enterprise.rateLimitDescription, equals('2500 calls/minute'));
      });
    });
  });
}
