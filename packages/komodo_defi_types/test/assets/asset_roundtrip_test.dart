import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import '../utils/asset_config_builders.dart';

void main() {
  group('Asset JSON Roundtrip Tests', () {
    test('UTXO Asset roundtrip', () {
      // Use the Bitcoin config builder
      final utxoConfig =
          AssetConfigBuilders.bitcoin()..addAll({'rpcport': 8332});

      // Test fromJson -> toJson roundtrip
      final asset = Asset.fromJson(utxoConfig);
      final recreatedJson = asset.toJson();
      final recreatedAsset = Asset.fromJson(recreatedJson);

      // Verify the assets are equivalent
      expect(recreatedAsset.id.id, equals(asset.id.id));
      expect(recreatedAsset.id.name, equals(asset.id.name));
      expect(recreatedAsset.id.subClass, equals(asset.id.subClass));
      expect(recreatedAsset.protocol.subClass, equals(asset.protocol.subClass));
      expect(recreatedAsset.isWalletOnly, equals(asset.isWalletOnly));
      expect(recreatedAsset.signMessagePrefix, equals(asset.signMessagePrefix));

      // Verify protocol-specific properties are preserved
      expect(recreatedAsset.protocol, isA<UtxoProtocol>());
      final utxoProtocol = recreatedAsset.protocol as UtxoProtocol;
      final originalUtxoProtocol = asset.protocol as UtxoProtocol;
      expect(utxoProtocol.pubtype, equals(originalUtxoProtocol.pubtype));
      expect(utxoProtocol.p2shtype, equals(originalUtxoProtocol.p2shtype));
      expect(utxoProtocol.wiftype, equals(originalUtxoProtocol.wiftype));
    });

    test('ERC20 Asset roundtrip', () {
      // Use the Ethereum config builder
      final erc20Config =
          AssetConfigBuilders.ethereum()..addAll({'rpcport': 80});

      // Test fromJson -> toJson roundtrip
      final asset = Asset.fromJson(erc20Config);
      final recreatedJson = asset.toJson();
      final recreatedAsset = Asset.fromJson(recreatedJson);

      // Verify the assets are equivalent
      expect(recreatedAsset.id.id, equals(asset.id.id));
      expect(recreatedAsset.id.name, equals(asset.id.name));
      expect(recreatedAsset.id.subClass, equals(asset.id.subClass));
      expect(recreatedAsset.protocol.subClass, equals(asset.protocol.subClass));
      expect(recreatedAsset.isWalletOnly, equals(asset.isWalletOnly));

      // Verify ERC20-specific properties
      expect(recreatedAsset.protocol, isA<Erc20Protocol>());
      final erc20Protocol = recreatedAsset.protocol as Erc20Protocol;
      final originalErc20Protocol = asset.protocol as Erc20Protocol;
      expect(
        erc20Protocol.contractAddress,
        equals(originalErc20Protocol.contractAddress),
      );
    });

    test('Tendermint Asset roundtrip', () {
      // Use the Cosmos config builder
      final tendermintConfig =
          AssetConfigBuilders.cosmos()..addAll({'rpcport': 26657});

      // Test fromJson -> toJson roundtrip
      final asset = Asset.fromJson(tendermintConfig);
      final recreatedJson = asset.toJson();
      final recreatedAsset = Asset.fromJson(recreatedJson);

      // Verify the assets are equivalent
      expect(recreatedAsset.id.id, equals(asset.id.id));
      expect(recreatedAsset.id.name, equals(asset.id.name));
      expect(recreatedAsset.id.subClass, equals(asset.id.subClass));
      expect(recreatedAsset.protocol.subClass, equals(asset.protocol.subClass));

      // Verify Tendermint-specific properties
      expect(recreatedAsset.protocol, isA<TendermintProtocol>());
      final tmProtocol = recreatedAsset.protocol as TendermintProtocol;
      final originalTmProtocol = asset.protocol as TendermintProtocol;
      expect(
        tmProtocol.accountPrefix,
        equals(originalTmProtocol.accountPrefix),
      );
      expect(tmProtocol.chainId, equals(originalTmProtocol.chainId));
    });

    test('Asset with parent coin roundtrip', () {
      // Use the USDT ERC20 token config builder
      final tokenConfig =
          AssetConfigBuilders.usdtErc20()..addAll({'rpcport': 80});

      // Create parent ETH asset first for the known IDs
      final ethConfig = AssetConfigBuilders.ethereum();
      final ethAsset = Asset.fromJson(ethConfig);

      // Test fromJson -> toJson roundtrip with known parent
      final asset = Asset.fromJsonWithId(
        tokenConfig,
        assetId: AssetId.parse(tokenConfig, knownIds: {ethAsset.id}),
      );
      final recreatedJson = asset.toJson();
      final recreatedAsset = Asset.fromJsonWithId(
        recreatedJson,
        assetId: AssetId.parse(recreatedJson, knownIds: {ethAsset.id}),
      );

      // Verify the assets are equivalent
      expect(recreatedAsset.id.id, equals(asset.id.id));
      expect(recreatedAsset.id.name, equals(asset.id.name));
      expect(recreatedAsset.id.subClass, equals(asset.id.subClass));
      expect(recreatedAsset.protocol.subClass, equals(asset.protocol.subClass));
      expect(
        recreatedAsset.protocol.contractAddress,
        equals(asset.protocol.contractAddress),
      );

      // Verify parent coin relationship is preserved
      expect(recreatedJson['parent_coin'], equals('ETH'));
    });

    test('AssetId roundtrip preserves all fields', () {
      final assetIdConfig =
          UtxoAssetConfigBuilder(
              coin: 'BTC',
              name: 'Bitcoin',
              fname: 'Bitcoin',
              coinpaprikaId: 'btc-bitcoin',
              coingeckoId: 'bitcoin',
              livecoinwatchId: 'BTC',
            ).withDerivationPath("m/44'/0'").build()
            ..addAll({'chain_id': 0, 'decimals': 8});

      final assetId = AssetId.parse(assetIdConfig, knownIds: const {});
      final json = assetId.toJson();
      final recreatedAssetId = AssetId.parse(json, knownIds: const {});

      expect(recreatedAssetId.id, equals(assetId.id));
      expect(recreatedAssetId.name, equals(assetId.name));
      expect(recreatedAssetId.subClass, equals(assetId.subClass));
      expect(
        recreatedAssetId.symbol.assetConfigId,
        equals(assetId.symbol.assetConfigId),
      );
      expect(
        recreatedAssetId.symbol.coinGeckoId,
        equals(assetId.symbol.coinGeckoId),
      );
      expect(
        recreatedAssetId.symbol.coinPaprikaId,
        equals(assetId.symbol.coinPaprikaId),
      );
      expect(recreatedAssetId.derivationPath, equals(assetId.derivationPath));
    });

    test('Protocol variant creation works after roundtrip', () {
      // Create a UTXO asset that supports SmartChain
      final utxoConfig =
          AssetConfigBuilders.komodoWithSmartChain()
            ..addAll({'chain_id': 0, 'is_testnet': false});

      final asset = Asset.fromJson(utxoConfig);
      final recreatedJson = asset.toJson();
      final recreatedAsset = Asset.fromJson(recreatedJson);

      // Verify protocol variants work
      final variants = recreatedAsset.protocolVariants;
      expect(variants.length, greaterThan(0));

      final smartChainVariant = recreatedAsset.createVariant(
        CoinSubClass.smartChain,
      );
      expect(smartChainVariant, isNotNull);
      expect(
        smartChainVariant!.protocol.subClass,
        equals(CoinSubClass.smartChain),
      );
    });
  });
}
