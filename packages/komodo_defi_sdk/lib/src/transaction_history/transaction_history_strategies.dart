import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Factory for creating appropriate transaction history strategies
class TransactionHistoryStrategyFactory {
  static final List<TransactionHistoryStrategy> _strategies = [
    EtherscanTransactionStrategy(),
    const V2TransactionStrategy(),
    const LegacyTransactionStrategy(),
    const ZhtlcTransactionStrategy(),
  ];

  static TransactionHistoryStrategy forAsset(Asset asset) {
    final strategy = _strategies.firstWhere(
      (strategy) => strategy.supportsAsset(asset),
      orElse: () => throw UnsupportedError(
        'No strategy found for asset ${asset.id.id}',
      ),
    );

    return strategy;
  }
}

/// Strategy for fetching transaction history using the v2 API
class V2TransactionStrategy extends TransactionHistoryStrategy {
  const V2TransactionStrategy();

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

    return switch (pagination) {
      final PagePagination p => client.rpc.transactionHistory.myTxHistory(
          coin: asset.id.id,
          limit: p.itemsPerPage,
          pagingOptions: Pagination(pageNumber: p.pageNumber),
          target: HistoryTarget.accountId(0),
        ),
      final TransactionBasedPagination t =>
        client.rpc.transactionHistory.myTxHistory(
          coin: asset.id.id,
          limit: t.itemCount,
          pagingOptions: Pagination(fromId: int.parse(t.fromId)),
          target: HistoryTarget.accountId(0),
        ),
      _ => throw UnsupportedError(
          'Pagination mode ${pagination.runtimeType} not supported',
        ),
    };
  }

  static const List<Type> _supportedProtocols = [
    UtxoProtocol,
    QtumProtocol,
    TendermintProtocol,
  ];

  @override
  bool supportsAsset(Asset asset) =>
      _supportedProtocols.any((type) => asset.protocol.runtimeType == type);
}

/// Strategy for fetching transaction history using the legacy API
class LegacyTransactionStrategy extends TransactionHistoryStrategy {
  const LegacyTransactionStrategy();

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

    return switch (pagination) {
      final PagePagination p => client.rpc.transactionHistory.myTxHistoryLegacy(
          coin: asset.id.id,
          limit: p.itemsPerPage,
          pageNumber: p.pageNumber,
        ),
      final TransactionBasedPagination t =>
        client.rpc.transactionHistory.myTxHistoryLegacy(
          coin: asset.id.id,
          limit: t.itemCount,
          fromId: t.fromId,
        ),
      _ => throw UnsupportedError(
          'Pagination mode ${pagination.runtimeType} not supported',
        ),
    };
  }

  @override
  bool supportsAsset(Asset asset) => asset.protocol is! ZhtlcProtocol;
}

/// Strategy for fetching ZHTLC transaction history

///
