import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

typedef JsonMap = Map<String, dynamic>;

/// Simple key-value store abstraction for persisting activation configs.
abstract class KeyValueStore {
  Future<JsonMap?> get(String key);
  Future<void> set(String key, JsonMap value);
}

/// In-memory key-value store default implementation.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, JsonMap> _store = {};

  @override
  Future<JsonMap?> get(String key) async => _store[key];

  @override
  Future<void> set(String key, JsonMap value) async {
    _store[key] = value;
  }
}

/// Repository abstraction for typed activation configs.
abstract class ActivationConfigRepository {
  Future<TConfig?> getConfig<TConfig>(WalletId walletId, AssetId id);
  Future<void> saveConfig<TConfig>(
    WalletId walletId,
    AssetId id,
    TConfig config,
  );
}

/// Minimal ZHTLC user configuration.
class ZhtlcUserConfig {
  ZhtlcUserConfig({
    required this.zcashParamsPath,
    this.scanBlocksPerIteration = 1000,
    this.scanIntervalMs = 0,
    this.taskStatusPollingIntervalMs,
    this.syncParams,
  });

  final String zcashParamsPath;
  final int scanBlocksPerIteration;
  final int scanIntervalMs;
  final int? taskStatusPollingIntervalMs;
  final ZhtlcSyncParams? syncParams;

  JsonMap toJson() => {
    'zcashParamsPath': zcashParamsPath,
    'scanBlocksPerIteration': scanBlocksPerIteration,
    'scanIntervalMs': scanIntervalMs,
    if (taskStatusPollingIntervalMs != null)
      'taskStatusPollingIntervalMs': taskStatusPollingIntervalMs,
    if (syncParams != null) 'syncParams': syncParams!.toJsonRequest(),
  };

  static ZhtlcUserConfig fromJson(JsonMap json) => ZhtlcUserConfig(
    zcashParamsPath: json.value<String>('zcashParamsPath'),
    scanBlocksPerIteration:
        json.valueOrNull<int>('scanBlocksPerIteration') ?? 1000,
    scanIntervalMs: json.valueOrNull<int>('scanIntervalMs') ?? 0,
    taskStatusPollingIntervalMs: json.valueOrNull<int>(
      'taskStatusPollingIntervalMs',
    ),
    syncParams: ZhtlcSyncParams.tryParse(
      json.valueOrNull<dynamic>('syncParams'),
    ),
  );
}

/// Simple mapper for typed configs. Extend when adding more protocols.
abstract class ActivationConfigMapper {
  static JsonMap encode(Object config) {
    if (config is ZhtlcUserConfig) return config.toJson();
    throw UnsupportedError('Unsupported config type: ${config.runtimeType}');
  }

  static T decode<T>(JsonMap json) {
    if (T == ZhtlcUserConfig) return ZhtlcUserConfig.fromJson(json) as T;
    throw UnsupportedError('Unsupported type for decode: $T');
  }
}

/// Wrapper class for storing activation configs in Hive.
/// This replaces the problematic Map<String, String> storage approach
/// and provides type safety while using the encode/decode functions.
class HiveActivationConfigWrapper extends HiveObject {
  /// Creates a wrapper from a wallet ID and a map of asset IDs to configurations
  /// [walletId] The wallet ID this configuration belongs to
  /// [configs] The map of asset IDs to configurations
  HiveActivationConfigWrapper({required this.walletId, required this.configs});

  /// Creates a wrapper from individual config components
  /// [walletId] The wallet ID this configuration belongs to
  /// [configs] The map of asset IDs to configurations
  factory HiveActivationConfigWrapper.fromComponents({
    required WalletId walletId,
    required Map<String, Object> configs,
  }) {
    final encodedConfigs = <String, String>{};
    configs.forEach((assetId, config) {
      final json = ActivationConfigMapper.encode(config);
      encodedConfigs[assetId] = jsonEncode(json);
    });
    return HiveActivationConfigWrapper(
      walletId: walletId,
      configs: encodedConfigs,
    );
  }

  /// The wallet ID this configuration belongs to
  @HiveField(0)
  final WalletId walletId;

  /// Map of asset ID to JSON-encoded configuration strings
  @HiveField(1)
  final Map<String, String> configs;

  /// Gets a decoded configuration by asset ID and type
  TConfig? getConfig<TConfig>(String assetId) {
    final encodedConfig = configs[assetId];
    if (encodedConfig == null) return null;

    final json = jsonDecode(encodedConfig) as JsonMap;
    return ActivationConfigMapper.decode<TConfig>(json);
  }

  /// Sets a configuration by asset ID
  HiveActivationConfigWrapper setConfig(String assetId, Object config) {
    final json = ActivationConfigMapper.encode(config);
    final newConfigs = Map<String, String>.from(configs);
    newConfigs[assetId] = jsonEncode(json);

    return HiveActivationConfigWrapper(walletId: walletId, configs: newConfigs);
  }

