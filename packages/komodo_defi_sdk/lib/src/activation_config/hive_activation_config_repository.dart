import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_sdk/src/activation_config/activation_config_service.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

const _walletIdAdapterTypeId = 220;

/// Type adapter for persisting [WalletId] keys inside Hive boxes.
class WalletIdAdapter extends TypeAdapter<WalletId> {
  @override
  int get typeId => _walletIdAdapterTypeId;

  @override
  WalletId read(BinaryReader reader) {
    final json = jsonDecode(reader.readString()) as Map<String, dynamic>;
    return WalletId.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, WalletId obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}

/// Hive-backed activation configuration repository keyed by [WalletId].
class HiveActivationConfigRepository implements ActivationConfigRepository {
  HiveActivationConfigRepository({
    HiveInterface? hive,
    String boxName = 'activation_configs',
  }) : _hive = hive ?? Hive,
       _boxName = boxName;

  final HiveInterface _hive;
  final String _boxName;
  Box<Map<String, String>>? _box;
  Future<Box<Map<String, String>>>? _boxOpening;

  Future<Box<Map<String, String>>> _openBox() {
    if (_box != null) return Future.value(_box!);
    if (_boxOpening != null) return _boxOpening!;
    _boxOpening = () async {
      if (!_hive.isAdapterRegistered(_walletIdAdapterTypeId)) {
        _hive.registerAdapter(WalletIdAdapter());
      }
      final box = await _hive.openBox<Map<String, String>>(_boxName);
      _box = box;
      return box;
    }();
    return _boxOpening!;
  }

  @override
  Future<TConfig?> getConfig<TConfig>(WalletId walletId, AssetId id) async {
    final box = await _openBox();
    final stored = box.get(walletId);
    if (stored == null) return null;
    final serialized = stored[id.id];
    if (serialized == null) return null;
    final json = jsonDecode(serialized) as Map<String, dynamic>;
    return ActivationConfigMapper.decode<TConfig>(json);
  }

  @override
  Future<void> saveConfig<TConfig>(
    WalletId walletId,
    AssetId id,
    TConfig config,
  ) async {
    final box = await _openBox();
    final existing = Map<String, String>.from(box.get(walletId) ?? {});
    final json = ActivationConfigMapper.encode(config as Object);
    existing[id.id] = jsonEncode(json);
    await box.put(walletId, existing);
  }
}
