import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Test helpers for building minimal-valid Asset JSON/configs.
class AssetTestHelpers {
  /// Minimal JSON required by AssetId.parse and UtxoProtocol.fromJson.
  /// Fields:
  /// - coin (String)
  /// - fname (String)
  /// - type (e.g. 'UTXO')
  /// - chain_id (int)
  /// - is_testnet (bool)
  static Map<String, dynamic> utxoJson({
    String coin = 'KMD',
    String fname = 'Komodo',
    int chainId = 777,
    bool isTestnet = false,
    bool? walletOnly,
    String? signMessagePrefix,
  }) {
    return <String, dynamic>{
      'coin': coin,
      'fname': fname,
      'type': 'UTXO',
      'chain_id': chainId,
      'is_testnet': isTestnet,
      if (walletOnly != null) 'wallet_only': walletOnly,
      if (signMessagePrefix != null) 'sign_message_prefix': signMessagePrefix,
    };
  }

  /// Convenience builder for an Asset using the minimal UTXO config.
  static Asset utxoAsset({
    String coin = 'KMD',
    String fname = 'Komodo',
    int chainId = 777,
    bool isTestnet = false,
    bool? walletOnly,
    String? signMessagePrefix,
  }) {
    return Asset.fromJson(
      utxoJson(
        coin: coin,
        fname: fname,
        chainId: chainId,
        isTestnet: isTestnet,
        walletOnly: walletOnly,
        signMessagePrefix: signMessagePrefix,
      ),
    );
  }
}
