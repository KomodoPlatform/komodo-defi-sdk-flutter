import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/address_format.dart';
import 'package:komodo_coin_updates/src/models/links.dart';
import 'package:komodo_coin_updates/src/models/protocol.dart';

part 'coin.freezed.dart';
part 'coin.g.dart';

@freezed
abstract class Coin with _$Coin {
  const factory Coin({
    required String coin,
    String? name,
    String? fname,
    num? rpcport,
    num? mm2,
    num? chainId,
    num? requiredConfirmations,
    num? avgBlocktime,
    num? decimals,
    Protocol? protocol,
    String? derivationPath,
    String? trezorCoin,
    Links? links,
    num? isPoS,
    num? pubtype,
    num? p2shtype,
    num? wiftype,
    num? txfee,
    num? dust,
    num? matureConfirmations,
    bool? segwit,
    String? signMessagePrefix,
    String? asset,
    num? txversion,
    num? overwintered,
    bool? requiresNotarization,
    bool? walletOnly,
    String? bech32Hrp,
    bool? isTestnet,
    String? forkId,
    String? signatureVersion,
    String? confpath,
    AddressFormat? addressFormat,
    String? aliasTicker,
    String? estimateFeeMode,
    String? orderbookTicker,
    num? taddr,
    bool? forceMinRelayFee,
    num? p2p,
    String? magic,
    String? nSPV,
    num? isPoSV,
    String? versionGroupId,
    String? consensusBranchId,
    num? estimateFeeBlocks,
  }) = _Coin;

  factory Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);

  const Coin._();
}
