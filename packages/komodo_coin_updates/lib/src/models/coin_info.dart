import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:komodo_coin_updates/src/persistence/persistence_provider.dart';

import '../../komodo_coin_updates.dart';

part 'adapters/coin_info_adapter.dart';

class CoinInfo extends Equatable implements ObjectWithPrimaryKey<String> {
  const CoinInfo({
    required this.coin,
    required this.coinConfig,
  });

  final Coin coin;
  final CoinConfig? coinConfig;

  @override
  String get primaryKey => coin.coin;

  @override
  // TODO(Francois): optimize for comparisons - decide on fields to use when comparing
  List<Object?> get props => <Object?>[coin, coinConfig];
}
