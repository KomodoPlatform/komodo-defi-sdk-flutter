import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Namespace for legacy activation methods
class LegacyActivationMethodsNamespace extends BaseRpcMethodNamespace {
  LegacyActivationMethodsNamespace(super.client);

  /// Legacy electrum method for coin activation
  /// This matches the format shown in the Postman collection
  Future<LegacyEnableElectrumResponse> enableElectrum({
    required String coin,
    required List<LegacyElectrumServer> servers,
    int? minConnected,
    int? maxConnected,
    int? mm2,
    bool? txHistory,
    int? requiredConfirmations,
    bool? requiresNotarization,
    LegacyAddressFormat? addressFormat,
    LegacyUtxoMergeParams? utxoMergeParams,
    bool? checkUtxoMaturity,
    String? privKeyPolicy,
    int? gapLimit,
    String? scanPolicy,
    String? rpcPass,
  }) {
    return execute(
      LegacyEnableElectrumRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        servers: servers,
        minConnected: minConnected,
        maxConnected: maxConnected,
        mm2: mm2,
        txHistory: txHistory,
        requiredConfirmations: requiredConfirmations,
        requiresNotarization: requiresNotarization,
        addressFormat: addressFormat,
        utxoMergeParams: utxoMergeParams,
        checkUtxoMaturity: checkUtxoMaturity,
        privKeyPolicy: privKeyPolicy,
        gapLimit: gapLimit,
        scanPolicy: scanPolicy,
      ),
    );
  }

  /// Legacy get enabled coins method
  Future<LegacyGetEnabledCoinsResponse> getEnabledCoins([String? rpcPass]) {
    return execute(LegacyGetEnabledCoinsRequest(rpcPass: rpcPass));
  }
}