import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/_activation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Legacy UTXO activation strategy that uses the electrum method
/// This matches the format shown in the Postman collection
class LegacyUtxoActivationStrategy extends ActivationStrategy {
  LegacyUtxoActivationStrategy(this._client, this._privKeyPolicy);

  final ApiClient _client;
  final PrivateKeyPolicy _privKeyPolicy;

  @override
  bool supportsAsset(Asset asset) {
    return asset.protocol is UtxoProtocol;
  }

  @override
  Stream<ActivationProgress> activate(
    Asset asset, [
    List<Asset>? children,
  ]) async* {
    final protocol = asset.protocol as UtxoProtocol;

    yield ActivationProgress(
      status: 'Starting ${asset.id.name} activation (legacy mode)...',
      progressDetails: ActivationProgressDetails(
        currentStep: ActivationStep.init,
        stepCount: 5,
        additionalInfo: {
          'protocolType': protocol.subClass.formatted,
          'pubtype': protocol.pubtype,
          'activationMode': 'legacy_electrum',
        },
      ),
    );

    try {
      yield const ActivationProgress(
        status: 'Validating protocol configuration...',
        progressPercentage: 20,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.validation,
          stepCount: 5,
        ),
      );

      // Convert protocol servers to legacy format
      final legacyServers = protocol.requiredServers
          .map((server) => LegacyElectrumServer(
                url: server.url,
                protocol: server.protocol,
                disableCertVerification: server.disableCertVerification,
              ))
          .toList();

      yield ActivationProgress(
        status: 'Establishing network connections...',
        progressPercentage: 40,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.connection,
          stepCount: 5,
          additionalInfo: {
            'electrumServers': legacyServers.map((s) => s.toJson()).toList(),
            'protocolType': protocol.subClass.formatted,
          },
        ),
      );

      // Execute legacy electrum activation
      final response = await _client.rpc.legacyActivation.enableElectrum(
        coin: asset.id.id,
        servers: legacyServers,
        requiredConfirmations: protocol.requiredConfirmations,
        requiresNotarization: protocol.requiresNotarization,
        privKeyPolicy: _privKeyPolicy == PrivateKeyPolicy.trezor
            ? 'Trezor'
            : 'IguanaPrivKey',
      );

      yield ActivationProgress(
        status: 'Activation completed successfully',
        progressPercentage: 100,
        progressDetails: ActivationProgressDetails(
          currentStep: ActivationStep.complete,
          stepCount: 5,
          additionalInfo: {
            'address': response.address,
            'balance': response.balance,
            'coin': response.coin,
            'requiredConfirmations': response.requiredConfirmations,
            'requiresNotarization': response.requiresNotarization,
          },
        ),
      );

      yield ActivationProgress.success(
        assetName: asset.id.name,
        additionalInfo: {
          'address': response.address,
          'balance': response.balance,
          'coin': response.coin,
        },
      );
    } catch (e, stackTrace) {
      yield ActivationProgress.failure(
        assetName: asset.id.name,
        errorMessage: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }
}