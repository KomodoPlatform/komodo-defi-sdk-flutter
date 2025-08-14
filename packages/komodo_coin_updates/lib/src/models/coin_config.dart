import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/address_format.dart';
import 'package:komodo_coin_updates/src/models/electrum.dart';
import 'package:komodo_coin_updates/src/models/links.dart';
import 'package:komodo_coin_updates/src/models/node.dart';
import 'package:komodo_coin_updates/src/models/protocol.dart';
import 'package:komodo_coin_updates/src/models/rpc_url.dart';

part 'coin_config.freezed.dart';
part 'coin_config.g.dart';

@freezed
abstract class CoinConfig with _$CoinConfig {
  const factory CoinConfig({
    required String coin,
    String? type,
    String? name,
    String? coingeckoId,
    String? livecoinwatchId,
    String? explorerUrl,
    String? explorerTxUrl,
    String? explorerAddressUrl,
    List<String>? supported,
    bool? active,
    bool? isTestnet,
    bool? currentlyEnabled,
    bool? walletOnly,
    String? fname,
    num? rpcport,
    num? mm2,
    num? chainId,
    num? requiredConfirmations,
    num? avgBlocktime,
    num? decimals,
    Protocol? protocol,
    String? derivationPath,
    String? contractAddress,
    String? parentCoin,
    String? swapContractAddress,
    String? fallbackSwapContract,
    List<Node>? nodes,
    String? explorerBlockUrl,
    String? tokenAddressUrl,
    String? trezorCoin,
    Links? links,
    num? pubtype,
    num? p2shtype,
    num? wiftype,
    num? txfee,
    num? dust,
    bool? segwit,
    List<Electrum>? electrum,
    String? signMessagePrefix,
    List<String>? lightWalletDServers,
    String? asset,
    num? txversion,
    num? overwintered,
    bool? requiresNotarization,
    num? checkpointHeight,
    num? checkpointBlocktime,
    String? binanceId,
    String? bech32Hrp,
    String? forkId,
    String? signatureVersion,
    String? confpath,
    num? matureConfirmations,
    List<String>? bchdUrls,
    List<String>? otherTypes,
    AddressFormat? addressFormat,
    bool? allowSlpUnsafeConf,
    String? slpPrefix,
    String? tokenId,
    String? forexId,
    num? isPoS,
    String? aliasTicker,
    String? estimateFeeMode,
    String? orderbookTicker,
    num? taddr,
    bool? forceMinRelayFee,
    bool? isClaimable,
    String? minimalClaimAmount,
    num? isPoSV,
    String? versionGroupId,
    String? consensusBranchId,
    num? estimateFeeBlocks,
    List<RpcUrl>? rpcUrls,
  }) = _CoinConfig;

  factory CoinConfig.fromJson(Map<String, dynamic> json) =>
      _$CoinConfigFromJson(json);

  const CoinConfig._();
}

// No custom converters are needed; global snake_case + explicit_to_json handles nested lists
