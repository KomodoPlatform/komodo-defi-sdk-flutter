import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:komodo_persistence_layer/komodo_persistence_layer.dart';

import 'address_format.dart';
import 'links.dart';
import 'protocol.dart';

part 'adapters/coin_adapter.dart';

class Coin extends Equatable implements ObjectWithPrimaryKey<String> {
  const Coin({
    required this.coin,
    this.name,
    this.fname,
    this.rpcport,
    this.mm2,
    this.chainId,
    this.requiredConfirmations,
    this.avgBlocktime,
    this.decimals,
    this.protocol,
    this.derivationPath,
    this.trezorCoin,
    this.links,
    this.isPoS,
    this.pubtype,
    this.p2shtype,
    this.wiftype,
    this.txfee,
    this.dust,
    this.matureConfirmations,
    this.segwit,
    this.signMessagePrefix,
    this.asset,
    this.txversion,
    this.overwintered,
    this.requiresNotarization,
    this.walletOnly,
    this.bech32Hrp,
    this.isTestnet,
    this.forkId,
    this.signatureVersion,
    this.confpath,
    this.addressFormat,
    this.aliasTicker,
    this.estimateFeeMode,
    this.orderbookTicker,
    this.taddr,
    this.forceMinRelayFee,
    this.p2p,
    this.magic,
    this.nSPV,
    this.isPoSV,
    this.versionGroupId,
    this.consensusBranchId,
    this.estimateFeeBlocks,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      coin: json['coin'] as String,
      name: json['name'] as String?,
      fname: json['fname'] as String?,
      rpcport: json['rpcport'] as num?,
      mm2: json['mm2'] as num?,
      chainId: json['chain_id'] as num?,
      requiredConfirmations: json['required_confirmations'] as num?,
      avgBlocktime: json['avg_blocktime'] as num?,
      decimals: json['decimals'] as num?,
      protocol: json['protocol'] != null
          ? Protocol.fromJson(json['protocol'] as Map<String, dynamic>)
          : null,
      derivationPath: json['derivation_path'] as String?,
      trezorCoin: json['trezor_coin'] as String?,
      links: json['links'] != null
          ? Links.fromJson(json['links'] as Map<String, dynamic>)
          : null,
      isPoS: json['isPoS'] as num?,
      pubtype: json['pubtype'] as num?,
      p2shtype: json['p2shtype'] as num?,
      wiftype: json['wiftype'] as num?,
      txfee: json['txfee'] as num?,
      dust: json['dust'] as num?,
      matureConfirmations: json['mature_confirmations'] as num?,
      segwit: json['segwit'] as bool?,
      signMessagePrefix: json['sign_message_prefix'] as String?,
      asset: json['asset'] as String?,
      txversion: json['txversion'] as num?,
      overwintered: json['overwintered'] as num?,
      requiresNotarization: json['requires_notarization'] as bool?,
      walletOnly: json['wallet_only'] as bool?,
      bech32Hrp: json['bech32_hrp'] as String?,
      isTestnet: json['is_testnet'] as bool?,
      forkId: json['fork_id'] as String?,
      signatureVersion: json['signature_version'] as String?,
      confpath: json['confpath'] as String?,
      addressFormat: json['address_format'] != null
          ? AddressFormat.fromJson(
              json['address_format'] as Map<String, dynamic>,
            )
          : null,
      aliasTicker: json['alias_ticker'] as String?,
      estimateFeeMode: json['estimate_fee_mode'] as String?,
      orderbookTicker: json['orderbook_ticker'] as String?,
      taddr: json['taddr'] as num?,
      forceMinRelayFee: json['force_min_relay_fee'] as bool?,
      p2p: json['p2p'] as num?,
      magic: json['magic'] as String?,
      nSPV: json['nSPV'] as String?,
      isPoSV: json['isPoSV'] as num?,
      versionGroupId: json['version_group_id'] as String?,
      consensusBranchId: json['consensus_branch_id'] as String?,
      estimateFeeBlocks: json['estimate_fee_blocks'] as num?,
    );
  }

  final String coin;
  final String? name;
  final String? fname;
  final num? rpcport;
  final num? mm2;
  final num? chainId;
  final num? requiredConfirmations;
  final num? avgBlocktime;
  final num? decimals;
  final Protocol? protocol;
  final String? derivationPath;
  final String? trezorCoin;
  final Links? links;
  final num? isPoS;
  final num? pubtype;
  final num? p2shtype;
  final num? wiftype;
  final num? txfee;
  final num? dust;
  final num? matureConfirmations;
  final bool? segwit;
  final String? signMessagePrefix;
  final String? asset;
  final num? txversion;
  final num? overwintered;
  final bool? requiresNotarization;
  final bool? walletOnly;
  final String? bech32Hrp;
  final bool? isTestnet;
  final String? forkId;
  final String? signatureVersion;
  final String? confpath;
  final AddressFormat? addressFormat;
  final String? aliasTicker;
  final String? estimateFeeMode;
  final String? orderbookTicker;
  final num? taddr;
  final bool? forceMinRelayFee;
  final num? p2p;
  final String? magic;
  final String? nSPV;
  final num? isPoSV;
  final String? versionGroupId;
  final String? consensusBranchId;
  final num? estimateFeeBlocks;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coin': coin,
      'name': name,
      'fname': fname,
      'rpcport': rpcport,
      'mm2': mm2,
      'chain_id': chainId,
      'required_confirmations': requiredConfirmations,
      'avg_blocktime': avgBlocktime,
      'decimals': decimals,
      'protocol': protocol?.toJson(),
      'derivation_path': derivationPath,
      'trezor_coin': trezorCoin,
      'links': links?.toJson(),
      'isPoS': isPoS,
      'pubtype': pubtype,
      'p2shtype': p2shtype,
      'wiftype': wiftype,
      'txfee': txfee,
      'dust': dust,
      'mature_confirmations': matureConfirmations,
      'segwit': segwit,
      'sign_message_prefix': signMessagePrefix,
      'asset': asset,
      'txversion': txversion,
      'overwintered': overwintered,
      'requires_notarization': requiresNotarization,
      'wallet_only': walletOnly,
      'bech32_hrp': bech32Hrp,
      'is_testnet': isTestnet,
      'fork_id': forkId,
      'signature_version': signatureVersion,
      'confpath': confpath,
      'address_format': addressFormat?.toJson(),
      'alias_ticker': aliasTicker,
      'estimate_fee_mode': estimateFeeMode,
      'orderbook_ticker': orderbookTicker,
      'taddr': taddr,
      'force_min_relay_fee': forceMinRelayFee,
      'p2p': p2p,
      'magic': magic,
      'nSPV': nSPV,
      'isPoSV': isPoSV,
      'version_group_id': versionGroupId,
      'consensus_branch_id': consensusBranchId,
      'estimate_fee_blocks': estimateFeeBlocks,
    };
  }

  @override
  List<Object?> get props => <Object?>[coin];

  @override
  String get primaryKey => coin;
}
