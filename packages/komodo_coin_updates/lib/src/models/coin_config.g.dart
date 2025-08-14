// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinConfig _$CoinConfigFromJson(Map<String, dynamic> json) => _CoinConfig(
  coin: json['coin'] as String,
  type: json['type'] as String?,
  name: json['name'] as String?,
  coingeckoId: json['coingecko_id'] as String?,
  livecoinwatchId: json['livecoinwatch_id'] as String?,
  explorerUrl: json['explorer_url'] as String?,
  explorerTxUrl: json['explorer_tx_url'] as String?,
  explorerAddressUrl: json['explorer_address_url'] as String?,
  supported:
      (json['supported'] as List<dynamic>?)?.map((e) => e as String).toList(),
  active: json['active'] as bool?,
  isTestnet: json['is_testnet'] as bool?,
  currentlyEnabled: json['currently_enabled'] as bool?,
  walletOnly: json['wallet_only'] as bool?,
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
  contractAddress: json['contract_address'] as String?,
  parentCoin: json['parent_coin'] as String?,
  swapContractAddress: json['swap_contract_address'] as String?,
  fallbackSwapContract: json['fallback_swap_contract'] as String?,
  nodes:
      (json['nodes'] as List<dynamic>?)
          ?.map((e) => Node.fromJson(e as Map<String, dynamic>))
          .toList(),
  explorerBlockUrl: json['explorer_block_url'] as String?,
  tokenAddressUrl: json['token_address_url'] as String?,
  trezorCoin: json['trezor_coin'] as String?,
  links:
      json['links'] == null
          ? null
          : Links.fromJson(json['links'] as Map<String, dynamic>),
  pubtype: json['pubtype'] as num?,
  p2shtype: json['p2shtype'] as num?,
  wiftype: json['wiftype'] as num?,
  txfee: json['txfee'] as num?,
  dust: json['dust'] as num?,
  segwit: json['segwit'] as bool?,
  electrum:
      (json['electrum'] as List<dynamic>?)
          ?.map((e) => Electrum.fromJson(e as Map<String, dynamic>))
          .toList(),
  signMessagePrefix: json['sign_message_prefix'] as String?,
  lightWalletDServers:
      (json['light_wallet_d_servers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  asset: json['asset'] as String?,
  txversion: json['txversion'] as num?,
  overwintered: json['overwintered'] as num?,
  requiresNotarization: json['requires_notarization'] as bool?,
  checkpointHeight: json['checkpoint_height'] as num?,
  checkpointBlocktime: json['checkpoint_blocktime'] as num?,
  binanceId: json['binance_id'] as String?,
  bech32Hrp: json['bech32_hrp'] as String?,
  forkId: json['fork_id'] as String?,
  signatureVersion: json['signature_version'] as String?,
  confpath: json['confpath'] as String?,
  matureConfirmations: json['mature_confirmations'] as num?,
  bchdUrls:
      (json['bchd_urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
  otherTypes:
      (json['other_types'] as List<dynamic>?)?.map((e) => e as String).toList(),
  addressFormat:
      json['address_format'] == null
          ? null
          : AddressFormat.fromJson(
            json['address_format'] as Map<String, dynamic>,
          ),
  allowSlpUnsafeConf: json['allow_slp_unsafe_conf'] as bool?,
  slpPrefix: json['slp_prefix'] as String?,
  tokenId: json['token_id'] as String?,
  forexId: json['forex_id'] as String?,
  isPoS: json['is_po_s'] as num?,
  aliasTicker: json['alias_ticker'] as String?,
  estimateFeeMode: json['estimate_fee_mode'] as String?,
  orderbookTicker: json['orderbook_ticker'] as String?,
  taddr: json['taddr'] as num?,
  forceMinRelayFee: json['force_min_relay_fee'] as bool?,
  isClaimable: json['is_claimable'] as bool?,
  minimalClaimAmount: json['minimal_claim_amount'] as String?,
  isPoSV: json['is_po_s_v'] as num?,
  versionGroupId: json['version_group_id'] as String?,
  consensusBranchId: json['consensus_branch_id'] as String?,
  estimateFeeBlocks: json['estimate_fee_blocks'] as num?,
  rpcUrls:
      (json['rpc_urls'] as List<dynamic>?)
          ?.map((e) => RpcUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CoinConfigToJson(_CoinConfig instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'type': instance.type,
      'name': instance.name,
      'coingecko_id': instance.coingeckoId,
      'livecoinwatch_id': instance.livecoinwatchId,
      'explorer_url': instance.explorerUrl,
      'explorer_tx_url': instance.explorerTxUrl,
      'explorer_address_url': instance.explorerAddressUrl,
      'supported': instance.supported,
      'active': instance.active,
      'is_testnet': instance.isTestnet,
      'currently_enabled': instance.currentlyEnabled,
      'wallet_only': instance.walletOnly,
      'fname': instance.fname,
      'rpcport': instance.rpcport,
      'mm2': instance.mm2,
      'chain_id': instance.chainId,
      'required_confirmations': instance.requiredConfirmations,
      'avg_blocktime': instance.avgBlocktime,
      'decimals': instance.decimals,
      'protocol': instance.protocol,
      'derivation_path': instance.derivationPath,
      'contract_address': instance.contractAddress,
      'parent_coin': instance.parentCoin,
      'swap_contract_address': instance.swapContractAddress,
      'fallback_swap_contract': instance.fallbackSwapContract,
      'nodes': instance.nodes,
      'explorer_block_url': instance.explorerBlockUrl,
      'token_address_url': instance.tokenAddressUrl,
      'trezor_coin': instance.trezorCoin,
      'links': instance.links,
      'pubtype': instance.pubtype,
      'p2shtype': instance.p2shtype,
      'wiftype': instance.wiftype,
      'txfee': instance.txfee,
      'dust': instance.dust,
      'segwit': instance.segwit,
      'electrum': instance.electrum,
      'sign_message_prefix': instance.signMessagePrefix,
      'light_wallet_d_servers': instance.lightWalletDServers,
      'asset': instance.asset,
      'txversion': instance.txversion,
      'overwintered': instance.overwintered,
      'requires_notarization': instance.requiresNotarization,
      'checkpoint_height': instance.checkpointHeight,
      'checkpoint_blocktime': instance.checkpointBlocktime,
      'binance_id': instance.binanceId,
      'bech32_hrp': instance.bech32Hrp,
      'fork_id': instance.forkId,
      'signature_version': instance.signatureVersion,
      'confpath': instance.confpath,
      'mature_confirmations': instance.matureConfirmations,
      'bchd_urls': instance.bchdUrls,
      'other_types': instance.otherTypes,
      'address_format': instance.addressFormat,
      'allow_slp_unsafe_conf': instance.allowSlpUnsafeConf,
      'slp_prefix': instance.slpPrefix,
      'token_id': instance.tokenId,
      'forex_id': instance.forexId,
      'is_po_s': instance.isPoS,
      'alias_ticker': instance.aliasTicker,
      'estimate_fee_mode': instance.estimateFeeMode,
      'orderbook_ticker': instance.orderbookTicker,
      'taddr': instance.taddr,
      'force_min_relay_fee': instance.forceMinRelayFee,
      'is_claimable': instance.isClaimable,
      'minimal_claim_amount': instance.minimalClaimAmount,
      'is_po_s_v': instance.isPoSV,
      'version_group_id': instance.versionGroupId,
      'consensus_branch_id': instance.consensusBranchId,
      'estimate_fee_blocks': instance.estimateFeeBlocks,
      'rpc_urls': instance.rpcUrls,
    };
