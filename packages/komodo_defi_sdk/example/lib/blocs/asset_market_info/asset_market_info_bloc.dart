import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'asset_market_info_event.dart';
part 'asset_market_info_state.dart';

class AssetMarketInfoBloc
    extends Bloc<AssetMarketInfoEvent, AssetMarketInfoState> {
  AssetMarketInfoBloc({required KomodoDefiSdk sdk})
    : _sdk = sdk,
      super(const AssetMarketInfoState()) {
    on<AssetMarketInfoRequested>(_onWatchAssetMarketInfo);
  }

  final KomodoDefiSdk _sdk;

  Future<void> _onWatchAssetMarketInfo(
    AssetMarketInfoRequested event,
    Emitter<AssetMarketInfoState> emit,
  ) async {
    final asset = event.asset;
    final price = await _sdk.marketData.maybeFiatPrice(
      asset.id,
      quoteCurrency: FiatCurrency.usd,
    );
    final change = await _sdk.marketData.priceChange24h(
      asset.id,
      quoteCurrency: FiatCurrency.usd,
    );

    emit(state.copyWith(price: price, change24h: change));

    final balanceStream = _sdk.balances.watchBalance(
      asset.id,
      activateIfNeeded: false,
    );

    await emit.forEach<Balance>(
      balanceStream,
      onData: (balance) {
        final usdBalance = price != null ? price * balance.total : null;
        return state.copyWith(usdBalance: usdBalance);
      },
      onError: (error, stackTrace) {
        return state;
      },
    );
  }
}
