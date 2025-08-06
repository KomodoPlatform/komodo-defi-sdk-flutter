// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_currency.freezed.dart';
part 'quote_currency.g.dart';

/// Base class for all currencies used in price quotations
@freezed
sealed class QuoteCurrency with _$QuoteCurrency {
  /// Traditional fiat currencies issued by governments
  const factory QuoteCurrency.fiat({
    required String symbol,
    required String displayName,
  }) = FiatQuoteCurrency;

  /// Stablecoins pegged to fiat currencies
  const factory QuoteCurrency.stablecoin({
    required String symbol,
    required String displayName,
    required FiatQuoteCurrency underlyingFiat,
  }) = StablecoinQuoteCurrency;

  /// Cryptocurrencies used as quote currencies
  const factory QuoteCurrency.crypto({
    required String symbol,
    required String displayName,
  }) = CryptocurrencyQuoteCurrency;

  /// Commodities and special currencies
  const factory QuoteCurrency.commodity({
    required String symbol,
    required String displayName,
  }) = CommodityQuoteCurrency;

  const QuoteCurrency._();

  factory QuoteCurrency.fromJson(Map<String, dynamic> json) =>
      _$QuoteCurrencyFromJson(json);

  /// Get the CoinGecko vs_currency identifier
  String get coinGeckoId {
    return when(
      fiat: (symbol, displayName) {
        // Special case for Turkish Lira
        if (symbol == 'TRY') return 'try';
        return symbol.toLowerCase();
      },
      stablecoin:
          (symbol, displayName, underlyingFiat) => underlyingFiat.coinGeckoId,
      crypto: (symbol, displayName) => symbol.toLowerCase(),
      commodity: (symbol, displayName) => symbol.toLowerCase(),
    );
  }

  /// Get the Binance API identifier
  String get binanceId {
    return when(
      fiat: (symbol, displayName) => symbol.toUpperCase(),
      stablecoin: (symbol, displayName, underlyingFiat) => symbol.toUpperCase(),
      crypto: (symbol, displayName) => symbol.toUpperCase(),
      commodity: (symbol, displayName) => symbol.toUpperCase(),
    );
  }

  /// Get the symbol for this currency
  @override
  String get symbol {
    return when(
      fiat: (symbol, displayName) => symbol,
      stablecoin: (symbol, displayName, underlyingFiat) => symbol,
      crypto: (symbol, displayName) => symbol,
      commodity: (symbol, displayName) => symbol,
    );
  }

  /// Get the display name for this currency
  @override
  String get displayName {
    return when(
      fiat: (symbol, displayName) => displayName,
      stablecoin: (symbol, displayName, underlyingFiat) => displayName,
      crypto: (symbol, displayName) => displayName,
      commodity: (symbol, displayName) => displayName,
    );
  }

  /// Parse a string to QuoteCurrency, case-insensitive
  static QuoteCurrency? fromString(String value) {
    // Check each type
    return FiatCurrency.fromString(value) ??
        Stablecoin.fromString(value) ??
        Cryptocurrency.fromString(value) ??
        Commodity.fromString(value);
  }

  /// Parse a string to QuoteCurrency with fallback to USD
  static QuoteCurrency fromStringOrDefault(
    String value, [
    QuoteCurrency? defaultCurrency,
  ]) {
    return fromString(value) ?? defaultCurrency ?? FiatCurrency.usd;
  }

  @override
  String toString() => symbol;
}

/// Static constants and helper methods for Fiat currencies
class FiatCurrency {
  FiatCurrency._();

