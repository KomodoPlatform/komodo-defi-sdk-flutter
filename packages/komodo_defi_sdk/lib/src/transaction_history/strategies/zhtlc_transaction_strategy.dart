import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ZhtlcTransactionStrategy extends TransactionHistoryStrategy {
  const ZhtlcTransactionStrategy();

  @override
  Set<Type> get supportedPaginationModes => {
    PagePagination,
    TransactionBasedPagination,
  };

  @override
  Future<MyTxHistoryResponse> fetchTransactionHistory(
    ApiClient client,
    Asset asset,
    TransactionPagination pagination,
  ) async {
    validatePagination(pagination);

    final ({int limit, Pagination pagingOptions}) requestParams =
        switch (pagination) {
          final PagePagination p => (
            limit: p.itemsPerPage,
            pagingOptions: Pagination(pageNumber: p.pageNumber),
          ),
          final TransactionBasedPagination t => (
            limit: t.itemCount,
            pagingOptions: Pagination(fromId: t.fromId),
          ),
          _ => throw UnsupportedError(
            'Pagination mode ${pagination.runtimeType} not supported',
          ),
        };

    return client.rpc.transactionHistory.zCoinTxHistory(
      coin: asset.id.id,
      limit: requestParams.limit,
      pagingOptions: requestParams.pagingOptions,
    );
  }

  @override
  bool supportsAsset(Asset asset) => asset.protocol is ZhtlcProtocol;

  @override
  bool requiresKdfTransactionHistory(Asset asset) => true;
}
