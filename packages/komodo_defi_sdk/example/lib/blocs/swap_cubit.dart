import 'package:bloc/bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SwapState {
  const SwapState({
    this.sellAsset,
    this.buyAsset,
    this.bestOrders,
    this.orderbook,
    this.loadingBestOrders = false,
    this.loadingOrderbook = false,
    this.error,
  });

  final Asset? sellAsset;
  final Asset? buyAsset;
  final BestOrdersResponse? bestOrders;
  final OrderbookResponse? orderbook;
  final bool loadingBestOrders;
  final bool loadingOrderbook;
  final String? error;

  SwapState copyWith({
    Asset? sellAsset,
    Asset? buyAsset,
    BestOrdersResponse? bestOrders,
    OrderbookResponse? orderbook,
    bool? loadingBestOrders,
    bool? loadingOrderbook,
    String? error,
  }) {
    return SwapState(
      sellAsset: sellAsset ?? this.sellAsset,
      buyAsset: buyAsset ?? this.buyAsset,
      bestOrders: bestOrders ?? this.bestOrders,
      orderbook: orderbook ?? this.orderbook,
      loadingBestOrders: loadingBestOrders ?? this.loadingBestOrders,
      loadingOrderbook: loadingOrderbook ?? this.loadingOrderbook,
      error: error,
    );
  }
}

class SwapCubit extends Cubit<SwapState> {
  SwapCubit(this._sdk) : super(const SwapState());

  final KomodoDefiSdk _sdk;

  List<Asset> get assets {
    final list = _sdk.assets.available.values.toList();
    list.sort((a, b) => a.id.id.compareTo(b.id.id));
    return list;
  }

  void setSellAsset(Asset? asset) {
    emit(state.copyWith(sellAsset: asset, error: null));
    if (asset != null) {
      loadBestOrders(asset);
    }
  }

  void setBuyAsset(Asset? asset) {
    emit(state.copyWith(buyAsset: asset, error: null));
    if (asset != null) {
      loadOrderbook();
    }
  }

  Future<void> loadBestOrders(Asset asset) async {
    emit(state.copyWith(loadingBestOrders: true, error: null));
    try {
      final response = await _sdk.client.rpc.orderbook.bestOrders(
        coin: asset.id.id,
        action: 'sell',
        requestBy: const RequestByNumber(value: 10),
      );
      emit(state.copyWith(bestOrders: response));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(loadingBestOrders: false));
    }
  }

  Future<void> loadOrderbook() async {
    final sell = state.sellAsset;
    final buy = state.buyAsset;
    if (sell == null || buy == null) return;
    emit(state.copyWith(loadingOrderbook: true, error: null));
    try {
      final response = await _sdk.client.rpc.orderbook.orderbook(
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
