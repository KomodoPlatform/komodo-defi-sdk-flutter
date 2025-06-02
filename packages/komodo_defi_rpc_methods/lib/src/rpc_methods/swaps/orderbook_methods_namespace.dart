import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Namespace for trading and order-related methods
class OrderbookMethodsNamespace extends BaseRpcMethodNamespace {
  /// Creates a new trading methods namespace
  OrderbookMethodsNamespace(super.client);

  /// Returns the best priced trades available on the orderbook
  Future<BestOrdersResponse> bestOrders({
    required String coin,
    required String action,
    required RequestBy requestBy,
    bool excludeMine = false,
    String? rpcPass,
  }) {
    return execute(
      BestOrdersRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        action: action,
        requestBy: requestBy,
        excludeMine: excludeMine,
      ),
    );
  }

  /// Returns the currently available orders for the specified trading pair
  Future<OrderbookResponse> orderbook({
    required String base,
    required String rel,
    String? rpcPass,
  }) {
    return execute(
      OrderbookRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
      ),
    );
  }

  /// Returns all the swaps that are currently running on the Komodo DeFi
  /// Framework API node
  Future<ActiveSwapsResponse> activeSwaps({
    bool includeStatus = false,
    String? rpcPass,
  }) {
    return execute(
      ActiveSwapsRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        includeStatus: includeStatus,
      ),
    );
  }

  /// Returns the amount of a coin which is currently locked by a swap in
  /// progress
  Future<GetLockedAmountResponse> getLockedAmount({
    required String coin,
    String? rpcPass,
  }) {
    return execute(
      GetLockedAmountRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
      ),
    );
  }

  /// Returns the maximum volume of a coin which can be used to create a maker
  /// order
  Future<MaxMakerVolResponse> maxMakerVol({
    required String coin,
    String? rpcPass,
  }) {
    return execute(
      MaxMakerVolRequest(rpcPass: rpcPass ?? this.rpcPass ?? '', coin: coin),
    );
  }

  /// Returns the data of the most recent atomic swaps executed by the
  /// Komodo DeFi Framework API node
  ///
  /// [limit] specifies the number of swaps to return per page and must be a positive integer.
  /// [pageNumber] specifies which page of results to return and must be a positive integer.
  /// 
  /// Throws [ArgumentError] if pagination parameters are invalid.
  Future<MyRecentSwapsResponse> myRecentSwaps({
    String? myCoin,
    String? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
    String? fromUuid,
    int limit = 10,
    int pageNumber = 1,
    String? rpcPass,
  }) {
    // Validate pagination parameters
    if (limit <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Limit must be a positive integer',
      );
    }
    
    if (pageNumber <= 0) {
      throw ArgumentError.value(
        pageNumber,
        'pageNumber',
        'Page number must be a positive integer',
      );
    }
    
    return execute(
      MyRecentSwapsRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        myCoin: myCoin,
        otherCoin: otherCoin,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        fromUuid: fromUuid,
        limit: limit,
        pageNumber: pageNumber,
      ),
    );
  }

  /// Recreates swap data from the opposite side of a trade
  Future<RecreateSwapDataResponse> recreateSwapData({
    required SwapStatus swap,
    String? rpcPass,
  }) {
    return execute(
      RecreateSwapDataRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        swap: swap,
      ),
    );
  }

  /// Calculates the details of a potential trade including fees and volumes
  ///
  /// [volume] and [max] parameters are mutually exclusive and should not be used
  /// simultaneously. If both are provided, an [ArgumentError] will be thrown.
  ///
  /// - Use [volume] to specify an exact amount to trade
  /// - Use [max] (set to true) to use the maximum available balance
  Future<TradePreimageResponse> tradePreimage({
    required String base,
    required String rel,
    required String swapMethod,
    required Decimal price,
    Decimal? volume,
    bool max = false,
    String? rpcPass,
  }) {
    // Validate that volume and max are not both provided
    if (volume != null && max == true) {
      throw ArgumentError(
        'Cannot specify both volume and max parameters simultaneously. '
        'Use either volume to specify an exact amount or max=true to '
        'use maximum available balance.',
      );
    }

    return execute(
      TradePreimageRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        swapMethod: swapMethod,
        price: price,
        volume: volume,
        max: max,
      ),
    );
  }

  /// Legacy method to place a maker order on the orderbook
  Future<SetPriceResponse> setPriceLegacy({
    required String base,
    required String rel,
    required Decimal price,
    Decimal? volume,
    bool max = false,
    bool cancelPrevious = true,
    Decimal? minVolume,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    bool saveInHistory = true,
    String? rpcPass,
  }) {
    return execute(
      SetPriceRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        price: price,
        volume: volume,
        max: max,
        cancelPrevious: cancelPrevious,
        minVolume: minVolume,
        baseConfs: baseConfs,
        baseNota: baseNota,
        relConfs: relConfs,
        relNota: relNota,
        saveInHistory: saveInHistory,
      ),
    );
  }

  /// Legacy method to buy base coin with rel coin
  Future<BuyResponse> buyLegacy({
    required String base,
    required String rel,
    required Decimal price,
    required Decimal volume,
    Decimal? minVolume,
    MatchBy? matchBy,
    OrderType? orderType,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    bool saveInHistory = true,
    String? rpcPass,
  }) {
    return execute(
      BuyRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        price: price,
        volume: volume,
        minVolume: minVolume,
        matchBy: matchBy,
        orderType: orderType,
        baseConfs: baseConfs,
        baseNota: baseNota,
        relConfs: relConfs,
        relNota: relNota,
        saveInHistory: saveInHistory,
      ),
    );
  }

  /// Legacy method to sell base coin for rel coin
  Future<SellResponse> sellLegacy({
    required String base,
    required String rel,
    required Decimal price,
    required Decimal volume,
    Decimal? minVolume,
    MatchBy? matchBy,
    OrderType? orderType,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    bool saveInHistory = true,
    String? rpcPass,
  }) {
    return execute(
      SellRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        price: price,
        volume: volume,
        minVolume: minVolume,
        matchBy: matchBy,
        orderType: orderType,
        baseConfs: baseConfs,
        baseNota: baseNota,
        relConfs: relConfs,
        relNota: relNota,
        saveInHistory: saveInHistory,
      ),
    );
  }

  /// Cancels a specific order
  Future<CancelOrderResponse> cancelOrderLegacy({
    required String uuid,
    String? rpcPass,
  }) {
    return execute(
      CancelOrderRequest(rpcPass: rpcPass ?? this.rpcPass ?? '', uuid: uuid),
    );
  }

  /// Cancels all orders based on a condition
  Future<CancelAllOrdersResponse> cancelAllOrdersLegacy({
    required CancelBy cancelBy,
    String? rpcPass,
  }) {
    return execute(
      CancelAllOrdersRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        cancelBy: cancelBy,
      ),
    );
  }

  /// Returns the number of asks and bids for the specified trading pairs
  Future<OrderbookDepthResponse> orderbookDepthLegacy({
    required List<List<String>> pairs,
    String? rpcPass,
  }) {
    return execute(
      OrderbookDepthRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        pairs: pairs,
      ),
    );
  }

  /// Returns all orders whether active or inactive that match the selected
  /// filters
  Future<OrdersHistoryByFilterResponse> ordersHistoryByFilterLegacy({
    String? orderType,
    String? initialAction,
    String? base,
    String? rel,
    Decimal? fromPrice,
    Decimal? toPrice,
    Decimal? fromVolume,
    Decimal? toVolume,
    int? fromTimestamp,
    int? toTimestamp,
    bool? wasTaker,
    String? status,
    bool includeDetails = false,
    String? rpcPass,
  }) {
    return execute(
      OrdersHistoryByFilterRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        orderType: orderType,
        initialAction: initialAction,
        base: base,
        rel: rel,
        fromPrice: fromPrice,
        toPrice: toPrice,
        fromVolume: fromVolume,
        toVolume: toVolume,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        wasTaker: wasTaker,
        status: status,
        includeDetails: includeDetails,
      ),
    );
  }

  /// Returns the status of an order by UUID
  Future<OrderStatusResponse> orderStatusLegacy({
    required String uuid,
    String? rpcPass,
  }) {
    return execute(
      OrderStatusRequest(rpcPass: rpcPass ?? this.rpcPass ?? '', uuid: uuid),
    );
  }
}
