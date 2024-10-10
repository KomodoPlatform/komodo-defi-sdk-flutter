//!
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/src/assets/chain.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';

class UtxoChain extends Chain {
  UtxoChain({
    required this.mode,
    required super.id,
    required super.decimals,
    required super.name,
    required super.symbol,
    this.requiredConfirmations,
    this.requiresNotarization = false,
    this.avgBlocktime,
    this.txVersion,
    this.txFee,
    this.dustAmount,
    this.pubtype,
    this.p2shtype,
    this.wiftype,
    this.overwintered,
    this.isTestnet = false,
    this.isClaimable = false,
    this.minimalClaimAmount,
    this.signMessagePrefix,
    this.derivationPath,
    this.trezorCoin,
  }) : super(isHdWalletSupported: true);

  final ActivationMode mode;
  final int? requiredConfirmations;
  final bool requiresNotarization;
  final int? avgBlocktime;
  final int? txVersion;
  final int? txFee;
  final int? dustAmount;
  final int? pubtype;
  final int? p2shtype;
  final int? wiftype;
  final int? overwintered;
  final bool isTestnet;
  final bool isClaimable;
  final String? minimalClaimAmount;
  final String? signMessagePrefix;
  final String? derivationPath;
  final String? trezorCoin;

  @override
  TaskEnableUtxoInit createEnableRequest(
    ActivationParams params,
  ) {
    if (params is! UtxoActivationParams) {
      throw ArgumentError('UtxoChain requires UtxoActivationParams');
    }
    return TaskEnableUtxoInit(
      ticker: id,
      params: params,
    );
  }

  @override
  UtxoChain fromJsonConfig(Map<String, dynamic> json) {
    return UtxoChain(
      id: json.value<String>('coin'),
      decimals: json.value<int>('decimals'),
      name: json.value<String>('name'),
      symbol: json.value<String>('coin'),
      mode: ActivationMode(
        rpc: 'Electrum',
        rpcData: ActivationRpcData(
          electrum: json
              .value<List<dynamic>>('electrum')
              .map((e) => ActivationServers.fromJsonConfig(e as JsonMap))
              .toList(),
        ),
      ),
      requiredConfirmations: json.valueOrNull<int>('required_confirmations'),
      requiresNotarization:
          json.valueOrNull<bool>('requires_notarization') ?? false,
      avgBlocktime: json.valueOrNull<int>('avg_blocktime'),
      txVersion: json.valueOrNull<int>('txversion'),
      txFee: json.valueOrNull<int>('txfee'),
      pubtype: json.valueOrNull<int>('pubtype'),
      p2shtype: json.valueOrNull<int>('p2shtype'),
      wiftype: json.valueOrNull<int>('wiftype'),
      overwintered: json.valueOrNull<int>('overwintered'),
      isTestnet: json.valueOrNull<bool?>('is_testnet') ?? false,
      isClaimable: json.valueOrNull<bool?>('is_claimable') ?? false,
      minimalClaimAmount: json.valueOrNull<String>('minimal_claim_amount'),
      signMessagePrefix: json.valueOrNull<String>('sign_message_prefix'),
      derivationPath: json.valueOrNull<String>('derivation_path'),
      trezorCoin: json.valueOrNull<String>('trezor_coin'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'decimals': decimals,
        'name': name,
        'symbol': symbol,
        'mode': mode.toJsonRequest(),
        'required_confirmations': requiredConfirmations,
        'requires_notarization': requiresNotarization,
        'avg_blocktime': avgBlocktime,
        'txversion': txVersion,
        'txfee': txFee,
        'dust_amount': dustAmount,
        'pubtype': pubtype,
        'p2shtype': p2shtype,
        'wiftype': wiftype,
        'overwintered': overwintered,
        'is_testnet': isTestnet,
        'is_claimable': isClaimable,
        'minimal_claim_amount': minimalClaimAmount,
        'sign_message_prefix': signMessagePrefix,
        'derivation_path': derivationPath,
        'trezor_coin': trezorCoin,
        'servers':
            mode.rpcData!.electrum!.map((e) => e.toJsonRequest()).toList(),
      };
}
