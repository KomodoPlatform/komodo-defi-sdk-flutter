import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

class TransactionHistoryMethods extends BaseRpcMethodNamespace {
  TransactionHistoryMethods(super.client);

  /// Get transaction history using V2 API
  Future<MyTxHistoryResponse> myTxHistory({
    required String coin,
    int limit = 10,
    HistoryTarget? target,
    Pagination? pagingOptions,
  }) {
    return execute(
      MyTxHistoryRequest(
        coin: coin,
        limit: limit,
        historyTarget: target,
        pagingOptions: pagingOptions,
        rpcPass: rpcPass,
      ),
    );
  }

  /// Get transaction history using legacy API
  Future<MyTxHistoryResponse> myTxHistoryLegacy({
    required String coin,
    int limit = 10,
    String? fromId,
    bool max = false,
    int? pageNumber,
  }) {
    return execute(
      MyTxHistoryLegacyRequest(
        coin: coin,
        limit: limit,
        fromId: fromId,
        max: max,
        pageNumber: pageNumber,
        rpcPass: rpcPass,
      ),
    );
  }

  /// Get ZHTLC transaction history
  Future<MyTxHistoryResponse> zCoinTxHistory({
    required String coin,
    int limit = 10,
    Pagination? pagingOptions,
  }) {
    return execute(
      ZCoinTxHistoryRequest(
        coin: coin,
        limit: limit,
        pagingOptions: pagingOptions,
        rpcPass: rpcPass,
      ),
    );
  }
}
