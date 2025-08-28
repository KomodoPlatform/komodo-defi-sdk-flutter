/// CoinPaprika market data provider implementation.
///
/// This library provides access to cryptocurrency market data through the
/// CoinPaprika API, including coin listings, historical OHLC data, and
/// current market information.
///
/// The CoinPaprika provider is positioned as priority 4 in the repository
/// selection hierarchy, serving as a fallback below CoinGecko.
library coinpaprika;

// Data layer exports
export 'data/coinpaprika_cex_provider.dart';
export 'data/coinpaprika_repository.dart';
// Model exports
export 'models/coinpaprika_coin.dart';
export 'models/coinpaprika_market.dart';

// Note: CoinPaprika OHLC functionality is now integrated into
// the main coin_ohlc.dart file using the Ohlc.coinpaprika factory
