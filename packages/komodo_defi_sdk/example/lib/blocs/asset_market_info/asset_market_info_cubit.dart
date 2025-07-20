import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'asset_market_info_state.dart';

class AssetMarketInfoCubit extends Cubit<AssetMarketInfoState> {
  AssetMarketInfoCubit({required KomodoDefiSdk sdk, required Asset asset})
    : _sdk = sdk,
      _asset = asset,
      super(const AssetMarketInfoState()) {
    _init();
  }

  final KomodoDefiSdk _sdk;
  final Asset _asset;

  StreamSubscription<BalanceInfo>? _balanceSub;

  Future<void> _init() async {
    final price = await _sdk.marketData.maybeFiatPrice(
      _asset.id,
      fiatCurrency: 'usd',
    );
    final change = await _sdk.marketData.priceChange24h(
      _asset.id,
      fiatCurrency: 'usd',
    );

    emit(state.copyWith(price: price, change24h: change));

    _balanceSub = _sdk.balances
        .watchBalance(_asset.id, activateIfNeeded: false)
        .listen((balance) {
          final usdBalance = price != null ? price * balance.total : null;
          emit(state.copyWith(usdBalance: usdBalance));
        });
  }

  @override
  Future<void> close() {
    _balanceSub?.cancel();
    return super.close();
  }
}