  // USD and major fiat currencies
  static const usd = QuoteCurrency.fiat(
    symbol: 'USD',
    displayName: 'US Dollar',
  );
  static const eur = QuoteCurrency.fiat(symbol: 'EUR', displayName: 'Euro');
  static const gbp = QuoteCurrency.fiat(
    symbol: 'GBP',
    displayName: 'British Pound',
  );
  static const jpy = QuoteCurrency.fiat(
    symbol: 'JPY',
    displayName: 'Japanese Yen',
  );
  static const cny = QuoteCurrency.fiat(
    symbol: 'CNY',
    displayName: 'Chinese Yuan',
  );
  static const krw = QuoteCurrency.fiat(
    symbol: 'KRW',
    displayName: 'Korean Won',
  );
  static const aud = QuoteCurrency.fiat(
    symbol: 'AUD',
    displayName: 'Australian Dollar',
  );
  static const cad = QuoteCurrency.fiat(
    symbol: 'CAD',
    displayName: 'Canadian Dollar',
  );
  static const chf = QuoteCurrency.fiat(
    symbol: 'CHF',
    displayName: 'Swiss Franc',
  );
  static const aed = QuoteCurrency.fiat(
    symbol: 'AED',
    displayName: 'UAE Dirham',
  );
  static const ars = QuoteCurrency.fiat(
    symbol: 'ARS',
    displayName: 'Argentine Peso',
  );
  static const bdt = QuoteCurrency.fiat(
    symbol: 'BDT',
    displayName: 'Bangladeshi Taka',
  );
  static const bhd = QuoteCurrency.fiat(
    symbol: 'BHD',
    displayName: 'Bahraini Dinar',
  );
  static const bmd = QuoteCurrency.fiat(
    symbol: 'BMD',
    displayName: 'Bermudian Dollar',
  );
  static const brl = QuoteCurrency.fiat(
    symbol: 'BRL',
    displayName: 'Brazilian Real',
  );
  static const clp = QuoteCurrency.fiat(
    symbol: 'CLP',
    displayName: 'Chilean Peso',
  );
  static const czk = QuoteCurrency.fiat(
    symbol: 'CZK',
    displayName: 'Czech Koruna',
  );
  static const dkk = QuoteCurrency.fiat(
    symbol: 'DKK',
    displayName: 'Danish Krone',
  );
  static const gel = QuoteCurrency.fiat(
    symbol: 'GEL',
    displayName: 'Georgian Lari',
  );
  static const hkd = QuoteCurrency.fiat(
    symbol: 'HKD',
    displayName: 'Hong Kong Dollar',
  );
  static const huf = QuoteCurrency.fiat(
    symbol: 'HUF',
    displayName: 'Hungarian Forint',
  );
  static const idr = QuoteCurrency.fiat(
    symbol: 'IDR',
    displayName: 'Indonesian Rupiah',
  );
  static const ils = QuoteCurrency.fiat(
    symbol: 'ILS',
    displayName: 'Israeli Shekel',
  );
  static const inr = QuoteCurrency.fiat(
    symbol: 'INR',
    displayName: 'Indian Rupee',
  );
  static const kwd = QuoteCurrency.fiat(
    symbol: 'KWD',
    displayName: 'Kuwaiti Dinar',
  );
  static const lkr = QuoteCurrency.fiat(
    symbol: 'LKR',
    displayName: 'Sri Lankan Rupee',
  );
  static const mmk = QuoteCurrency.fiat(
    symbol: 'MMK',
    displayName: 'Myanmar Kyat',
  );
  static const mxn = QuoteCurrency.fiat(
    symbol: 'MXN',
    displayName: 'Mexican Peso',
  );
  static const myr = QuoteCurrency.fiat(
    symbol: 'MYR',
    displayName: 'Malaysian Ringgit',
  );
  static const ngn = QuoteCurrency.fiat(
    symbol: 'NGN',
    displayName: 'Nigerian Naira',
  );
  static const nok = QuoteCurrency.fiat(
    symbol: 'NOK',
    displayName: 'Norwegian Krone',
  );
  static const nzd = QuoteCurrency.fiat(
    symbol: 'NZD',
    displayName: 'New Zealand Dollar',
  );
  static const php = QuoteCurrency.fiat(
    symbol: 'PHP',
    displayName: 'Philippine Peso',
  );
  static const pkr = QuoteCurrency.fiat(
    symbol: 'PKR',
    displayName: 'Pakistani Rupee',
  );
  static const pln = QuoteCurrency.fiat(
    symbol: 'PLN',
    displayName: 'Polish Zloty',
  );
  static const rub = QuoteCurrency.fiat(
    symbol: 'RUB',
    displayName: 'Russian Ruble',
  );
  static const sar = QuoteCurrency.fiat(
    symbol: 'SAR',
    displayName: 'Saudi Riyal',
  );
  static const sek = QuoteCurrency.fiat(
    symbol: 'SEK',
    displayName: 'Swedish Krona',
  );
  static const sgd = QuoteCurrency.fiat(
    symbol: 'SGD',
    displayName: 'Singapore Dollar',
  );
  static const thb = QuoteCurrency.fiat(
    symbol: 'THB',
    displayName: 'Thai Baht',
  );
  static const tryLira = QuoteCurrency.fiat(
    symbol: 'TRY',
    displayName: 'Turkish Lira',
  );
  static const twd = QuoteCurrency.fiat(
    symbol: 'TWD',
    displayName: 'Taiwan Dollar',
  );
  static const uah = QuoteCurrency.fiat(
    symbol: 'UAH',
    displayName: 'Ukrainian Hryvnia',
  );
  static const vef = QuoteCurrency.fiat(
    symbol: 'VEF',
    displayName: 'Venezuelan Bolívar',
  );
  static const vnd = QuoteCurrency.fiat(
    symbol: 'VND',
    displayName: 'Vietnamese Dong',
  );
  static const zar = QuoteCurrency.fiat(
    symbol: 'ZAR',
    displayName: 'South African Rand',
  );

