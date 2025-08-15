import 'package:flutter/foundation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Defines a transform that can be applied to a single coin configuration.
///
/// Implementations must indicate whether they need to run for a given
/// configuration and return a transformed copy when applied.
abstract class CoinConfigTransform {
  /// Returns a new configuration with this transform applied.
  ///
  /// Implementations should avoid mutating the original map to preserve
  /// idempotency.
  JsonMap transform(JsonMap config);

  /// Returns true if this transform should be applied to the provided [config].
  bool needsTransform(JsonMap config);
}

/// This class is responsible for doing any necessary fixes to the coin config
/// before it is used by the rest of the library.
/// This should be used only when absolutely necessary and not for transforming
/// the config for easier parsing; that should be encapsulated in the
/// respective classes.
class CoinConfigTransformer {
  /// Creates a new [CoinConfigTransformer] with the provided transforms.
  /// If [transforms] is omitted, a default set is used.
  const CoinConfigTransformer({List<CoinConfigTransform>? transforms})
    : _transforms =
          transforms ?? const [WssWebsocketTransform(), ParentCoinTransform()];

  final List<CoinConfigTransform> _transforms;

  /// Applies all necessary transforms to the given coin configuration.
  JsonMap apply(JsonMap config) {
    final neededTransforms = _transforms.where((t) => t.needsTransform(config));

    if (neededTransforms.isEmpty) {
      return config;
    }

    return neededTransforms.fold(
      config,

      // Instantiating a new map for each transform is not ideal, given the
      // large size of the config file. However, it is necessary to avoid
      // mutating the original map and for making the transforms idempotent.
      // Use sparingly and ideally only once.
      (config, transform) => transform.transform(JsonMap.of(config)),
    );
  }
}

/// This class is responsible for transforming a list of coin configurations.
/// It applies the necessary transforms to each configuration in the list.
class CoinConfigListTransformer {
  const CoinConfigListTransformer();

  /// Applies all registered transforms to each configuration in [configs].
  /// The input list is cloned before modification to preserve immutability.
  static JsonList applyTransforms(
    JsonList configs, {
    CoinConfigTransformer transformer = const CoinConfigTransformer(),
  }) {
    final result = JsonList.of(configs);

    for (var i = 0; i < result.length; i++) {
      result[i] = transformer.apply(result[i]);
    }

    return result;
  }

  /// Applies transforms to each config in the list and filters out coins that should be excluded.
  static JsonList applyTransformsAndFilter(
    JsonList configs, {
    CoinConfigTransformer transformer = const CoinConfigTransformer(),
  }) {
    final transformedList = applyTransforms(configs, transformer: transformer);
    return transformedList
        .where((config) => !const CoinFilter().shouldFilter(config))
        .toList();
  }
}

extension CoinConfigTransformExtension on JsonMap {
  /// Returns a transformed copy of this configuration by applying all
  /// registered transforms.
  JsonMap applyTransforms({
    CoinConfigTransformer transformer = const CoinConfigTransformer(),
  }) => transformer.apply(this);
}

extension CoinConfigListTransformExtension on JsonList {
  /// Returns a transformed copy of the configurations list by applying all
  /// registered transforms to each item.
  JsonList applyTransforms({
    CoinConfigTransformer transformer = const CoinConfigTransformer(),
  }) =>
      CoinConfigListTransformer.applyTransforms(this, transformer: transformer);

  /// Returns a transformed and filtered copy of the configurations list by
  /// applying transforms and then excluding coins that should be filtered.
  JsonList applyTransformsAndFilter({
    CoinConfigTransformer transformer = const CoinConfigTransformer(),
  }) => CoinConfigListTransformer.applyTransformsAndFilter(
    this,
    transformer: transformer,
  );
}

/// If true, only test coins are allowed when filtering.
const bool _isTestCoinsOnly = false;

/// Filters out coins from runtime configuration based on a set of rules.
class CoinFilter {
  const CoinFilter();

  /// Specific coins (by ticker) to exclude from the runtime list.
  static const _filteredCoins = <String, String>{};

  /// Protocol subtypes to exclude from the runtime list.
  static const _filteredProtocolSubTypes = {'SLP': 'Simple Ledger Protocol'};

