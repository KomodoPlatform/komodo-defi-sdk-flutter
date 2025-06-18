import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'bridge_event.dart';
part 'bridge_state.dart';

class BridgeBloc extends Bloc<BridgeEvent, BridgeState> {
  BridgeBloc(this._sdk) : super(BridgeState.initial) {
    on<BridgeInit>(_onInit);
    on<BridgeTickerChanged>(_onTickerChanged);
    on<BridgeShowTickerDropdown>(_onShowTickerDropdown);
    on<BridgeShowSourceDropdown>(_onShowSourceDropdown);
    on<BridgeShowTargetDropdown>(_onShowTargetDropdown);
    on<BridgeSetSellAsset>(_onSetSellAsset);
    on<BridgeSelectBestOrder>(_onSelectBestOrder);
    on<BridgeSetError>(_onSetError);
    on<BridgeClearErrors>(_onClearErrors);
    on<BridgeSetSellAmount>(_onSetSellAmount);
    on<BridgeSellAmountChanged>(_onSellAmountChanged);
    on<BridgeAmountButtonClicked>(_onAmountButtonClicked);
    on<BridgeSubmitClicked>(_onSubmitClicked);
    on<BridgeBackClicked>(_onBackClicked);
    on<BridgeStartSwap>(_onStartSwap);
    on<BridgeClear>(_onClear);
  }

  final KomodoDefiSdk _sdk;

  Future<void> _onInit(BridgeInit event, Emitter<BridgeState> emit) async {
    try {
      final assets = _sdk.assets.available;
      final tickers = _extractTickers(assets);

      emit(
        state.copyWith(selectedTicker: event.ticker, availableTickers: tickers),
      );

      await _loadSourceAssets(event.ticker, emit);
    } catch (e, s) {
      emit(state.copyWith(error: 'Failed to initialize: $e'));
    }
  }

