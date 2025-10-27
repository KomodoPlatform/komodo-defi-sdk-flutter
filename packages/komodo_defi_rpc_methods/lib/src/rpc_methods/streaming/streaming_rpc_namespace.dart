import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// RPC namespace for streaming methods.
///
/// Provides enable/disable methods for different streaming topics such as
/// heartbeat, network, balances, orderbook, order status, swap status, and
/// transaction history.
class StreamingMethodsNamespace extends BaseRpcMethodNamespace {
  StreamingMethodsNamespace(super.client);

  /// Enable heartbeat stream
  Future<StreamEnableResponse> enableHeartbeat({
    int? clientId,
    StreamConfig? config,
    bool? alwaysSend,
    String? rpcPass,
  }) {
    return execute(
      StreamHeartbeatEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        clientId: clientId,
        config: config,
        alwaysSend: alwaysSend,
      ),
    );
  }

  /// Enable network stream
  Future<StreamEnableResponse> enableNetwork({
    int? clientId,
    StreamConfig? config,
    bool? alwaysSend,
    String? rpcPass,
  }) {
    return execute(
      StreamNetworkEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        clientId: clientId,
        config: config,
        alwaysSend: alwaysSend,
      ),
    );
  }

  /// Enable balance stream for coin
  Future<StreamEnableResponse> enableBalance({
    required String coin,
    int? clientId,
    StreamConfig? config,
    String? rpcPass,
  }) {
    return execute(
      StreamBalanceEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        clientId: clientId,
        config: config,
      ),
    );
  }

  /// Enable orderbook stream for pair
  Future<StreamEnableResponse> enableOrderbook({
    required String base,
    required String rel,
    int? clientId,
    String? rpcPass,
  }) {
    return execute(
      StreamOrderbookEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        clientId: clientId,
      ),
    );
  }

  /// Enable order status stream
  Future<StreamEnableResponse> enableOrderStatus({
    int? clientId,
    String? rpcPass,
  }) {
    return execute(
      StreamOrderStatusEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        clientId: clientId,
      ),
    );
  }

  /// Enable swap status stream
  Future<StreamEnableResponse> enableSwapStatus({
    int? clientId,
    String? rpcPass,
  }) {
    return execute(
      StreamSwapStatusEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        clientId: clientId,
      ),
    );
  }

  /// Enable transaction history stream for coin
  Future<StreamEnableResponse> enableTxHistory({
    required String coin,
    int? clientId,
    String? rpcPass,
  }) {
    return execute(
      StreamTxHistoryEnableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        clientId: clientId,
      ),
    );
  }

  /// Disable a previously enabled stream
  Future<StreamDisableResponse> disable({
    required int clientId,
    required String streamerId,
    String? rpcPass,
  }) {
    return execute(
      StreamDisableRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        clientId: clientId,
        streamerId: streamerId,
      ),
    );
  }
}
