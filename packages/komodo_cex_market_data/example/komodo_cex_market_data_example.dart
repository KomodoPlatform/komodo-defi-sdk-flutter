// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Example demonstrating rate limit handling in the Komodo CEX Market Data package.
///
/// This example shows how the system automatically handles 429 (Too Many Requests)
/// responses and falls back to healthy repositories.
Future<void> main() async {
  print('🚀 Starting Komodo CEX Market Data Rate Limit Example\n');

  // Setup dependency injection
  final di = GetIt.asNewInstance();

  // Configure with multiple repositories for fallback demonstration
  const config = MarketDataConfig(
    enableKomodoPrice: true,
    enableBinance: true,
    enableCoinGecko: true,
    repositoryPriority: [
      RepositoryType.coinGecko, // Primary
      RepositoryType.binance, // Fallback 1
      RepositoryType.komodoPrice, // Fallback 2
    ],
  );

  try {
    // Bootstrap the market data system
    await MarketDataBootstrap.register(di, config: config);

    final repos = await MarketDataBootstrap.buildRepositoryList(di, config);
    final manager = CexMarketDataManager(
      priceRepositories: repos,
      selectionStrategy: di<RepositorySelectionStrategy>(),
    );

    await manager.init();
    print(
      '✅ Market data manager initialized with ${repos.length} repositories\n',
    );

    // Create test asset (Bitcoin)
    final btcAsset = AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'BTC'),
      chainId: AssetChainId(chainId: 0),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );

    // Example 1: Normal operation - all repositories healthy
    print('📊 Example 1: Normal operation');
    await demonstrateNormalOperation(manager, btcAsset);

    // Example 2: Simulated rate limit handling
    print('\n🚦 Example 2: Rate limit simulation');
    await demonstrateRateLimitHandling(manager, btcAsset);

    // Example 3: Repository recovery
    print('\n🔄 Example 3: Repository recovery');
    await demonstrateRepositoryRecovery(manager, btcAsset);

    await manager.dispose();
    print('\n✅ Example completed successfully!');
  } catch (e, stackTrace) {
    print('❌ Error in example: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Demonstrates normal operation when all repositories are healthy
Future<void> demonstrateNormalOperation(
  CexMarketDataManager manager,
  AssetId asset,
) async {
  try {
    print('Fetching Bitcoin price...');

    final price = await manager.fiatPrice(asset);
    print('💰 Current BTC price: \$${price.toStringAsFixed(2)}');

    final change24h = await manager.priceChange24h(asset);
    if (change24h != null) {
      final changePercent = (change24h * 100).toStringAsFixed(2);
      final isPositive = change24h >= 0;
      final arrow = isPositive ? '📈' : '📉';
      print('$arrow 24h change: ${isPositive ? '+' : ''}$changePercent%');
    }
  } catch (e) {
    print('❌ Failed to fetch price: $e');
  }
}

/// Demonstrates how the system handles rate limit errors
Future<void> demonstrateRateLimitHandling(
  CexMarketDataManager manager,
  AssetId asset,
) async {
  print('Simulating rate limit scenario...\n');

  // In a real scenario, this would happen naturally when a repository
  // returns a 429 response. For demonstration, we'll show the concept:

  print('📝 Note: In real usage, rate limits are detected automatically:');
  print('   - HTTP 429 status codes');
  print('   - "Too many requests" error messages');
  print('   - "Rate limit" error text');

  print('\n🔍 When a 429 error occurs:');
  print('   1. Repository is immediately marked as unhealthy');
  print('   2. 5-minute backoff period starts');
  print('   3. Requests automatically fall back to healthy repositories');
  print('   4. No manual intervention required');

  // Example of what the error detection looks like
  final exampleErrors = [
    http.ClientException('HTTP 429: Too Many Requests'),
    Exception('API rate limit exceeded'),
    Exception('Too many requests - please try again later'),
  ];

  print('\n🧪 Example error patterns detected as rate limits:');
  for (final error in exampleErrors) {
    print('   ✓ "${error.toString()}"');
  }

  // Demonstrate continued operation during rate limits
  print('\n🔄 System continues operating with available repositories...');
  try {
    final price = await manager.maybeFiatPrice(asset);
    if (price != null) {
      print(
        '💰 Fallback price fetch successful: \$${price.toStringAsFixed(2)}',
      );
    } else {
      print('⚠️  All repositories temporarily unavailable');
    }
  } catch (e) {
    print('❌ Error during fallback: $e');
  }
}

/// Demonstrates how repositories recover from rate limits
Future<void> demonstrateRepositoryRecovery(
  CexMarketDataManager manager,
  AssetId asset,
) async {
  print('Repository health and recovery process...\n');

  print('🏥 Repository Health Management:');
  print('   • Rate-limited repositories: 5-minute backoff');
  print('   • Failed repositories: Progressive backoff (3 failures = 5min)');
  print('   • Successful requests: Immediate health restoration');

  print('\n⏰ Recovery Timeline:');
  print('   1. Rate limit detected → Immediate exclusion');
  print('   2. 5 minutes pass → Repository becomes available again');
  print('   3. Next successful request → Full health restored');

  print('\n🎯 Benefits:');
  print('   • Prevents cascading rate limit violations');
  print('   • Maintains service availability through fallbacks');
  print('   • Automatic recovery without manual intervention');
  print('   • Intelligent request routing based on health');

  // Show that the system continues to work
  try {
    final price = await manager.maybeFiatPrice(asset);
    if (price != null) {
      print('\n✅ System operational - price: \$${price.toStringAsFixed(2)}');
    }
  } catch (e) {
    print('\n⚠️  Could not fetch price: $e');
  }
}
