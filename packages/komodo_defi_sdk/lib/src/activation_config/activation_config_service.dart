import 'dart:async';

import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

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
  Future<TConfig?> getConfig<TConfig>(AssetId id);
  Future<void> saveConfig<TConfig>(AssetId id, TConfig config);
}

/// Minimal ZHTLC user configuration.
class ZhtlcUserConfig {
  ZhtlcUserConfig({
    required this.zcashParamsPath,
    this.scanBlocksPerIteration = 1000,
    this.scanIntervalMs = 0,
  });

  final String zcashParamsPath;
  final int scanBlocksPerIteration;
  final int scanIntervalMs;

  JsonMap toJson() => {
    'zcashParamsPath': zcashParamsPath,
    'scanBlocksPerIteration': scanBlocksPerIteration,
    'scanIntervalMs': scanIntervalMs,
  };

  static ZhtlcUserConfig fromJson(JsonMap json) => ZhtlcUserConfig(
    zcashParamsPath: json.value<String>('zcashParamsPath'),
    scanBlocksPerIteration:
        json.valueOrNull<int>('scanBlocksPerIteration') ?? 1000,
    scanIntervalMs: json.valueOrNull<int>('scanIntervalMs') ?? 0,
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

class JsonActivationConfigRepository implements ActivationConfigRepository {
  JsonActivationConfigRepository(this.store);
  final KeyValueStore store;

  String _key(AssetId id) => 'activation_config:${id.id}';

  @override
  Future<TConfig?> getConfig<TConfig>(AssetId id) async {
    final data = await store.get(_key(id));
    if (data == null) return null;
    return ActivationConfigMapper.decode<TConfig>(data);
  }

  @override
  Future<void> saveConfig<TConfig>(AssetId id, TConfig config) async {
    final json = ActivationConfigMapper.encode(config as Object);
    await store.set(_key(id), json);
  }
}

/// Service orchestrating retrieval/request of activation configs.
class ActivationConfigService {
  ActivationConfigService(this.repo);
  final ActivationConfigRepository repo;

  Future<ZhtlcUserConfig?> getZhtlcOrRequest(
    AssetId id, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final existing = await repo.getConfig<ZhtlcUserConfig>(id);
    if (existing != null) return existing;

    final completer = Completer<ZhtlcUserConfig?>();
    _awaitingControllers[id] = completer;
    try {
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () => null,
      );
      if (result == null) return null;
      await repo.saveConfig(id, result);
      return result;
    } finally {
      _awaitingControllers.remove(id);
    }
  }

  void submitZhtlc(AssetId id, ZhtlcUserConfig config) {
    _awaitingControllers[id]?.complete(config);
  }

  final Map<AssetId, Completer<ZhtlcUserConfig?>> _awaitingControllers = {};
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
        ];
      default:
        return const [];
    }
  }
}