  Future<void> _onTickerChanged(
    BridgeTickerChanged event,
    Emitter<BridgeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTicker: event.ticker,
        bestOrder: null,
        showTickerDropdown: false,
        error: null,
      ),
    );

    if (event.ticker != null) {
      await _loadSourceAssets(event.ticker!, emit);
    }
  }

  void _onShowTickerDropdown(
    BridgeShowTickerDropdown event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(showTickerDropdown: event.show));
  }

  void _onShowSourceDropdown(
    BridgeShowSourceDropdown event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(showSourceDropdown: event.show));
  }

  void _onShowTargetDropdown(
    BridgeShowTargetDropdown event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(showTargetDropdown: event.show));
  }

  Future<void> _onSetSellAsset(
    BridgeSetSellAsset event,
    Emitter<BridgeState> emit,
  ) async {
    emit(
      state.copyWith(
        sellAsset: event.asset,
        bestOrder: null,
        showSourceDropdown: false,
        error: null,
      ),
    );

    await _loadBestOrders(event.asset, emit);
  }

  void _onSelectBestOrder(
    BridgeSelectBestOrder event,
    Emitter<BridgeState> emit,
  ) {
    emit(
      state.copyWith(
        bestOrder: event.order,
        showTargetDropdown: false,
        error: null,
      ),
    );

    if (event.order != null && state.sellAmount != null) {
      _calculateBuyAmount(emit);
    }
  }

  void _onSetError(BridgeSetError event, Emitter<BridgeState> emit) {
    emit(state.copyWith(error: event.error));
  }

  void _onClearErrors(BridgeClearErrors event, Emitter<BridgeState> emit) {
    emit(state.copyWith(error: null));
  }

  void _onSetSellAmount(BridgeSetSellAmount event, Emitter<BridgeState> emit) {
    emit(state.copyWith(sellAmount: event.amount));

    if (event.amount != null && state.bestOrder != null) {
      _calculateBuyAmount(emit);
    }
  }

  void _onSellAmountChanged(
    BridgeSellAmountChanged event,
    Emitter<BridgeState> emit,
  ) {
    try {
      final amount = event.value.isEmpty ? null : Decimal.parse(event.value);
      emit(state.copyWith(sellAmount: amount, error: null));

      if (amount != null && state.bestOrder != null) {
        _calculateBuyAmount(emit);
      }
    } catch (e, s) {
      emit(state.copyWith(error: 'Invalid amount format'));
    }
  }

  void _onAmountButtonClicked(
    BridgeAmountButtonClicked event,
    Emitter<BridgeState> emit,
  ) {
    final maxAmount = state.maxSellAmount;
    if (maxAmount != null) {
      final amount = maxAmount * Decimal.parse(event.fraction.toString());
      emit(state.copyWith(sellAmount: amount));

      if (state.bestOrder != null) {
        _calculateBuyAmount(emit);
      }
    }
  }

  Future<void> _onSubmitClicked(
    BridgeSubmitClicked event,
    Emitter<BridgeState> emit,
  ) async {
    if (!_validateForm()) {
      return;
    }

    emit(state.copyWith(step: BridgeStep.confirm, inProgress: true));

    try {
      final preimage = await _getTradePreimage();
      emit(state.copyWith(preimageData: preimage, inProgress: false));
    } catch (e, s) {
      emit(
        state.copyWith(
          error: 'Failed to get trade preimage: $e',
          inProgress: false,
          step: BridgeStep.form,
        ),
      );
    }
  }

  void _onBackClicked(BridgeBackClicked event, Emitter<BridgeState> emit) {
    emit(state.copyWith(step: BridgeStep.form));
  }

  Future<void> _onStartSwap(
    BridgeStartSwap event,
    Emitter<BridgeState> emit,
  ) async {
    if (state.sellAsset == null ||
        state.bestOrder == null ||
        state.sellAmount == null) {
      emit(state.copyWith(error: 'Missing required data for swap'));
      return;
    }

    emit(state.copyWith(inProgress: true));

    try {
      // Find the asset that matches the best order's coin
      final relAsset =
          _sdk.assets.available.values
              .where((asset) => asset.id.id == state.bestOrder!.coin)
              .firstOrNull;

      if (relAsset == null) {
        throw Exception('Asset not found for coin: ${state.bestOrder!.coin}');
      }

      // Use the SwapManager instead of direct RPC
      final parameters = SwapParameters(
        base: state.sellAsset!.id,
        rel: relAsset.id,
        volume: state.sellAmount!,
        price: state.bestOrder!.price.toDecimal(),
        swapMethod: 'buy',
      );

      // Listen to the swap stream to get the UUID
      final swapStream = _sdk.swaps.swap(parameters);
      await for (final progress in swapStream) {
        if (progress.uuid != null) {
          emit(state.copyWith(swapUuid: progress.uuid, inProgress: false));
          break; // Exit after getting the UUID
        }
      }
    } catch (e, s) {
      emit(
        state.copyWith(error: 'Failed to start swap: $e', inProgress: false),
      );
    }
  }

  void _onClear(BridgeClear event, Emitter<BridgeState> emit) {
    emit(BridgeState.initial);
  }

  List<String> _extractTickers(Map<AssetId, Asset> assets) {
    final tickers = <String>{};
    for (final asset in assets.values) {
      // Extract ticker from asset name or ID
      final ticker = _getTickerFromAsset(asset);
      if (ticker != null) {
        tickers.add(ticker);
      }
    }
    return tickers.toList()..sort();
  }

  String? _getTickerFromAsset(Asset asset) {
    // Simple ticker extraction - in a real implementation this would be more
    // sophisticated
    final name = asset.id.name.toUpperCase();
    if (name.contains('-')) {
      return name.split('-')[0];
    }
    return name;
  }

  Future<void> _loadSourceAssets(
    String ticker,
    Emitter<BridgeState> emit,
  ) async {
    try {
      final assets = _sdk.assets.available;
      final sourceAssets =
          assets.values
              .where((asset) => _getTickerFromAsset(asset) == ticker)
              .toList();

      emit(state.copyWith(sourceAssets: sourceAssets));
    } catch (e, s) {
      emit(state.copyWith(error: 'Failed to load source assets: $e'));
    }
  }

  Future<void> _loadBestOrders(Asset asset, Emitter<BridgeState> emit) async {
    try {
      final response = await _sdk.orderbook.getBestOrders(
        assetId: asset.id,
        action: 'sell',
        requestBy: const RequestByNumber(value: 10),
      );

      // Filter orders to only include those from the same protocol as the
      // source asset
      final filteredResponse = _filterOrdersByProtocol(response, asset);

      emit(state.copyWith(bestOrders: filteredResponse));
    } catch (e, s) {
      emit(state.copyWith(error: 'Failed to load best orders: $e'));
    }
  }

  /// Filters best orders to only include orders from the same protocol as the
  /// source asset
  BestOrdersResponse _filterOrdersByProtocol(
    BestOrdersResponse response,
    Asset sourceAsset,
  ) {
    final filteredOrders = <String, List<OrderData>>{};

    for (final entry in response.orders.entries) {
      final coinName = entry.key;
      final orders = entry.value;

      // Check if there's an asset with this coin name that has the same
      // protocol as the source asset
      final matchingAsset =
          _sdk.assets.available.values
              .where(
                (asset) =>
                    asset.id.id == coinName &&
                    _isSameProtocolFamily(asset.protocol, sourceAsset.protocol),
              )
              .firstOrNull;

      // Only include orders if we found a matching asset with the same
      // protocol
      if (matchingAsset != null) {
        filteredOrders[coinName] = orders;
      }
    }

    return BestOrdersResponse(
      mmrpc: response.mmrpc,
      id: response.id,
      orders: filteredOrders,
      originalTickers: response.originalTickers,
    );
  }

  /// Checks if two protocols belong to the same protocol family
  bool _isSameProtocolFamily(ProtocolClass protocol1, ProtocolClass protocol2) {
    // For now, we'll consider protocols the same if they have the same
    // runtime type. This could be refined further based on specific protocol
    // characteristics
    return protocol1.runtimeType == protocol2.runtimeType;
  }

  void _calculateBuyAmount(Emitter<BridgeState> emit) {
    final sellAmount = state.sellAmount;
    final bestOrder = state.bestOrder;

    if (sellAmount != null && bestOrder != null) {
      final price = bestOrder.price.toDecimal();
      final buyAmount = sellAmount * price;
      emit(state.copyWith(buyAmount: buyAmount));
    }
  }

  bool _validateForm() {
    if (state.sellAsset == null) {
      add(const BridgeSetError('Please select a source asset'));
      return false;
    }

    if (state.bestOrder == null) {
      add(const BridgeSetError('Please select a target order'));
      return false;
    }

    if (state.sellAmount == null || state.sellAmount! <= Decimal.zero) {
      add(const BridgeSetError('Please enter a valid sell amount'));
      return false;
    }

    return true;
  }

  Future<SwapPreview> _getTradePreimage() {
    // Find the asset that matches the best order's coin
    final relAsset =
        _sdk.assets.available.values
            .where((asset) => asset.id.id == state.bestOrder!.coin)
            .firstOrNull;

    if (relAsset == null) {
      throw Exception('Asset not found for coin: ${state.bestOrder!.coin}');
    }

    final parameters = SwapParameters(
      base: state.sellAsset!.id,
      rel: relAsset.id,
      volume: state.sellAmount!,
      price: state.bestOrder!.price.toDecimal(),
      swapMethod: 'sell',
    );

    return _sdk.swaps.previewSwap(parameters);
  }
}