  /// Removes a configuration by asset ID
  HiveActivationConfigWrapper removeConfig(String assetId) {
    final newConfigs = Map<String, String>.from(configs);
    newConfigs.remove(assetId);

    return HiveActivationConfigWrapper(walletId: walletId, configs: newConfigs);
  }

  /// Checks if a configuration exists for the given asset ID
  bool hasConfig(String assetId) => configs.containsKey(assetId);

  /// Gets all asset IDs that have configurations
  List<String> getAssetIds() => configs.keys.toList();
}

class JsonActivationConfigRepository implements ActivationConfigRepository {
  JsonActivationConfigRepository(this.store);
  final KeyValueStore store;

  String _key(WalletId walletId, AssetId id) =>
      'activation_config:${walletId.compoundId}:${id.id}';

  @override
  Future<TConfig?> getConfig<TConfig>(WalletId walletId, AssetId id) async {
    final data = await store.get(_key(walletId, id));
    if (data == null) return null;
    return ActivationConfigMapper.decode<TConfig>(data);
  }

  @override
  Future<void> saveConfig<TConfig>(
    WalletId walletId,
    AssetId id,
    TConfig config,
  ) async {
    final json = ActivationConfigMapper.encode(config as Object);
    await store.set(_key(walletId, id), json);
  }
}

typedef WalletIdResolver = Future<WalletId?> Function();

/// Service orchestrating retrieval/request of activation configs.
class ActivationConfigService {
  ActivationConfigService(
    this.repo, {
    required WalletIdResolver walletIdResolver,
  }) : _walletIdResolver = walletIdResolver;

  final ActivationConfigRepository repo;
  final WalletIdResolver _walletIdResolver;

  Future<WalletId> _requireActiveWallet() async {
    final walletId = await _walletIdResolver();
    if (walletId == null) {
      throw StateError('Attempted to access activation config with no wallet');
    }
    return walletId;
  }

  Future<ZhtlcUserConfig?> getSavedZhtlc(AssetId id) async {
    final walletId = await _requireActiveWallet();
    return repo.getConfig<ZhtlcUserConfig>(walletId, id);
  }

  Future<ZhtlcUserConfig?> getZhtlcOrRequest(
    AssetId id, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final walletId = await _requireActiveWallet();
    final key = _WalletAssetKey(walletId, id);

    final existing = await repo.getConfig<ZhtlcUserConfig>(walletId, id);
    if (existing != null) return existing;

    final completer = Completer<ZhtlcUserConfig?>();
    _awaitingControllers[key] = completer;
    try {
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () => null,
      );
      if (result == null) return null;
      await repo.saveConfig(walletId, id, result);
      return result;
    } finally {
      _awaitingControllers.remove(key);
    }
  }

  Future<void> saveZhtlcConfig(AssetId id, ZhtlcUserConfig config) async {
    final walletId = await _requireActiveWallet();
    await repo.saveConfig(walletId, id, config);
  }

  Future<void> submitZhtlc(AssetId id, ZhtlcUserConfig config) async {
    final walletId = await _walletIdResolver();
    if (walletId == null) return;
    _awaitingControllers[_WalletAssetKey(walletId, id)]?.complete(config);
  }

  final Map<_WalletAssetKey, Completer<ZhtlcUserConfig?>> _awaitingControllers =
      {};
}

class _WalletAssetKey {
  _WalletAssetKey(this.walletId, this.assetId);

  final WalletId walletId;
  final AssetId assetId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _WalletAssetKey &&
        other.walletId == walletId &&
        other.assetId == assetId;
  }

  @override
  int get hashCode => Object.hash(walletId, assetId);
}

/// UI helper for building configuration forms.
class ActivationSettingDescriptor {
  ActivationSettingDescriptor({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.helpText,
  });

  final String key;
  final String label;
  final String type; // 'path' | 'number' | 'string' | 'boolean' | 'select'
  final bool required;
  final Object? defaultValue;
  final String? helpText;
}

extension AssetIdActivationSettings on AssetId {
  List<ActivationSettingDescriptor> activationSettings() {
    switch (subClass) {
      case CoinSubClass.zhtlc:
        return [
          ActivationSettingDescriptor(
            key: 'zcashParamsPath',
            label: 'Zcash parameters path',
            type: 'path',
            required: true,
            helpText: 'Folder containing Zcash parameters',
          ),
          ActivationSettingDescriptor(
            key: 'scanBlocksPerIteration',
            label: 'Blocks per scan iteration',
            type: 'number',
            defaultValue: 1000,
          ),
          ActivationSettingDescriptor(
            key: 'scanIntervalMs',
            label: 'Scan interval (ms)',
            type: 'number',
            defaultValue: 0,
          ),
          ActivationSettingDescriptor(
            key: 'taskStatusPollingIntervalMs',
            label: 'Task status polling interval (ms)',
            type: 'number',
            defaultValue: 500,
            helpText: 'Delay between status polls while monitoring activation',
          ),
        ];
      default:
        return const [];
    }
  }
}
