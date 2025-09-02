/// Komodo CEX market data library for fetching and managing cryptocurrency
/// market data.
///
/// This library provides comprehensive support for multiple cryptocurrency
/// market data providers
/// including Binance, CoinGecko, and CoinPaprika. It features:
///
/// * Multiple market data providers with fallback capabilities
/// * Repository selection strategies and priority management
/// * Robust error handling and retry mechanisms
/// * OHLC data, price information, and market statistics
/// * Sparkline data for charts and visualizations
/// * Bootstrap functionality for initial data setup
/// * Hive-based caching and persistence
///
/// ## Usage
///
/// The library is designed to work with the broader Komodo DeFi SDK ecosystem
/// and provides a unified interface for accessing market data across different
/// centralized exchanges and data providers.
///
/// ## Providers
///
/// * **Binance**: High-priority provider for real-time market data
/// * **CoinGecko**: Primary fallback provider with comprehensive coverage
/// * **CoinPaprika**: Secondary fallback provider
/// * **Komodo**: Internal price data and calculations
///
/// The library automatically handles provider selection, fallbacks, and
/// error recovery to ensure reliable market data access.
library komodo_cex_market_data;

// Export all generated indices for comprehensive API coverage
export 'src/_core_index.dart';
export 'src/_internal_exports.dart';
