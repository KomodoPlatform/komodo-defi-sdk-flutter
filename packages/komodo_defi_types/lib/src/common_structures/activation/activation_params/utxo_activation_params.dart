import 'package:komodo_defi_types/src/common_structures/activation/activation_params/activation_params.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class UtxoActivationParams extends ActivationParams {
  /// Primary constructor is private to enforce using named constructors
  const UtxoActivationParams._({
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

  /// Constructor for HD wallet or non-HD wallet activation. If in non-HD mode,
  /// the HD parameters will be ignored.
  ///
  /// Prefer using [UtxoActivationParams.nonHd] if you know the wallet is not
  /// running in HD mode.
  factory UtxoActivationParams.hdWallet({
    required ActivationMode mode,
    required bool txHistory,
    required int minAddressesNumber,
    required ScanPolicy scanPolicy,
    required int gapLimit,
    int? requiredConfirmations,
    bool requiresNotarization = false,
    PrivateKeyPolicy privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
    int? txVersion,
    int? txFee,
    int? dustAmount,
    int? pubtype,
    int? p2shtype,
    int? wiftype,
    int? overwintered,
  }) {
    return UtxoActivationParams._(
      mode: mode,
      txHistory: txHistory,
      minAddressesNumber: minAddressesNumber,
      scanPolicy: scanPolicy,
      gapLimit: gapLimit,
      requiredConfirmations: requiredConfirmations,
      requiresNotarization: requiresNotarization,
      privKeyPolicy: privKeyPolicy,
      txVersion: txVersion,
      txFee: txFee,
      dustAmount: dustAmount,
      pubtype: pubtype,
      p2shtype: p2shtype,
      wiftype: wiftype,
      overwintered: overwintered,
    );
  }

  /// Constructor for standard (non-HD) wallet activation
  factory UtxoActivationParams.nonHd({
    required ActivationMode mode,
    required bool txHistory,
    int? requiredConfirmations,
    bool requiresNotarization = false,
    PrivateKeyPolicy privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
    int? txVersion,
    int? txFee,
    int? dustAmount,
    int? pubtype,
    int? p2shtype,
    int? wiftype,
    int? overwintered,
  }) {
    return UtxoActivationParams._(
      mode: mode,
      txHistory: txHistory,
      requiredConfirmations: requiredConfirmations,
      requiresNotarization: requiresNotarization,
      privKeyPolicy: privKeyPolicy,
      txVersion: txVersion,
      txFee: txFee,
      dustAmount: dustAmount,
      pubtype: pubtype,
      p2shtype: p2shtype,
      wiftype: wiftype,
      overwintered: overwintered,
    );
  }

  factory UtxoActivationParams.fromJson(JsonMap json) {
    final base = ActivationParams.fromConfigJson(json);

    return UtxoActivationParams._(
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
  Map<String, dynamic> toRpcParams() {
    return super.toRpcParams().deepMerge({
      if (txHistory != null) 'tx_history': txHistory,
      if (txVersion != null) 'txversion': txVersion,
      if (txFee != null) 'txfee': txFee,
      if (dustAmount != null) 'dust_amount': dustAmount,
      if (pubtype != null) 'pubtype': pubtype,
      if (p2shtype != null) 'p2shtype': p2shtype,
      if (wiftype != null) 'wiftype': wiftype,
      if (overwintered != null) 'overwintered': overwintered,
    });
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
    return UtxoActivationParams._(
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

  /// Method to copy the activation parameters, but with only the HD wallet
  /// parameters.
  ///
  /// HD wallet parameters are ignored if the wallet is not running in HD mode.
  ///
  /// See [UtxoActivationParams.hdWallet] for more information.
  UtxoActivationParams copyWithHd({
    required int minAddressesNumber,
    required ScanPolicy scanPolicy,
    required int gapLimit,
  }) {
    return copyWith(
      minAddressesNumber: minAddressesNumber,
      scanPolicy: scanPolicy,
      gapLimit: gapLimit,
    );
  }
}
