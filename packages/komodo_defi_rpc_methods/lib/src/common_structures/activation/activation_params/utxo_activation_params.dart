import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';
import 'package:komodo_defi_rpc_methods/src/models/models.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class UtxoActivationParams extends ActivationParams
    implements KdfRequestParams {
  UtxoActivationParams({
    required super.mode,
    this.txHistory,
    super.requiredConfirmations,
    super.requiresNotarization,
    super.privKeyPolicy,
    super.minAddressesNumber,
    super.scanPolicy,
    super.gapLimit,
    this.txVersion,
    this.txFee,
    this.dustAmount,
    this.pubtype,
    this.p2shtype,
    this.wiftype,
    this.overwintered,
  });

  factory UtxoActivationParams.fromJsonConfig(Map<String, dynamic> config) {
    return UtxoActivationParams(
      mode: ActivationMode(
        rpc: 'Electrum',
        rpcData: ActivationRpcData(
          electrum: (config['electrum'] as List<dynamic>?)
              ?.cast<JsonMap>()
              .map(ActivationServers.fromJsonConfig)
              .toList(),
        ),
      ),
      requiredConfirmations: config.valueOrNull<int>('required_confirmations'),
      requiresNotarization:
          config.valueOrNull<bool>('requires_notarization') ?? false,
      txVersion: config.valueOrNull<int?>('txversion'),
      txFee: config.valueOrNull<int?>('txfee'),
      pubtype: config.valueOrNull<int?>('pubtype'),
      p2shtype: config.valueOrNull<int?>('p2shtype'),
      wiftype: config.valueOrNull<int?>('wiftype'),
      overwintered: config.valueOrNull<int?>('overwintered'),
    );
  }

  final bool? txHistory;
  final int? txVersion;
  final int? txFee;
  final int? dustAmount;
  final int? pubtype;
  final int? p2shtype;
  final int? wiftype;
  final int? overwintered;

  @override
  Map<String, dynamic> toJson() => {
        'mode': mode!.toJsonRequest(),
        if (txHistory != null) 'tx_history': txHistory,
        if (requiredConfirmations != null)
          'required_confirmations': requiredConfirmations,
        'requires_notarization': requiresNotarization,
        'priv_key_policy': privKeyPolicy.id,
        if (minAddressesNumber != null)
          'min_addresses_number': minAddressesNumber,
        if (scanPolicy != null) 'scan_policy': scanPolicy,
        if (gapLimit != null) 'gap_limit': gapLimit,
        if (txVersion != null) 'txversion': txVersion,
        if (txFee != null) 'txfee': txFee,
        if (dustAmount != null) 'dust_amount': dustAmount,
        if (pubtype != null) 'pubtype': pubtype,
        if (p2shtype != null) 'p2shtype': p2shtype,
        if (wiftype != null) 'wiftype': wiftype,
        if (overwintered != null) 'overwintered': overwintered,
        // 'servers':
        //     mode!.rpcData!.electrum!.map((e) => e.toJsonRequest()).toList(),
      };
}
