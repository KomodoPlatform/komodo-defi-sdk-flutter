import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ZhtlcTransactionStrategy extends TransactionHistoryStrategy {
  const ZhtlcTransactionStrategy();

  @override
  Set<Type> get supportedPaginationModes => {PagePagination};

  @override
  Future<TransactionPage> fetchTransactionHistory(
    ApiClient client,
    Asset asset,
    TransactionPagination pagination,
  ) async {
    validatePagination(pagination);

    if (pagination is! PagePagination) {
      throw UnsupportedError('ZHTLC only supports page-based pagination');
    }

    final response = client.rpc.transactionHistory.zCoinTxHistory(
      coin: asset.id.id,
      limit: pagination.itemsPerPage,
      pagingOptions: Pagination(pageNumber: pagination.pageNumber),
    );

    return TransactionPage(
      transactions:
          response.transactions
              .map((tx) => tx.asTransaction(asset.id))
              .toList(),
      total: response.total,
      nextPageId: response.fromId,
      currentPage: response.pageNumber ?? 1,
      totalPages: response.totalPages,
    );
  }

  @override
  bool supportsAsset(Asset asset) => asset.protocol is ZhtlcProtocol;
}
