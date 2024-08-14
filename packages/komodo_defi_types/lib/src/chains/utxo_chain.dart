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
      requiredConfirmations: json.value<int>('required_confirmations'),
      requiresNotarization: json.value<bool?>('requires_notarization') ?? false,
      avgBlocktime: json.value<int>('avg_blocktime'),
      txVersion: json.value<int>('txversion'),
      txFee: json.value<int>('txfee'),
      pubtype: json.value<int>('pubtype'),
      p2shtype: json.value<int>('p2shtype'),
      wiftype: json.value<int>('wiftype'),
      overwintered: json.value<int>('overwintered'),
      isTestnet: json.value<bool?>('is_testnet') ?? false,
      isClaimable: json.value<bool?>('is_claimable') ?? false,
      minimalClaimAmount: json.value<String>('minimal_claim_amount'),
      signMessagePrefix: json.value<String>('sign_message_prefix'),
      derivationPath: json.value<String>('derivation_path'),
      trezorCoin: json.value<String>('trezor_coin'),
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
      };
}
