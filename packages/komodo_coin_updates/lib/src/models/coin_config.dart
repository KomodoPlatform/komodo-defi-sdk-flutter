import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:komodo_coin_updates/src/persistence/persistence_provider.dart';

import 'address_format.dart';
import 'electrum.dart';
import 'links.dart';
import 'node.dart';
import 'protocol.dart';
import 'rpc_url.dart';

part 'adapters/coin_config_adapter.dart';

class CoinConfig extends Equatable implements ObjectWithPrimaryKey<String> {
  const CoinConfig({
    required this.coin,
    this.type,
    this.name,
    this.coingeckoId,
    this.livecoinwatchId,
    this.explorerUrl,
    this.explorerTxUrl,
    this.explorerAddressUrl,
    this.supported,
    this.active,
    this.isTestnet,
    this.currentlyEnabled,
    this.walletOnly,
    this.fname,
    this.rpcport,
    this.mm2,
    this.chainId,
    this.requiredConfirmations,
    this.avgBlocktime,
    this.decimals,
    this.protocol,
    this.derivationPath,
    this.contractAddress,
    this.parentCoin,
    this.swapContractAddress,
    this.fallbackSwapContract,
    this.nodes,
    this.explorerBlockUrl,
    this.tokenAddressUrl,
    this.trezorCoin,
    this.links,
    this.pubtype,
    this.p2shtype,
    this.wiftype,
    this.txfee,
    this.dust,
    this.segwit,
    this.electrum,
    this.signMessagePrefix,
    this.lightWalletDServers,
    this.asset,
    this.txversion,
    this.overwintered,
    this.requiresNotarization,
    this.checkpointHeight,
    this.checkpointBlocktime,
    this.binanceId,
    this.bech32Hrp,
    this.forkId,
    this.signatureVersion,
    this.confpath,
    this.matureConfirmations,
    this.bchdUrls,
    this.otherTypes,
    this.addressFormat,
    this.allowSlpUnsafeConf,
    this.slpPrefix,
    this.tokenId,
    this.forexId,
    this.isPoS,
    this.aliasTicker,
    this.estimateFeeMode,
    this.orderbookTicker,
    this.taddr,
    this.forceMinRelayFee,
    this.isClaimable,
    this.minimalClaimAmount,
    this.isPoSV,
    this.versionGroupId,
    this.consensusBranchId,
    this.estimateFeeBlocks,
    this.rpcUrls,
  });

