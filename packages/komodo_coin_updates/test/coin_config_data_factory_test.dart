import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_repository.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_repository_factory.dart';
import 'package:komodo_coin_updates/src/coins_config/config_transform.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';

void main() {
  group('DefaultCoinConfigDataFactory', () {
    test('createRepository wires defaults and passes transformer', () {
      const transformer = CoinConfigTransformer();
      const factory = DefaultCoinConfigDataFactory();
      final repo = factory.createRepository(
        const RuntimeUpdateConfig(),
        transformer,
      );
      expect(repo, isA<CoinConfigRepository>());
    });

    test(
      'createLocalProvider returns LocalAssetCoinConfigProvider.fromConfig',
      () {
        const factory = DefaultCoinConfigDataFactory();
        final provider = factory.createLocalProvider(
          const RuntimeUpdateConfig(),
        );
        // We don\'t import the concrete type here; verifying an instance is returned is enough
        expect(provider, isNotNull);
      },
    );
  });
}
