import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Legacy electrum method request for coin activation
/// This matches the format shown in the Postman collection
class LegacyEnableElectrumRequest
    extends BaseRequest<LegacyEnableElectrumResponse, GeneralErrorResponse> {
  LegacyEnableElectrumRequest({
    required super.rpcPass,
    required this.coin,
    required this.servers,
    this.minConnected,
    this.maxConnected,
    this.mm2,
    this.txHistory,
    this.requiredConfirmations,
    this.requiresNotarization,
    this.addressFormat,
    this.utxoMergeParams,
    this.checkUtxoMaturity,
    this.privKeyPolicy,
    this.gapLimit,
    this.scanPolicy,
  }) : super(method: 'electrum', mmrpc: null);

  final String coin;
  final List<LegacyElectrumServer> servers;
  final int? minConnected;
  final int? maxConnected;
  final int? mm2;
  final bool? txHistory;
  final int? requiredConfirmations;
  final bool? requiresNotarization;
  final LegacyAddressFormat? addressFormat;
  final LegacyUtxoMergeParams? utxoMergeParams;
  final bool? checkUtxoMaturity;
  final String? privKeyPolicy;
  final int? gapLimit;
  final String? scanPolicy;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'coin': coin,
    'servers': servers.map((s) => s.toJson()).toList(),
    if (minConnected != null) 'min_connected': minConnected,
    if (maxConnected != null) 'max_connected': maxConnected,
    if (mm2 != null) 'mm2': mm2,
    if (txHistory != null) 'tx_history': txHistory,
    if (requiredConfirmations != null) 'required_confirmations': requiredConfirmations,
    if (requiresNotarization != null) 'requires_notarization': requiresNotarization,
    if (addressFormat != null) 'address_format': addressFormat!.toJson(),
    if (utxoMergeParams != null) 'utxo_merge_params': utxoMergeParams!.toJson(),
    if (checkUtxoMaturity != null) 'check_utxo_maturity': checkUtxoMaturity,
    if (privKeyPolicy != null) 'priv_key_policy': privKeyPolicy,
    if (gapLimit != null) 'gap_limit': gapLimit,
    if (scanPolicy != null) 'scan_policy': scanPolicy,
  };

  @override
  LegacyEnableElectrumResponse parse(Map<String, dynamic> json) {
    return LegacyEnableElectrumResponse.fromJson(json);
  }
}

/// Legacy electrum server configuration
class LegacyElectrumServer {
  LegacyElectrumServer({
    required this.url,
    this.protocol = 'TCP',
    this.disableCertVerification = false,
  });

  factory LegacyElectrumServer.fromJson(JsonMap json) {
    return LegacyElectrumServer(
      url: json.value<String>('url'),
      protocol: json.valueOrNull<String>('protocol') ?? 'TCP',
      disableCertVerification: json.valueOrNull<bool>('disable_cert_verification') ?? false,
    );
  }

  final String url;
  final String protocol;
  final bool disableCertVerification;

  Map<String, dynamic> toJson() => {
    'url': url,
    'protocol': protocol,
    'disable_cert_verification': disableCertVerification,
  };
}

/// Legacy address format configuration
class LegacyAddressFormat {
  LegacyAddressFormat({
    required this.format,
    this.network,
  });

  factory LegacyAddressFormat.fromJson(JsonMap json) {
    return LegacyAddressFormat(
      format: json.value<String>('format'),
      network: json.valueOrNull<String>('network'),
    );
  }

  final String format;
  final String? network;

  Map<String, dynamic> toJson() => {
    'format': format,
    if (network != null) 'network': network,
  };
}

/// Legacy UTXO merge parameters
class LegacyUtxoMergeParams {
  LegacyUtxoMergeParams({
    this.mergeAt,
    this.checkEvery,
    this.maxMergeAtOnce,
  });

  factory LegacyUtxoMergeParams.fromJson(JsonMap json) {
    return LegacyUtxoMergeParams(
      mergeAt: json.valueOrNull<int>('merge_at'),
      checkEvery: json.valueOrNull<int>('check_every'),
      maxMergeAtOnce: json.valueOrNull<int>('max_merge_at_once'),
    );
  }

  final int? mergeAt;
  final int? checkEvery;
  final int? maxMergeAtOnce;

  Map<String, dynamic> toJson() => {
    if (mergeAt != null) 'merge_at': mergeAt,
    if (checkEvery != null) 'check_every': checkEvery,
    if (maxMergeAtOnce != null) 'max_merge_at_once': maxMergeAtOnce,
  };
}

/// Legacy electrum method response
class LegacyEnableElectrumResponse extends BaseResponse {
  LegacyEnableElectrumResponse({
    required super.mmrpc,
    required this.result,
    required this.address,
    required this.balance,
    required this.unspendableBalance,
    required this.coin,
    required this.requiredConfirmations,
    required this.requiresNotarization,
    required this.matureConfirmations,
  });

  factory LegacyEnableElectrumResponse.fromJson(Map<String, dynamic> json) {
    return LegacyEnableElectrumResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result: json.value<String>('result'),
      address: json.value<String>('address'),
      balance: json.value<String>('balance'),
      unspendableBalance: json.value<String>('unspendable_balance'),
      coin: json.value<String>('coin'),
      requiredConfirmations: json.value<int>('required_confirmations'),
      requiresNotarization: json.value<bool>('requires_notarization'),
      matureConfirmations: json.value<int>('mature_confirmations'),
    );
  }

  final String result;
  final String address;
  final String balance;
  final String unspendableBalance;
  final String coin;
  final int requiredConfirmations;
  final bool requiresNotarization;
  final int matureConfirmations;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': result,
    'address': address,
    'balance': balance,
    'unspendable_balance': unspendableBalance,
    'coin': coin,
    'required_confirmations': requiredConfirmations,
    'requires_notarization': requiresNotarization,
    'mature_confirmations': matureConfirmations,
  };
}