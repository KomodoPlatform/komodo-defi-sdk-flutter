import 'package:komodo_defi_sdk/src/activation/config/activation_config_models.dart';
import 'package:komodo_defi_sdk/src/activation/config/key_value_store.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class ActivationConfigRepository {
  Future<TConfig?> getConfig<TConfig>(AssetId id);
  Future<void> saveConfig<TConfig>(AssetId id, TConfig config);
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

