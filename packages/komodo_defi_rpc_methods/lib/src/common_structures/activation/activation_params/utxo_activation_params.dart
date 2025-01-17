import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class UtxoActivationParams extends ActivationParams {
  UtxoActivationParams({
    required super.mode,
    required this.txHistory,
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

  factory UtxoActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return UtxoActivationParams(
      mode: base.mode ??
          (throw const FormatException(
            'UTXO activation requires mode parameter',
          )),
      txHistory: json.valueOrNull<bool>('tx_history'),
      requiredConfirmations: base.requiredConfirmations,
      requiresNotarization: base.requiresNotarization,
      privKeyPolicy: base.privKeyPolicy,
      minAddressesNumber: base.minAddressesNumber,
      scanPolicy: base.scanPolicy,
      gapLimit: base.gapLimit,
      txVersion: json.valueOrNull<int>('txversion'),
      txFee: json.valueOrNull<int>('txfee'),
      dustAmount: json.valueOrNull<int>('dust_amount'),
      pubtype: json.valueOrNull<int>('pubtype'),
      p2shtype: json.valueOrNull<int>('p2shtype'),
      wiftype: json.valueOrNull<int>('wiftype'),
      overwintered: json.valueOrNull<int>('overwintered'),
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
  Map<String, dynamic> toJsonRequestParams() {
    return {
      ...super.toJsonRequestParams(),
      if (txHistory != null) 'tx_history': txHistory,
      if (txVersion != null) 'txversion': txVersion,
      if (txFee != null) 'txfee': txFee,
      if (dustAmount != null) 'dust_amount': dustAmount,
      if (pubtype != null) 'pubtype': pubtype,
      if (p2shtype != null) 'p2shtype': p2shtype,
      if (wiftype != null) 'wiftype': wiftype,
      if (overwintered != null) 'overwintered': overwintered,
    };
  }

  UtxoActivationParams copyWith({
    bool? txHistory,
    int? txVersion,
    int? txFee,
    int? dustAmount,
    int? pubtype,
    int? p2shtype,
    int? wiftype,
    int? overwintered,
    int? requiredConfirmations,
    bool? requiresNotarization,
    PrivateKeyPolicy? privKeyPolicy,
    int? minAddressesNumber,
    ScanPolicy? scanPolicy,
    int? gapLimit,
  }) {
    return UtxoActivationParams(
      mode: mode,
      txHistory: txHistory ?? this.txHistory,
      requiredConfirmations:
          requiredConfirmations ?? super.requiredConfirmations,
      requiresNotarization: requiresNotarization ?? super.requiresNotarization,
      privKeyPolicy: privKeyPolicy ?? super.privKeyPolicy,
      minAddressesNumber: minAddressesNumber ?? super.minAddressesNumber,
      scanPolicy: scanPolicy ?? super.scanPolicy,
      gapLimit: gapLimit ?? super.gapLimit,
      txVersion: txVersion ?? this.txVersion,
      txFee: txFee ?? this.txFee,
      dustAmount: dustAmount ?? this.dustAmount,
      pubtype: pubtype ?? this.pubtype,
      p2shtype: p2shtype ?? this.p2shtype,
      wiftype: wiftype ?? this.wiftype,
      overwintered: overwintered ?? this.overwintered,
    );
  }
}