  // NFT was previosly filtered out, but it is now required with the NFT v2
  // migration. NFT_<COIN> coins are used to represent NFTs on the chain.
  /// Protocol types to exclude from the runtime list.
  static const _filteredProtocolTypes = <String, String>{};

  /// Returns true if the given coin should be filtered out.
  bool shouldFilter(JsonMap config) {
    final coin = config.value<String>('coin');
    final protocolSubClass = config.valueOrNull<String>('type');
    final protocolClass = config.valueOrNull<String>('protocol', 'type');
    final isTestnet = config.valueOrNull<bool>('is_testnet') ?? false;

    return _filteredCoins.containsKey(coin) ||
        _filteredProtocolTypes.containsKey(protocolClass) ||
        _filteredProtocolSubTypes.containsKey(protocolSubClass) ||
        (_isTestCoinsOnly && !isTestnet);
  }
}

/// Filters out non-wss electrum/server URLs from the given coin config for
/// the web platform as only wss connections are supported.
class WssWebsocketTransform implements CoinConfigTransform {
  const WssWebsocketTransform();

  @override
  /// Determines if the transform should run by checking the presence of an
  /// `electrum` list in the configuration.
  bool needsTransform(JsonMap config) {
    final electrum = config.valueOrNull<JsonList>('electrum');
    return electrum != null;
  }

  @override
  /// Filters `electrum` entries based on the platform: WSS-only on web and
  /// non-WSS on native platforms.
  JsonMap transform(JsonMap config) {
    final electrum = JsonList.of(config.value<JsonList>('electrum'));
    // On native, only non-WSS servers are supported. On web, only WSS servers
    // are supported.
    final filteredElectrums = filterElectrums(
      electrum,
      serverType:
          kIsWeb ? ElectrumServerType.wssOnly : ElectrumServerType.nonWssOnly,
    );

    return config..['electrum'] = filteredElectrums;
  }

  /// Returns a filtered copy of [electrums] keeping only entries allowed by
  /// [serverType]. For WSS entries, `ws_url` is normalized to match `url`.
  JsonList filterElectrums(
    JsonList electrums, {
    required ElectrumServerType serverType,
  }) {
    final electrumsCopy = JsonList.of(electrums);

    for (final e in electrumsCopy) {
      if (e['protocol'] == 'WSS') {
        e['ws_url'] = e['url'];
      }
    }

    return electrumsCopy..removeWhere(
      (JsonMap e) =>
          serverType == ElectrumServerType.wssOnly
              ? e['ws_url'] == null
              : e['ws_url'] != null,
    );
  }
}

/// Specifies which type of Electrum servers to retain
enum ElectrumServerType { wssOnly, nonWssOnly }

class ParentCoinTransform implements CoinConfigTransform {
  const ParentCoinTransform();

  @override
  /// Returns true if `parent_coin` exists and requires remapping to a concrete
  /// parent (e.g. `SLP` → `BCH`).
  bool needsTransform(JsonMap config) =>
      config.valueOrNull<String>('parent_coin') != null &&
      _ParentCoinResolver.needsRemapping(config.value('parent_coin'));

  @override
  /// Remaps `parent_coin` to the resolved concrete parent when needed.
  JsonMap transform(JsonMap config) {
    final parentCoin = config.valueOrNull<String>('parent_coin');
    if (parentCoin != null && _ParentCoinResolver.needsRemapping(parentCoin)) {
      return config
        ..['parent_coin'] = _ParentCoinResolver.resolveParentCoin(parentCoin);
    }
    return config;
  }
}

class _ParentCoinResolver {
  const _ParentCoinResolver._();

  static const _parentCoinMappings = {
    'SLP': 'BCH',
    // Add any other mappings here as needed
  };

  /// Resolves the actual parent coin ticker from a given parent coin identifier.
  ///
  /// For example, `SLP` resolves to `BCH` since SLP tokens are BCH tokens.
  static String resolveParentCoin(String parentCoin) =>
      _parentCoinMappings[parentCoin] ?? parentCoin;

  /// Returns true if this parent coin identifier needs remapping.
  static bool needsRemapping(String? parentCoin) =>
      _parentCoinMappings.containsKey(parentCoin);
}
