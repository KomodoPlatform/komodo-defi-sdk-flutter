import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Extensions for Trading/Swap-related RPC methods
class TradingMethodsNamespace extends BaseRpcMethodNamespace {
  TradingMethodsNamespace(super.client);

  /// Start a new swap
  Future<StartSwapResponse> startSwap({
    required SwapRequest swapRequest,
    String? rpcPass,
  }) {
    return execute(
      StartSwapRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        swapRequest: swapRequest,
      ),
    );
  }

  /// Get swap status
  Future<SwapStatusResponse> swapStatus({
    required String uuid,
    String? rpcPass,
  }) {
    return execute(
      SwapStatusRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        uuid: uuid,
      ),
    );
  }

  /// Get active swaps
  Future<ActiveSwapsResponse> activeSwaps({
    String? coin,
    String? rpcPass,
  }) {
    return execute(
      ActiveSwapsRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
      ),
    );
  }

  /// Get recent swaps with pagination
  Future<RecentSwapsResponse> recentSwaps({
    int? limit,
    int? fromUuid,
    String? coin,
    String? rpcPass,
  }) {
    return execute(
      RecentSwapsRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        limit: limit,
        fromUuid: fromUuid,
        coin: coin,
      ),
    );
  }

  /// Cancel an active swap
  Future<CancelSwapResponse> cancelSwap({
    required String uuid,
    String? rpcPass,
  }) {
    return execute(
      CancelSwapRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        uuid: uuid,
      ),
    );
  }

  /// Get trade preimage
  Future<TradePreimageResponse> tradePreimage({
    required String base,
    required String rel,
    required SwapMethod swapMethod,
    required String volume,
    String? price,
    String? rpcPass,
  }) {
    return execute(
      TradePreimageRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        swapMethod: swapMethod,
        volume: volume,
        price: price,
      ),
    );
  }

  /// Get max taker volume
  Future<MaxTakerVolumeResponse> maxTakerVolume({
    required String coin,
    String? rpcPass,
  }) {
    return execute(
      MaxTakerVolumeRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
      ),
    );
  }

  /// Get min trading volume
  Future<MinTradingVolumeResponse> minTradingVolume({
    required String coin,
    String? rpcPass,
  }) {
    return execute(
      MinTradingVolumeRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
      ),
    );
  }
}