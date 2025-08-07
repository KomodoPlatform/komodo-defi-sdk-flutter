import 'package:komodo_cex_market_data/src/models/quote_currency.dart';
import 'package:test/test.dart';

void main() {
  group('QuoteCurrency', () {
    group('fromString', () {
      test('should return FiatCurrency for valid fiat symbols', () {
        expect(QuoteCurrency.fromString('USD'), equals(FiatCurrency.usd));
        expect(QuoteCurrency.fromString('usd'), equals(FiatCurrency.usd));
        expect(QuoteCurrency.fromString('EUR'), equals(FiatCurrency.eur));
        expect(QuoteCurrency.fromString('GBP'), equals(FiatCurrency.gbp));
        expect(QuoteCurrency.fromString('TRY'), equals(FiatCurrency.tryLira));
      });

      test('should return Stablecoin for valid stablecoin symbols', () {
        expect(QuoteCurrency.fromString('USDT'), equals(Stablecoin.usdt));
        expect(QuoteCurrency.fromString('usdt'), equals(Stablecoin.usdt));
        expect(QuoteCurrency.fromString('USDC'), equals(Stablecoin.usdc));
        expect(QuoteCurrency.fromString('DAI'), equals(Stablecoin.dai));
        expect(QuoteCurrency.fromString('EURS'), equals(Stablecoin.eurs));
      });

      test('should return Cryptocurrency for valid crypto symbols', () {
        expect(QuoteCurrency.fromString('BTC'), equals(Cryptocurrency.btc));
        expect(QuoteCurrency.fromString('btc'), equals(Cryptocurrency.btc));
        expect(QuoteCurrency.fromString('ETH'), equals(Cryptocurrency.eth));
        expect(QuoteCurrency.fromString('SOL'), equals(Cryptocurrency.sol));
      });

      test('should return Commodity for valid commodity symbols', () {
        expect(QuoteCurrency.fromString('XAU'), equals(Commodity.xau));
        expect(QuoteCurrency.fromString('xau'), equals(Commodity.xau));
        expect(QuoteCurrency.fromString('XAG'), equals(Commodity.xag));
        expect(QuoteCurrency.fromString('XDR'), equals(Commodity.xdr));
      });

      test('should return null for invalid symbols', () {
        expect(QuoteCurrency.fromString('INVALID'), isNull);
        expect(QuoteCurrency.fromString(''), isNull);
        expect(QuoteCurrency.fromString('123'), isNull);
      });
    });

    group('fromStringOrDefault', () {
      test('should return parsed currency when valid', () {
        expect(
          QuoteCurrency.fromStringOrDefault('EUR'),
          equals(FiatCurrency.eur),
        );
        expect(
          QuoteCurrency.fromStringOrDefault('USDT'),
          equals(Stablecoin.usdt),
        );
      });

      test('should return custom default when provided and symbol invalid', () {
        expect(
          QuoteCurrency.fromStringOrDefault('INVALID', FiatCurrency.eur),
          equals(FiatCurrency.eur),
        );
      });

      test('should return USD when no default provided and symbol invalid', () {
        expect(
          QuoteCurrency.fromStringOrDefault('INVALID'),
          equals(FiatCurrency.usd),
        );
      });
    });

    group('equality and hashCode', () {
      test('should be equal for same currencies', () {
        const currency1 = FiatCurrency.usd;
        const currency2 = FiatCurrency.usd;

        expect(currency1, equals(currency2));
        expect(currency1.hashCode, equals(currency2.hashCode));
      });

      test('should not be equal for different currencies', () {
        const currency1 = FiatCurrency.usd;
        const currency2 = FiatCurrency.eur;

        expect(currency1, isNot(equals(currency2)));
      });

      test('should not be equal for different types with same symbol', () {
        // This would require creating two currencies with same symbol but different types
        // which is not possible with current implementation, so we test different approach
        expect(FiatCurrency.usd, isNot(equals(Stablecoin.usdt)));
      });
    });

    group('toString', () {
      test('should return symbol', () {
        expect(FiatCurrency.usd.toString(), equals('USD'));
        expect(Stablecoin.usdt.toString(), equals('USDT'));
        expect(Cryptocurrency.btc.toString(), equals('BTC'));
        expect(Commodity.xau.toString(), equals('XAU'));
      });
    });
  });

  group('FiatCurrency', () {
    test('should have correct symbol and displayName', () {
      expect(FiatCurrency.usd.symbol, equals('USD'));
      expect(FiatCurrency.usd.displayName, equals('US Dollar'));
      expect(FiatCurrency.tryLira.symbol, equals('TRY'));
      expect(FiatCurrency.tryLira.displayName, equals('Turkish Lira'));
    });

    test('coinGeckoId should handle special cases', () {
      expect(FiatCurrency.tryLira.coinGeckoId, equals('try'));
      expect(FiatCurrency.usd.coinGeckoId, equals('usd'));
      expect(FiatCurrency.eur.coinGeckoId, equals('eur'));
    });

    test('binanceId should map to appropriate trading pairs', () {
      expect(
        FiatCurrency.usd.binanceId,
        equals('USDT'),
      ); // USD maps to USDT stablecoin
      expect(
        FiatCurrency.tryLira.binanceId,
        equals('TRY'),
      ); // TRY is directly supported
      expect(
        FiatCurrency.eur.binanceId,
        equals('EUR'),
      ); // EUR is directly supported
    });

    test('fromString should work case-insensitively', () {
      expect(FiatCurrency.fromString('USD'), equals(FiatCurrency.usd));
      expect(FiatCurrency.fromString('usd'), equals(FiatCurrency.usd));
      expect(FiatCurrency.fromString('Usd'), equals(FiatCurrency.usd));
    });

    test('should contain all expected major currencies', () {
      expect(FiatCurrency.values, contains(FiatCurrency.usd));
      expect(FiatCurrency.values, contains(FiatCurrency.eur));
      expect(FiatCurrency.values, contains(FiatCurrency.gbp));
      expect(FiatCurrency.values, contains(FiatCurrency.jpy));
      expect(FiatCurrency.values, contains(FiatCurrency.cny));
      expect(FiatCurrency.values, contains(FiatCurrency.tryLira));
    });
  });

  group('Stablecoin', () {
    test('should have correct symbol, displayName and underlyingFiat', () {
      expect(Stablecoin.usdt.symbol, equals('USDT'));
      expect(Stablecoin.usdt.displayName, equals('Tether'));
      expect(Stablecoin.usdt.underlyingFiat, equals(FiatCurrency.usd));

      expect(Stablecoin.eurs.underlyingFiat, equals(FiatCurrency.eur));
      expect(Stablecoin.gbpt.underlyingFiat, equals(FiatCurrency.gbp));
    });

    test('coinGeckoId should return underlying fiat coinGeckoId', () {
      expect(Stablecoin.usdt.coinGeckoId, equals('usd'));
      expect(Stablecoin.eurs.coinGeckoId, equals('eur'));
      expect(Stablecoin.gbpt.coinGeckoId, equals('gbp'));
    });

    test('all USD-pegged stablecoins should map to usd coinGeckoId', () {
      final usdStablecoins = [
        Stablecoin.usdt,
        Stablecoin.usdc,
        Stablecoin.busd,
        Stablecoin.dai,
        Stablecoin.tusd,
        Stablecoin.frax,
        Stablecoin.lusd,
        Stablecoin.gusd,
        Stablecoin.usdp,
        Stablecoin.susd,
        Stablecoin.fei,
        Stablecoin.tribe,
        Stablecoin.ust,
        Stablecoin.ustc,
      ];

      for (final stablecoin in usdStablecoins) {
        expect(
          stablecoin.coinGeckoId,
          equals('usd'),
          reason: '${stablecoin.symbol} should map to usd for CoinGecko API',
        );
      }
    });

    test('binanceId should return uppercase symbol', () {
      expect(Stablecoin.usdt.binanceId, equals('USDT'));
      expect(Stablecoin.usdc.binanceId, equals('USDC'));
    });

    test('should contain all expected stablecoins', () {
      expect(Stablecoin.values, contains(Stablecoin.usdt));
      expect(Stablecoin.values, contains(Stablecoin.usdc));
      expect(Stablecoin.values, contains(Stablecoin.dai));
      expect(Stablecoin.values, contains(Stablecoin.eurs));
    });
  });

  group('Cryptocurrency', () {
    test('should have correct symbol and displayName', () {
      expect(Cryptocurrency.btc.symbol, equals('BTC'));
      expect(Cryptocurrency.btc.displayName, equals('Bitcoin'));
      expect(Cryptocurrency.eth.symbol, equals('ETH'));
      expect(Cryptocurrency.eth.displayName, equals('Ethereum'));
    });

    test('coinGeckoId should return lowercase symbol', () {
      expect(Cryptocurrency.btc.coinGeckoId, equals('btc'));
      expect(Cryptocurrency.eth.coinGeckoId, equals('eth'));
    });

    test('binanceId should return uppercase symbol', () {
      expect(Cryptocurrency.btc.binanceId, equals('BTC'));
      expect(Cryptocurrency.eth.binanceId, equals('ETH'));
    });

    test('should contain all expected cryptocurrencies', () {
      expect(Cryptocurrency.values, contains(Cryptocurrency.btc));
      expect(Cryptocurrency.values, contains(Cryptocurrency.eth));
      expect(Cryptocurrency.values, contains(Cryptocurrency.sol));
      expect(Cryptocurrency.values, contains(Cryptocurrency.bits));
      expect(Cryptocurrency.values, contains(Cryptocurrency.sats));
    });
  });

  group('Commodity', () {
    test('should have correct symbol and displayName', () {
      expect(Commodity.xau.symbol, equals('XAU'));
      expect(Commodity.xau.displayName, equals('Gold'));
      expect(Commodity.xag.symbol, equals('XAG'));
      expect(Commodity.xag.displayName, equals('Silver'));
    });

    test('coinGeckoId should return lowercase symbol', () {
      expect(Commodity.xau.coinGeckoId, equals('xau'));
      expect(Commodity.xag.coinGeckoId, equals('xag'));
    });

    test('binanceId should return uppercase symbol', () {
      expect(Commodity.xau.binanceId, equals('XAU'));
      expect(Commodity.xag.binanceId, equals('XAG'));
    });

    test('should contain all expected commodities', () {
      expect(Commodity.values, contains(Commodity.xdr));
      expect(Commodity.values, contains(Commodity.xag));
      expect(Commodity.values, contains(Commodity.xau));
    });
  });

  group('QuoteCurrencyTypeChecking extension', () {
    test('isFiat should return true only for FiatCurrency', () {
      expect(FiatCurrency.usd.isFiat, isTrue);
      expect(Stablecoin.usdt.isFiat, isFalse);
      expect(Cryptocurrency.btc.isFiat, isFalse);
      expect(Commodity.xau.isFiat, isFalse);
    });

    test('isStablecoin should return true only for Stablecoin', () {
      expect(FiatCurrency.usd.isStablecoin, isFalse);
      expect(Stablecoin.usdt.isStablecoin, isTrue);
      expect(Cryptocurrency.btc.isStablecoin, isFalse);
      expect(Commodity.xau.isStablecoin, isFalse);
    });

    test('isCrypto should return true only for Cryptocurrency', () {
      expect(FiatCurrency.usd.isCrypto, isFalse);
      expect(Stablecoin.usdt.isCrypto, isFalse);
      expect(Cryptocurrency.btc.isCrypto, isTrue);
      expect(Commodity.xau.isCrypto, isFalse);
    });

    test('isCommodity should return true only for Commodity', () {
      expect(FiatCurrency.usd.isCommodity, isFalse);
      expect(Stablecoin.usdt.isCommodity, isFalse);
      expect(Cryptocurrency.btc.isCommodity, isFalse);
      expect(Commodity.xau.isCommodity, isTrue);
    });

    test('underlyingFiat should return appropriate fiat currency', () {
      // For fiat currencies, return self
      expect(FiatCurrency.usd.underlyingFiat, equals(FiatCurrency.usd));
      expect(FiatCurrency.eur.underlyingFiat, equals(FiatCurrency.eur));

      // For stablecoins, return underlying fiat
      expect(Stablecoin.usdt.underlyingFiat, equals(FiatCurrency.usd));
      expect(Stablecoin.eurs.underlyingFiat, equals(FiatCurrency.eur));
      expect(Stablecoin.gbpt.underlyingFiat, equals(FiatCurrency.gbp));

      // For cryptos and commodities, return USD as fallback
      expect(Cryptocurrency.btc.underlyingFiat, equals(FiatCurrency.usd));
      expect(Commodity.xau.underlyingFiat, equals(FiatCurrency.usd));
    });
  });

  group('Integration tests', () {
    test(
      'should handle all original enum values from legacy implementation',
      () {
        // Test all USD-pegged stablecoins
        final usdStablecoins = [
          'USDT',
          'USDC',
          'BUSD',
          'DAI',
          'TUSD',
          'FRAX',
          'LUSD',
          'GUSD',
          'USDP',
          'SUSD',
          'FEI',
          'TRIBE',
          'UST',
          'USTC',
        ];

        for (final symbol in usdStablecoins) {
          final currency = QuoteCurrency.fromString(symbol);
          expect(currency, isNotNull, reason: 'Failed to parse $symbol');
          expect(currency!.isStablecoin, isTrue);
          expect(currency.underlyingFiat, equals(FiatCurrency.usd));
        }

        // Test EUR-pegged stablecoins
        final eurStablecoins = ['EURS', 'EURT', 'JEUR'];
        for (final symbol in eurStablecoins) {
          final currency = QuoteCurrency.fromString(symbol);
          expect(currency, isNotNull, reason: 'Failed to parse $symbol');
          expect(currency!.isStablecoin, isTrue);
          expect(currency.underlyingFiat, equals(FiatCurrency.eur));
        }

        // Test major fiat currencies
        final majorFiats = [
          'USD',
          'EUR',
          'GBP',
          'JPY',
          'CNY',
          'KRW',
          'AUD',
          'CAD',
          'CHF',
          'TRY',
        ];
        for (final symbol in majorFiats) {
          final currency = QuoteCurrency.fromString(symbol);
          expect(currency, isNotNull, reason: 'Failed to parse $symbol');
          expect(currency!.isFiat, isTrue);
        }

        // Test cryptocurrencies
        final cryptos = [
          'BTC',
          'ETH',
          'LTC',
          'BCH',
          'BNB',
          'EOS',
          'XRP',
          'XLM',
          'LINK',
          'DOT',
          'YFI',
          'SOL',
          'BITS',
          'SATS',
        ];
        for (final symbol in cryptos) {
          final currency = QuoteCurrency.fromString(symbol);
          expect(currency, isNotNull, reason: 'Failed to parse $symbol');
          expect(currency!.isCrypto, isTrue);
        }

        // Test commodities
        final commodities = ['XDR', 'XAG', 'XAU'];
        for (final symbol in commodities) {
          final currency = QuoteCurrency.fromString(symbol);
          expect(currency, isNotNull, reason: 'Failed to parse $symbol');
          expect(currency!.isCommodity, isTrue);
        }
      },
    );

    test('should maintain API compatibility for CoinGecko IDs', () {
      // Test stablecoin CoinGecko ID mapping
      expect(Stablecoin.usdt.coinGeckoId, equals('usd'));
      expect(Stablecoin.eurs.coinGeckoId, equals('eur'));
      expect(Stablecoin.gbpt.coinGeckoId, equals('gbp'));

      // Test special case for Turkish Lira
      expect(FiatCurrency.tryLira.coinGeckoId, equals('try'));

      // Test direct mapping for other currencies
      expect(Cryptocurrency.btc.coinGeckoId, equals('btc'));
      expect(Commodity.xau.coinGeckoId, equals('xau'));
    });

    test('should maintain API compatibility for Binance IDs', () {
      expect(FiatCurrency.usd.binanceId, equals('USDT')); // USD maps to USDT
      expect(Stablecoin.usdt.binanceId, equals('USDT'));
      expect(Cryptocurrency.btc.binanceId, equals('BTC'));
      expect(Commodity.xau.binanceId, equals('XAU'));
      expect(FiatCurrency.tryLira.binanceId, equals('TRY'));
    });
  });
}
