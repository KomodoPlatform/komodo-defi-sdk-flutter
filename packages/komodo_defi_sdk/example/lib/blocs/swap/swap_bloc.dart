import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart' show BestOrdersResponse, OrderbookResponse, RequestByNumber;
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'swap_event.dart';
part 'swap_state.dart';

class SwapBloc extends Bloc<SwapEvent, SwapState> {
  SwapBloc(this._sdk) : super(const SwapState()) {
    on<SellAssetSelected>(_onSellAssetSelected);
    on<BuyAssetSelected>(_onBuyAssetSelected);
  }

  final KomodoDefiSdk _sdk;

  Future<void> _onSellAssetSelected(
    SellAssetSelected event,
    Emitter<SwapState> emit,
  ) async {
    emit(
      state.copyWith(
        sellAsset: event.asset,
        loadingBestOrders: true,
        error: null,
      ),
    );
    try {
      final response = await _sdk.orderbook.getBestOrders(
        coin: event.asset.id.id,
        action: 'sell',
        requestBy: const RequestByNumber(value: 10),
      );
      emit(state.copyWith(bestOrders: response));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(loadingBestOrders: false));
    }
    // Load orderbook if buy asset already selected
    final buy = state.buyAsset;
    if (buy != null) {
      await _loadOrderbook(event.asset, buy, emit);
    }
  }

  Future<void> _onBuyAssetSelected(
    BuyAssetSelected event,
    Emitter<SwapState> emit,
  ) async {
    emit(state.copyWith(buyAsset: event.asset));
    final sell = state.sellAsset;
    if (sell != null) {
      await _loadOrderbook(sell, event.asset, emit);
    }
  }

  Future<void> _loadOrderbook(
    Asset sell,
    Asset buy,
    Emitter<SwapState> emit,
  ) async {
    emit(state.copyWith(loadingOrderbook: true, error: null));
    try {
      final response = await _sdk.orderbook.getOrderbook(
        base: buy.id.id,
        rel: sell.id.id,
      );
      emit(state.copyWith(orderbook: response));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(loadingOrderbook: false));
    }
  }
}
