import 'dart:async';

import 'package:komodo_defi_sdk/src/activation/config/activation_config_models.dart';
import 'package:komodo_defi_sdk/src/activation/config/activation_config_repository.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

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
      final result = await completer.future.timeout(timeout, onTimeout: () => null);
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

