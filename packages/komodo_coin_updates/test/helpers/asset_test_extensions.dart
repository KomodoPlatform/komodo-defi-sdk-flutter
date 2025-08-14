import 'package:komodo_defi_types/komodo_defi_types.dart';

extension AssetTestBuilders on String {
  /// Builds a minimal UTXO [Asset] suitable for tests.
  ///
  /// - [name]: optional full name (defaults to ticker)
  /// - [chainId]: optional chain id (defaults to 0)
  /// - [decimals]: optional decimals included in the config
  Asset toUtxoTestAsset({String? name, int chainId = 0, int? decimals}) {
    final json = <String, dynamic>{
      'coin': this,
      if (decimals != null) 'decimals': decimals,
      'type': 'UTXO',
      'protocol': {'type': 'UTXO'},
      'fname': name ?? this,
      'chain_id': chainId,
    };
    final assetId = AssetId.parse(json, knownIds: const {});
    return Asset.fromJsonWithId(json, assetId: assetId);
  }

  /// Convenience builder for an [AssetId] to look up assets in storage.
  AssetId toTestAssetId({
    String? name,
    CoinSubClass subClass = CoinSubClass.utxo,
    int chainId = 0,
  }) {
    return AssetId(
      id: this,
      name: name ?? this,
      symbol: AssetSymbol(assetConfigId: this),
      chainId: AssetChainId(chainId: chainId),
      derivationPath: null,
      subClass: subClass,
    );
  }
}

/// Common ready-to-use assets
Asset buildKmdTestAsset() => 'KMD'.toUtxoTestAsset(name: 'Komodo', decimals: 8);
Asset buildBtcTestAsset() =>
    'BTC'.toUtxoTestAsset(name: 'Bitcoin', decimals: 8);
