import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// V2 Transaction History Request
class MyTxHistoryRequest
    extends BaseRequest<MyTxHistoryResponse, GeneralErrorResponse> {
  MyTxHistoryRequest({
    required this.coin,
    this.limit = 10,

    /// Required for HD wallets
    this.historyTarget,
    this.pagingOptions,
    super.rpcPass,
  }) : super(method: 'my_tx_history', mmrpc: '2.0');

  final String coin;
  final int limit;
  final HistoryTarget? historyTarget;
  final Pagination? pagingOptions;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'params': {
      'coin': coin,
      'limit': limit,
      if (historyTarget != null
          // Bug in the API, it doesn't accept IguanaHistoryTarget. It is
          // the default target, so we can just skip it.
          &&
          historyTarget is! IguanaHistoryTarget)
        'target': historyTarget!.toJson() ?? historyTarget!.value,
      if (pagingOptions != null) 'paging_options': pagingOptions!.toJson(),
    },
  };

  @override
  MyTxHistoryResponse parse(Map<String, dynamic> json) =>
      MyTxHistoryResponse.parse(json);
}

/// Legacy Transaction History Request
class MyTxHistoryLegacyRequest
    extends BaseRequest<MyTxHistoryResponse, GeneralErrorResponse> {
  MyTxHistoryLegacyRequest({
    required this.coin,
    this.limit = 10,
    this.fromId,
    this.max = false,
    this.pageNumber,
    super.rpcPass,
  }) : super(method: 'my_tx_history', mmrpc: null);

  final String coin;
  final int limit;
  final String? fromId;
  final bool max;
  final int? pageNumber;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'coin': coin,
    'limit': limit,
    if (fromId != null) 'from_id': fromId,
    'max': max,
    if (pageNumber != null) 'page_number': pageNumber,
    'target': {'type': 'account_id', 'id': 0},
  };

  @override
  MyTxHistoryResponse parse(Map<String, dynamic> json) =>
      MyTxHistoryResponse.parse(json);
}

/// Common Response for all Transaction History Requests
class MyTxHistoryResponse extends BaseResponse {
  MyTxHistoryResponse({
    required super.mmrpc,
    required this.currentBlock,
    required this.fromId,
    required this.limit,
    required this.skipped,
    required this.syncStatus,
    required this.total,
    required this.totalPages,
    required this.pageNumber,
    required this.transactions,
  });

  factory MyTxHistoryResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    return MyTxHistoryResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      currentBlock: result.value<int>('current_block'),
      fromId: result.valueOrNull<String>('from_id'),
      limit: result.value<int>('limit'),
      skipped: result.value<int>('skipped'),
      syncStatus: SyncStatusResponse.fromJson(
        result.value<JsonMap>('sync_status'),
      ),
      total: result.value<int>('total'),
      totalPages: result.value<int>('total_pages'),
      pageNumber: result.valueOrNull<int>('page_number'),
      transactions:
          result
              .value<List<dynamic>>('transactions')
              .map((e) => TransactionInfo.fromJson(e as JsonMap))
              .toList(),
    );
  }

  factory MyTxHistoryResponse.empty() => MyTxHistoryResponse(
    mmrpc: '2.0',
    currentBlock: 0,
    fromId: null,
    limit: 0,
    skipped: 0,
    syncStatus: SyncStatusResponse(state: TransactionSyncStatusEnum.finished),
    total: 0,
    totalPages: 0,
    pageNumber: null,
    transactions: const [],
  );

  final int currentBlock;
  final String? fromId;
  final int limit;
  final int skipped;
  final SyncStatusResponse syncStatus;
  final int total;
  final int totalPages;
  final int? pageNumber;
  final List<TransactionInfo> transactions;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'current_block': currentBlock,
      if (fromId != null) 'from_id': fromId,
      'limit': limit,
      'skipped': skipped,
      'sync_status': syncStatus.toJson(),
      'total': total,
      'total_pages': totalPages,
      if (pageNumber != null) 'page_number': pageNumber,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
    },
  };
}
