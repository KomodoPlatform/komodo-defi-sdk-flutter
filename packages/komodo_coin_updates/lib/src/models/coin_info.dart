import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/coin.dart';
import 'package:komodo_coin_updates/src/models/coin_config.dart';

part 'coin_info.freezed.dart';
part 'coin_info.g.dart';

@freezed
abstract class CoinInfo with _$CoinInfo {
  const factory CoinInfo({required Coin coin, CoinConfig? coinConfig}) =
      _CoinInfo;

  factory CoinInfo.fromJson(Map<String, dynamic> json) =>
      _$CoinInfoFromJson(json);

  const CoinInfo._();
}
