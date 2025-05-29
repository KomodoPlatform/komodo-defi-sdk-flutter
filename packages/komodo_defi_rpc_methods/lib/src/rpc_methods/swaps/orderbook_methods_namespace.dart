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
      MaxMakerVolRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
      ),
    );
  }

  /// Returns the data of the most recent atomic swaps executed by the
  /// Komodo DeFi Framework API node
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
  Future<TradePreimageResponse> tradePreimage({
    required String base,
    required String rel,
    required dynamic price,
    required dynamic volume,
    bool? maxVolume,
    bool? dryRun,
    String? rpcPass,
  }) {
    return execute(
      TradePreimageRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        price: price,
        volume: volume,
        maxVolume: maxVolume,
        dryRun: dryRun,
      ),
    );
  }

  /// Legacy method to place a maker order on the orderbook
  Future<SetPriceLegacyResponse> setPriceLegacy({
    required String base,
    required String rel,
    required dynamic price,
    dynamic? volume,
    bool max = false,
    bool cancelPrevious = true,
    dynamic? minVolume,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    bool saveInHistory = true,
    String? rpcPass,
  }) {
    return execute(
      SetPriceLegacyRequest(
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
  Future<BuyLegacyResponse> buyLegacy({
    required String base,
    required String rel,
    required dynamic price,
    required dynamic volume,
    dynamic? minVolume,
    Map<String, dynamic>? matchBy,
    Map<String, dynamic>? orderType,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    bool saveInHistory = true,
    String? rpcPass,
  }) {
    return execute(
      BuyLegacyRequest(
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
  Future<SellLegacyResponse> sellLegacy({
    required String base,
    required String rel,
    required dynamic price,
    required dynamic volume,
    dynamic? minVolume,
    Map<String, dynamic>? matchBy,
    Map<String, dynamic>? orderType,
    int? baseConfs,
    bool? baseNota,
    int? relConfs,
    bool? relNota,
    bool saveInHistory = true,
    String? rpcPass,
  }) {
    return execute(
      SellLegacyRequest(
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
  Future<CancelOrderResponse> cancelOrder({
    required String uuid,
    String? rpcPass,
  }) {
    return execute(
      CancelOrderRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        uuid: uuid,
      ),
    );
  }

  /// Cancels all orders based on a condition
  Future<CancelAllOrdersResponse> cancelAllOrders({
    required Map<String, dynamic> cancelBy,
    String? rpcPass,
  }) {
    return execute(
      CancelAllOrdersRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        cancelBy: cancelBy,
      ),
    );
  }
}
