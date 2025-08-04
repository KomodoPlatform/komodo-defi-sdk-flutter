import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

/// ZHTLC Transaction History Request
class ZCoinTxHistoryRequest
    extends BaseRequest<MyTxHistoryResponse, GeneralErrorResponse> {
  ZCoinTxHistoryRequest({
    required this.coin,
    this.limit = 10,
    this.pagingOptions,
    super.rpcPass,
  }) : super(method: 'z_coin_tx_history', mmrpc: RpcVersion.v2_0);

  final String coin;
  final int limit;
  final Pagination? pagingOptions;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {
      'coin': coin,
      'limit': limit,
      if (pagingOptions != null) 'paging_options': pagingOptions!.toJson(),
    },
  };

  @override
  MyTxHistoryResponse parse(Map<String, dynamic> json) =>
      MyTxHistoryResponse.parse(json);
}