  factory CoinConfig.fromJson(Map<String, dynamic> json) {
    return CoinConfig(
      coin: json['coin'] as String,
      type: json['type'] as String?,
      name: json['name'] as String?,
      coingeckoId: json['coingecko_id'] as String?,
      livecoinwatchId: json['livecoinwatch_id'] as String?,
      explorerUrl: json['explorer_url'] as String?,
      explorerTxUrl: json['explorer_tx_url'] as String?,
      explorerAddressUrl: json['explorer_address_url'] as String?,
      supported: (json['supported'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
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
      protocol: json['protocol'] == null
          ? null
          : Protocol.fromJson(json['protocol'] as Map<String, dynamic>),
      derivationPath: json['derivation_path'] as String?,
      contractAddress: json['contractAddress'] as String?,
      parentCoin: json['parent_coin'] as String?,
      swapContractAddress: json['swap_contract_address'] as String?,
      fallbackSwapContract: json['fallback_swap_contract'] as String?,
      nodes: (json['nodes'] as List<dynamic>?)
          ?.map((dynamic e) => Node.fromJson(e as Map<String, dynamic>))
          .toList(),
      explorerBlockUrl: json['explorer_block_url'] as String?,
      tokenAddressUrl: json['token_address_url'] as String?,
      trezorCoin: json['trezor_coin'] as String?,
      links: json['links'] == null
          ? null
          : Links.fromJson(json['links'] as Map<String, dynamic>),
      pubtype: json['pubtype'] as num?,
      p2shtype: json['p2shtype'] as num?,
      wiftype: json['wiftype'] as num?,
      txfee: json['txfee'] as num?,
      dust: json['dust'] as num?,
      segwit: json['segwit'] as bool?,
      electrum: (json['electrum'] as List<dynamic>?)
          ?.map((dynamic e) => Electrum.fromJson(e as Map<String, dynamic>))
          .toList(),
      signMessagePrefix: json['sign_message_refix'] as String?,
      lightWalletDServers: (json['light_wallet_d_servers'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
      asset: json['asset'] as String?,
      txversion: json['txversion'] as num?,
      overwintered: json['overwintered'] as num?,
      requiresNotarization: json['requires_notarization'] as bool?,
      checkpointHeight: json['checkpoint_height'] as num?,
      checkpointBlocktime: json['checkpoint_blocktime'] as num?,
      binanceId: json['binance_id'] as String?,
      bech32Hrp: json['bech32_hrp'] as String?,
      forkId: json['forkId'] as String?,
      signatureVersion: json['signature_version'] as String?,
      confpath: json['confpath'] as String?,
      matureConfirmations: json['mature_confirmations'] as num?,
      bchdUrls: (json['bchd_urls'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
      otherTypes: (json['other_types'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
      addressFormat: json['address_format'] == null
          ? null
          : AddressFormat.fromJson(
              json['address_format'] as Map<String, dynamic>,
            ),
      allowSlpUnsafeConf: json['allow_slp_unsafe_conf'] as bool?,
      slpPrefix: json['slp_prefix'] as String?,
      tokenId: json['token_id'] as String?,
      forexId: json['forex_id'] as String?,
      isPoS: json['isPoS'] as num?,
      aliasTicker: json['alias_ticker'] as String?,
      estimateFeeMode: json['estimate_fee_mode'] as String?,
      orderbookTicker: json['orderbook_ticker'] as String?,
      taddr: json['taddr'] as num?,
      forceMinRelayFee: json['force_min_relay_fee'] as bool?,
      isClaimable: json['is_claimable'] as bool?,
      minimalClaimAmount: json['minimal_claim_amount'] as String?,
      isPoSV: json['isPoSV'] as num?,
      versionGroupId: json['version_group_id'] as String?,
      consensusBranchId: json['consensus_branch_id'] as String?,
      estimateFeeBlocks: json['estimate_fee_blocks'] as num?,
      rpcUrls: (json['rpc_urls'] as List<dynamic>?)
          ?.map((dynamic e) => RpcUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String coin;
  final String? type;
  final String? name;
  final String? coingeckoId;
  final String? livecoinwatchId;
  final String? explorerUrl;
  final String? explorerTxUrl;
  final String? explorerAddressUrl;
  final List<String>? supported;
  final bool? active;
  final bool? isTestnet;
  final bool? currentlyEnabled;
  final bool? walletOnly;
  final String? fname;
  final num? rpcport;
  final num? mm2;
  final num? chainId;
  final num? requiredConfirmations;
  final num? avgBlocktime;
  final num? decimals;
  final Protocol? protocol;
  final String? derivationPath;
  final String? contractAddress;
  final String? parentCoin;
  final String? swapContractAddress;
  final String? fallbackSwapContract;
  final List<Node>? nodes;
  final String? explorerBlockUrl;
  final String? tokenAddressUrl;
  final String? trezorCoin;
  final Links? links;
  final num? pubtype;
  final num? p2shtype;
  final num? wiftype;
  final num? txfee;
  final num? dust;
  final bool? segwit;
  final List<Electrum>? electrum;
  final String? signMessagePrefix;
  final List<String>? lightWalletDServers;
  final String? asset;
  final num? txversion;
  final num? overwintered;
  final bool? requiresNotarization;
  final num? checkpointHeight;
  final num? checkpointBlocktime;
  final String? binanceId;
  final String? bech32Hrp;
  final String? forkId;
  final String? signatureVersion;
  final String? confpath;
  final num? matureConfirmations;
  final List<String>? bchdUrls;
  final List<String>? otherTypes;
  final AddressFormat? addressFormat;
  final bool? allowSlpUnsafeConf;
  final String? slpPrefix;
  final String? tokenId;
  final String? forexId;
  final num? isPoS;
  final String? aliasTicker;
  final String? estimateFeeMode;
  final String? orderbookTicker;
  final num? taddr;
  final bool? forceMinRelayFee;
  final bool? isClaimable;
  final String? minimalClaimAmount;
  final num? isPoSV;
  final String? versionGroupId;
  final String? consensusBranchId;
  final num? estimateFeeBlocks;
  final List<RpcUrl>? rpcUrls;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coin': coin,
      'type': type,
      'name': name,
      'coingecko_id': coingeckoId,
      'livecoinwatch_id': livecoinwatchId,
      'explorer_url': explorerUrl,
      'explorer_tx_url': explorerTxUrl,
      'explorer_address_url': explorerAddressUrl,
      'supported': supported,
      'active': active,
      'is_testnet': isTestnet,
      'currently_enabled': currentlyEnabled,
      'wallet_only': walletOnly,
      'fname': fname,
      'rpcport': rpcport,
      'mm2': mm2,
      'chain_id': chainId,
      'required_confirmations': requiredConfirmations,
      'avg_blocktime': avgBlocktime,
      'decimals': decimals,
      'protocol': protocol?.toJson(),
      'derivation_path': derivationPath,
      'contractAddress': contractAddress,
      'parent_coin': parentCoin,
      'swap_contract_address': swapContractAddress,
      'fallback_swap_contract': fallbackSwapContract,
      'nodes': nodes?.map((Node e) => e.toJson()).toList(),
      'explorer_block_url': explorerBlockUrl,
      'token_address_url': tokenAddressUrl,
      'trezor_coin': trezorCoin,
      'links': links?.toJson(),
      'pubtype': pubtype,
      'p2shtype': p2shtype,
      'wiftype': wiftype,
      'txfee': txfee,
      'dust': dust,
      'segwit': segwit,
      'electrum': electrum?.map((Electrum e) => e.toJson()).toList(),
      'sign_message_refix': signMessagePrefix,
      'light_wallet_d_servers': lightWalletDServers,
      'asset': asset,
      'txversion': txversion,
      'overwintered': overwintered,
      'requires_notarization': requiresNotarization,
      'checkpoint_height': checkpointHeight,
      'checkpoint_blocktime': checkpointBlocktime,
      'binance_id': binanceId,
      'bech32_hrp': bech32Hrp,
      'forkId': forkId,
      'signature_version': signatureVersion,
      'confpath': confpath,
      'mature_confirmations': matureConfirmations,
      'bchd_urls': bchdUrls,
      'other_types': otherTypes,
      'address_format': addressFormat?.toJson(),
      'allow_slp_unsafe_conf': allowSlpUnsafeConf,
      'slp_prefix': slpPrefix,
      'token_id': tokenId,
      'forex_id': forexId,
      'isPoS': isPoS,
      'alias_ticker': aliasTicker,
      'estimate_fee_mode': estimateFeeMode,
      'orderbook_ticker': orderbookTicker,
      'taddr': taddr,
      'force_min_relay_fee': forceMinRelayFee,
      'is_claimable': isClaimable,
      'minimal_claim_amount': minimalClaimAmount,
      'isPoSV': isPoSV,
      'version_group_id': versionGroupId,
      'consensus_branch_id': consensusBranchId,
      'estimate_fee_blocks': estimateFeeBlocks,
      'rpc_urls': rpcUrls?.map((RpcUrl e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        coin,
        type,
        name,
        coingeckoId,
        livecoinwatchId,
        explorerUrl,
        explorerTxUrl,
        explorerAddressUrl,
        supported,
        active,
        isTestnet,
        currentlyEnabled,
        walletOnly,
        fname,
        rpcport,
        mm2,
        chainId,
        requiredConfirmations,
        avgBlocktime,
        decimals,
        protocol,
        derivationPath,
        contractAddress,
        parentCoin,
        swapContractAddress,
        fallbackSwapContract,
        nodes,
        explorerBlockUrl,
        tokenAddressUrl,
        trezorCoin,
        links,
        pubtype,
        p2shtype,
        wiftype,
        txfee,
        dust,
        segwit,
        electrum,
        signMessagePrefix,
        lightWalletDServers,
        asset,
        txversion,
        overwintered,
        requiresNotarization,
        checkpointHeight,
        checkpointBlocktime,
        binanceId,
        bech32Hrp,
        forkId,
        signatureVersion,
        confpath,
        matureConfirmations,
        bchdUrls,
        otherTypes,
        addressFormat,
        allowSlpUnsafeConf,
        slpPrefix,
        tokenId,
        forexId,
        isPoS,
        aliasTicker,
        estimateFeeMode,
        orderbookTicker,
        taddr,
        forceMinRelayFee,
        isClaimable,
        minimalClaimAmount,
        isPoSV,
        versionGroupId,
        consensusBranchId,
        estimateFeeBlocks,
        rpcUrls,
      ];

  @override
  String get primaryKey => coin;
}
