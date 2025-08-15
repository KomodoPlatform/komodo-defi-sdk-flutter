// Abstract factory for creating data-layer collaborators used by KomodoCoins.
import 'package:komodo_coin_updates/src/coins_config/_coins_config_index.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/_runtime_update_config_index.dart'
    show RuntimeUpdateConfig;

/// Abstract factory for creating data-layer collaborators used by KomodoCoins.
abstract class CoinConfigDataFactory {
  /// Creates a repository wired to the given [config] and [transformer].
  CoinConfigRepository createRepository(
    RuntimeUpdateConfig config,
    CoinConfigTransformer transformer,
  );

  /// Creates a local asset-backed provider using the given [config].
  CoinConfigProvider createLocalProvider(RuntimeUpdateConfig config);
}

/// Default production implementation.
class DefaultCoinConfigDataFactory implements CoinConfigDataFactory {
  /// Creates a default coin config data factory.
  const DefaultCoinConfigDataFactory();

  @override
  CoinConfigRepository createRepository(
    RuntimeUpdateConfig config,
    CoinConfigTransformer transformer,
  ) {
    return CoinConfigRepository.withDefaults(config, transformer: transformer);
  }

  @override
  CoinConfigProvider createLocalProvider(RuntimeUpdateConfig config) {
    return LocalAssetCoinConfigProvider.fromConfig(config);
  }
}