  /// List of all available fiat currencies.
  ///
  /// This array is useful for:
  /// - Iterating over all fiat currencies (e.g., for UI dropdowns)
  /// - Validation and testing purposes
  /// - Checking the total count of supported fiat currencies
  ///
  /// Example usage:
  /// ```dart
  /// // Build a dropdown of all fiat currencies
  /// for (final currency in FiatCurrency.values) {
  ///   print('${currency.symbol}: ${currency.displayName}');
  /// }
  /// ```
  static const values = [
    usd,
    eur,
    gbp,
    jpy,
    cny,
    krw,
    aud,
    cad,
    chf,
    aed,
    ars,
    bdt,
    bhd,
    bmd,
    brl,
    clp,
    czk,
    dkk,
    gel,
    hkd,
    huf,
    idr,
    ils,
    inr,
    kwd,
    lkr,
    mmk,
    mxn,
    myr,
    ngn,
    nok,
    nzd,
    php,
    pkr,
    pln,
    rub,
    sar,
    sek,
    sgd,
    thb,
    tryLira,
    twd,
    uah,
    vef,
    vnd,
    zar,
  ];

  /// Optimized lookup map for fast symbol-to-currency resolution.
  ///
  /// This map provides O(1) lookup performance for the `fromString` method,
  /// automatically generated from the `values` array to ensure consistency.
  /// Keys are uppercase currency symbols for case-insensitive matching.
  ///
  /// Internal use only - prefer using `fromString()` method for lookups.
  static final Map<String, QuoteCurrency> _currencyMap = {
    for (final currency in values) currency.symbol.toUpperCase(): currency,
  };

  static QuoteCurrency? fromString(String value) {
    return _currencyMap[value.toUpperCase()];
  }
}

/// Static constants and helper methods for Stablecoins
class Stablecoin {
  Stablecoin._();

