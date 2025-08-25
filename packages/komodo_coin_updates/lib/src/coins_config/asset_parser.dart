import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// A standardized helper for parsing assets from coin configuration data.
///
/// This provides a common implementation for all coin config providers,
/// ensuring consistent parsing logic and proper parent-child relationships.
class AssetParser {
  /// Creates a new [AssetParser] instance.
  ///
  /// - [loggerName]: The name of the logger to use for logging.
  const AssetParser({this.loggerName = 'AssetParser'});

  /// The name of the logger to use for logging.
  final String loggerName;

  Logger get _log => Logger(loggerName);

  /// Parses a collection of transformed coin configurations into a list of assets.
  ///
  /// This method implements a two-pass parsing strategy:
  /// 1. First pass: Parse platform coins (coins without parent_coin)
  /// 2. Second pass: Parse child coins with proper parent relationships
  ///
  /// Parameters:
  /// - [transformedConfigs]: Map of coin ticker to transformed configuration data
  /// - [shouldFilterCoin]: Optional function to filter out coins (receives coin config)
  /// - [logContext]: Optional context string for logging (e.g., 'from asset bundle')
  ///
  /// Returns a list of successfully parsed assets.
  Future<List<Asset>> parseAssetsFromConfig(
    Map<String, Map<String, dynamic>> transformedConfigs, {
    bool Function(Map<String, dynamic>)? shouldFilterCoin,
    String? logContext,
  }) async {
    final context = logContext != null ? ' $logContext' : '';

    _log.info(
      'Parsing ${transformedConfigs.length} coin configurations$context',
    );

    // Separate platform coins and child coins
    final platformCoins = <String, Map<String, dynamic>>{};
    final childCoins = <String, Map<String, dynamic>>{};

    for (final entry in transformedConfigs.entries) {
      final coinData = entry.value;
      if (_hasNoParent(coinData)) {
        platformCoins[entry.key] = coinData;
      } else {
        childCoins[entry.key] = coinData;
      }
    }

    _log.fine(
      'Found ${platformCoins.length} platform coins and '
      '${childCoins.length} child coins',
    );

    // First pass: Parse platform coin AssetIds. Parent/platform assets are
    // processed first to ensure that child assets can be created with the
    // correct parent relationships.
    final assets = _parseCoinConfigsToAssets(
      platformCoins,
      shouldFilterCoin,
      coinType: 'platform',
    );
    final platformIds = assets.map((e) => e.id).toSet();

    if (platformIds.isEmpty) {
      _log.severe('No platform coin IDs parsed from config$context');
      throw Exception('No platform coin IDs parsed from config$context');
    }

    _log.fine('Parsed ${platformIds.length} platform coin IDs');

    // Second pass: Create child assets with proper parent relationships
    final childAssets = _parseCoinConfigsToAssets(
      childCoins,
      shouldFilterCoin,
      coinType: 'child',
      knownIds: platformIds,
    );
    assets.addAll(childAssets);

    // Something went very wrong if we don't have any assets
    if (assets.isEmpty) {
      _log.severe('No assets parsed from config$context');
      throw Exception('No assets parsed from config$context');
    }

    _log.info('Successfully parsed ${assets.length} assets$context');
    return assets;
  }

  /// Processes a collection of coin configurations and creates assets.
  ///
  /// This helper method encapsulates the common logic for processing both
  /// platform and child coins, including filtering, parsing, and error handling.
  ///
  /// Parameters:
  /// - [coins]: Map of coin ticker to configuration data
  /// - [knownIds]: Set of known AssetIds for resolving parent relationships
  /// - [shouldFilterCoin]: Optional function to filter out coins
  /// - [coinType]: Description of coin type for logging (e.g., 'platform', 'child')
  List<Asset> _parseCoinConfigsToAssets(
    Map<String, Map<String, dynamic>> coins,
    bool Function(Map<String, dynamic>)? shouldFilterCoin, {
    required String coinType,
    Set<AssetId> knownIds = const {},
  }) {
    final assets = <Asset>[];

    for (final entry in coins.entries) {
      final coinData = entry.value;

      if (shouldFilterCoin?.call(coinData) ?? false) {
        _log.fine('Filtered out $coinType coin: ${entry.key}');
        continue;
      }

      // Coin config data may contain coins with missing protocol fields,
      // so we skip those coins rather than throwing an exception and crashing
      // on startup.
      try {
        final asset = Asset.fromJson(coinData, knownIds: knownIds);
        assets.add(asset);
      } on ProtocolException catch (e) {
        _log.warning(
          'Skipping $coinType asset ${entry.key} with missing protocol fields',
          e,
        );

        // This is necessary to catch StateErrors thrown by AssetId.parse,
        // specifically in the case of a missing parent asset. For example, RBTC
        // with a missing RSK parent
        // ignore: avoid_catches_without_on_clauses
      } catch (e, s) {
        _log.severe('Failed to parse $coinType asset ${entry.key}: $e', s);
      }
    }

    return assets;
  }

  /// Helper method to check if a coin configuration has no parent.
  bool _hasNoParent(Map<String, dynamic> coinData) =>
      coinData['parent_coin'] == null;
}
