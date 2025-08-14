// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coin _$CoinFromJson(Map<String, dynamic> json) => _Coin(
  coin: json['coin'] as String,
  name: json['name'] as String?,
  fname: json['fname'] as String?,
  rpcport: json['rpcport'] as num?,
  mm2: json['mm2'] as num?,
  chainId: json['chain_id'] as num?,
  requiredConfirmations: json['required_confirmations'] as num?,
  avgBlocktime: json['avg_blocktime'] as num?,
  decimals: json['decimals'] as num?,
  protocol:
      json['protocol'] == null
          ? null
          : Protocol.fromJson(json['protocol'] as Map<String, dynamic>),
  derivationPath: json['derivation_path'] as String?,
  trezorCoin: json['trezor_coin'] as String?,
  links:
      json['links'] == null
          ? null
          : Links.fromJson(json['links'] as Map<String, dynamic>),
  isPoS: json['is_po_s'] as num?,
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
  addressFormat:
      json['address_format'] == null
          ? null
          : AddressFormat.fromJson(
            json['address_format'] as Map<String, dynamic>,
          ),
  aliasTicker: json['alias_ticker'] as String?,
  estimateFeeMode: json['estimate_fee_mode'] as String?,
  orderbookTicker: json['orderbook_ticker'] as String?,
  taddr: json['taddr'] as num?,
  forceMinRelayFee: json['force_min_relay_fee'] as bool?,
  p2p: json['p2p'] as num?,
  magic: json['magic'] as String?,
  nSPV: json['n_s_p_v'] as String?,
  isPoSV: json['is_po_s_v'] as num?,
  versionGroupId: json['version_group_id'] as String?,
  consensusBranchId: json['consensus_branch_id'] as String?,
  estimateFeeBlocks: json['estimate_fee_blocks'] as num?,
);

Map<String, dynamic> _$CoinToJson(_Coin instance) => <String, dynamic>{
  'coin': instance.coin,
  'name': instance.name,
  'fname': instance.fname,
  'rpcport': instance.rpcport,
  'mm2': instance.mm2,
  'chain_id': instance.chainId,
  'required_confirmations': instance.requiredConfirmations,
  'avg_blocktime': instance.avgBlocktime,
  'decimals': instance.decimals,
  'protocol': instance.protocol,
  'derivation_path': instance.derivationPath,
  'trezor_coin': instance.trezorCoin,
  'links': instance.links,
  'is_po_s': instance.isPoS,
  'pubtype': instance.pubtype,
  'p2shtype': instance.p2shtype,
  'wiftype': instance.wiftype,
  'txfee': instance.txfee,
  'dust': instance.dust,
  'mature_confirmations': instance.matureConfirmations,
  'segwit': instance.segwit,
  'sign_message_prefix': instance.signMessagePrefix,
  'asset': instance.asset,
  'txversion': instance.txversion,
  'overwintered': instance.overwintered,
  'requires_notarization': instance.requiresNotarization,
  'wallet_only': instance.walletOnly,
  'bech32_hrp': instance.bech32Hrp,
  'is_testnet': instance.isTestnet,
  'fork_id': instance.forkId,
  'signature_version': instance.signatureVersion,
  'confpath': instance.confpath,
  'address_format': instance.addressFormat,
  'alias_ticker': instance.aliasTicker,
  'estimate_fee_mode': instance.estimateFeeMode,
  'orderbook_ticker': instance.orderbookTicker,
  'taddr': instance.taddr,
  'force_min_relay_fee': instance.forceMinRelayFee,
  'p2p': instance.p2p,
  'magic': instance.magic,
  'n_s_p_v': instance.nSPV,
  'is_po_s_v': instance.isPoSV,
  'version_group_id': instance.versionGroupId,
  'consensus_branch_id': instance.consensusBranchId,
  'estimate_fee_blocks': instance.estimateFeeBlocks,
};