  // USD-pegged stablecoins
  static const usdt = QuoteCurrency.stablecoin(
    symbol: 'USDT',
    displayName: 'Tether',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const usdc = QuoteCurrency.stablecoin(
    symbol: 'USDC',
    displayName: 'USD Coin',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const busd = QuoteCurrency.stablecoin(
    symbol: 'BUSD',
    displayName: 'Binance USD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const dai = QuoteCurrency.stablecoin(
    symbol: 'DAI',
    displayName: 'MakerDAO DAI',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const tusd = QuoteCurrency.stablecoin(
    symbol: 'TUSD',
    displayName: 'TrueUSD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const frax = QuoteCurrency.stablecoin(
    symbol: 'FRAX',
    displayName: 'Frax',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const lusd = QuoteCurrency.stablecoin(
    symbol: 'LUSD',
    displayName: 'Liquity USD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const gusd = QuoteCurrency.stablecoin(
    symbol: 'GUSD',
    displayName: 'Gemini Dollar',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const usdp = QuoteCurrency.stablecoin(
    symbol: 'USDP',
    displayName: 'Pax Dollar',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const susd = QuoteCurrency.stablecoin(
    symbol: 'SUSD',
    displayName: 'Synthetix USD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const fei = QuoteCurrency.stablecoin(
    symbol: 'FEI',
    displayName: 'Fei USD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const tribe = QuoteCurrency.stablecoin(
    symbol: 'TRIBE',
    displayName: 'Tribe',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const ust = QuoteCurrency.stablecoin(
    symbol: 'UST',
    displayName: 'TerraUSD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );
  static const ustc = QuoteCurrency.stablecoin(
    symbol: 'USTC',
    displayName: 'TerraClassicUSD',
    underlyingFiat: FiatCurrency.usd as FiatQuoteCurrency,
  );

  // EUR-pegged stablecoins
  static const eurs = QuoteCurrency.stablecoin(
    symbol: 'EURS',
    displayName: 'STASIS EURS',
    underlyingFiat: FiatCurrency.eur as FiatQuoteCurrency,
  );
  static const eurt = QuoteCurrency.stablecoin(
    symbol: 'EURT',
    displayName: 'Tether EUR',
    underlyingFiat: FiatCurrency.eur as FiatQuoteCurrency,
  );
  static const jeur = QuoteCurrency.stablecoin(
    symbol: 'JEUR',
    displayName: 'Jarvis EUR',
    underlyingFiat: FiatCurrency.eur as FiatQuoteCurrency,
  );

  // GBP-pegged stablecoins
  static const gbpt = QuoteCurrency.stablecoin(
    symbol: 'GBPT',
    displayName: 'Tether GBP',
    underlyingFiat: FiatCurrency.gbp as FiatQuoteCurrency,
  );

  // JPY-pegged stablecoins
  static const jpyt = QuoteCurrency.stablecoin(
    symbol: 'JPYT',
    displayName: 'Tether JPY',
    underlyingFiat: FiatCurrency.jpy as FiatQuoteCurrency,
  );

  // CNY-pegged stablecoins
  static const cnyt = QuoteCurrency.stablecoin(
    symbol: 'CNYT',
    displayName: 'Tether CNY',
    underlyingFiat: FiatCurrency.cny as FiatQuoteCurrency,
  );

  /// List of all available stablecoins.
  ///
  /// This array is useful for:
  /// - Iterating over all stablecoins (e.g., for UI components)
  /// - Filtering by underlying fiat currency
  /// - Validation and testing purposes
  /// - Analytics on supported stablecoins
  ///
  /// Example usage:
  /// ```dart
  /// // Find all USD-pegged stablecoins
  /// final usdStablecoins = Stablecoin.values.where((coin) =>
  ///   coin.when(stablecoin: (_, __, underlying) => underlying == FiatCurrency.usd,
  ///             orElse: () => false));
  /// ```
  static const values = [
    usdt,
    usdc,
    busd,
    dai,
    tusd,
    frax,
    lusd,
    gusd,
    usdp,
    susd,
    fei,
    tribe,
    ust,
    ustc,
    eurs,
    eurt,
    jeur,
    gbpt,
    jpyt,
    cnyt,
  ];

  /// Optimized lookup map for fast symbol-to-stablecoin resolution.
  ///
  /// This map provides O(1) lookup performance for the `fromString` method,
  /// automatically generated from the `values` array to ensure consistency.
  /// Keys are uppercase stablecoin symbols for case-insensitive matching.
  ///
  /// Internal use only - prefer using `fromString()` method for lookups.
  static final Map<String, QuoteCurrency> _currencyMap = {
    for (final currency in values) currency.symbol.toUpperCase(): currency,
  };

  static QuoteCurrency? fromString(String value) {
    return _currencyMap[value.toUpperCase()];
  }
}

/// Static constants and helper methods for Cryptocurrencies
class Cryptocurrency {
  Cryptocurrency._();

  static const btc = QuoteCurrency.crypto(
    symbol: 'BTC',
    displayName: 'Bitcoin',
  );
  static const eth = QuoteCurrency.crypto(
    symbol: 'ETH',
    displayName: 'Ethereum',
  );
  static const ltc = QuoteCurrency.crypto(
    symbol: 'LTC',
    displayName: 'Litecoin',
  );
  static const bch = QuoteCurrency.crypto(
    symbol: 'BCH',
    displayName: 'Bitcoin Cash',
  );
  static const bnb = QuoteCurrency.crypto(
    symbol: 'BNB',
    displayName: 'Binance Coin',
  );
  static const eos = QuoteCurrency.crypto(symbol: 'EOS', displayName: 'EOS');
  static const xrp = QuoteCurrency.crypto(symbol: 'XRP', displayName: 'Ripple');
  static const xlm = QuoteCurrency.crypto(
    symbol: 'XLM',
    displayName: 'Stellar',
  );
  static const link = QuoteCurrency.crypto(
    symbol: 'LINK',
    displayName: 'Chainlink',
  );
  static const dot = QuoteCurrency.crypto(
    symbol: 'DOT',
    displayName: 'Polkadot',
  );
  static const yfi = QuoteCurrency.crypto(
    symbol: 'YFI',
    displayName: 'yearn.finance',
  );
  static const sol = QuoteCurrency.crypto(symbol: 'SOL', displayName: 'Solana');
  static const bits = QuoteCurrency.crypto(
    symbol: 'BITS',
    displayName: 'Bitcoin Bits',
  );
  static const sats = QuoteCurrency.crypto(
    symbol: 'SATS',
    displayName: 'Bitcoin Satoshis',
  );

  /// List of all available cryptocurrencies used as quote currencies.
  ///
  /// This array is useful for:
  /// - Building UI components with crypto quote options
  /// - Iterating over supported crypto quotes for trading pairs
  /// - Validation and testing purposes
  /// - Analytics on cryptocurrency quote usage
  ///
  /// Example usage:
  /// ```dart
  /// // Build a list of crypto quote options
  /// final cryptoQuotes = Cryptocurrency.values.map((crypto) =>
  ///   DropdownMenuItem(value: crypto, child: Text(crypto.displayName)));
  /// ```
  static const values = [
    btc,
    eth,
    ltc,
    bch,
    bnb,
    eos,
    xrp,
    xlm,
    link,
    dot,
    yfi,
    sol,
    bits,
    sats,
  ];

  /// Optimized lookup map for fast symbol-to-cryptocurrency resolution.
  ///
  /// This map provides O(1) lookup performance for the `fromString` method,
  /// automatically generated from the `values` array to ensure consistency.
  /// Keys are uppercase cryptocurrency symbols for case-insensitive matching.
  ///
  /// Internal use only - prefer using `fromString()` method for lookups.
  static final Map<String, QuoteCurrency> _currencyMap = {
    for (final currency in values) currency.symbol.toUpperCase(): currency,
  };

  static QuoteCurrency? fromString(String value) {
    return _currencyMap[value.toUpperCase()];
  }
}

/// Static constants and helper methods for Commodities
class Commodity {
  Commodity._();

  static const xdr = QuoteCurrency.commodity(
    symbol: 'XDR',
    displayName: 'Special Drawing Rights',
  );
  static const xag = QuoteCurrency.commodity(
    symbol: 'XAG',
    displayName: 'Silver',
  );
  static const xau = QuoteCurrency.commodity(
    symbol: 'XAU',
    displayName: 'Gold',
  );

  /// List of all available commodities and special currencies.
  ///
  /// This array is useful for:
  /// - Building UI components with commodity quote options
  /// - Iterating over alternative store-of-value currencies
  /// - Validation and testing purposes
  /// - Special use cases requiring precious metals or SDR pricing
  ///
  /// Example usage:
  /// ```dart
  /// // Check if a currency is a precious metal
  /// final preciousMetals = Commodity.values.where((commodity) =>
  ///   ['XAU', 'XAG'].contains(commodity.symbol));
  /// ```
  static const values = [xdr, xag, xau];

  /// Optimized lookup map for fast symbol-to-commodity resolution.
  ///
  /// This map provides O(1) lookup performance for the `fromString` method,
  /// automatically generated from the `values` array to ensure consistency.
  /// Keys are uppercase commodity symbols for case-insensitive matching.
  ///
  /// Internal use only - prefer using `fromString()` method for lookups.
  static final Map<String, QuoteCurrency> _currencyMap = {
    for (final currency in values) currency.symbol.toUpperCase(): currency,
  };

  static QuoteCurrency? fromString(String value) {
    return _currencyMap[value.toUpperCase()];
  }
}

/// Extension methods for type checking and utility functions
extension QuoteCurrencyTypeChecking on QuoteCurrency {
  bool get isFiat => maybeWhen(fiat: (_, __) => true, orElse: () => false);
  bool get isStablecoin =>
      maybeWhen(stablecoin: (_, __, ___) => true, orElse: () => false);
  bool get isCrypto => maybeWhen(crypto: (_, __) => true, orElse: () => false);
  bool get isCommodity =>
      maybeWhen(commodity: (_, __) => true, orElse: () => false);

  /// Get the underlying fiat currency (returns self if already fiat, or underlying for stablecoins)
  QuoteCurrency get underlyingFiat {
    return when(
      fiat: (symbol, displayName) => this,
      stablecoin: (symbol, displayName, underlyingFiat) => underlyingFiat,
      crypto: (symbol, displayName) => FiatCurrency.usd,
      commodity: (symbol, displayName) => FiatCurrency.usd,
    );
  }
}
