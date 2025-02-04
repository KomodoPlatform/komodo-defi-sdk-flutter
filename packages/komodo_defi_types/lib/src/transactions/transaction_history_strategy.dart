import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base interface for transaction history strategies

abstract class TransactionHistoryStrategy {
  const TransactionHistoryStrategy();

  /// Get supported pagination modes for this strategy
  Set<Type> get supportedPaginationModes;

  /// Fetch transaction history with the specified pagination mode
  Future<MyTxHistoryResponse> fetchTransactionHistory(
    ApiClient client,
    Asset asset,
    TransactionPagination pagination,
    // {required HistoryTarget? target,}
  );

  /// Whether this strategy supports the given asset
  bool supportsAsset(Asset asset);

  /// Whether this strategy supports the given pagination mode
  bool supportsPaginationMode(Type paginationType) {
    return supportedPaginationModes.contains(paginationType);
  }

  /// Validates that the given pagination mode is supported by this strategy
  /// Throws UnsupportedError if not supported
  void validatePagination(TransactionPagination pagination) {
    if (!supportsPaginationMode(pagination.runtimeType)) {
      throw UnsupportedError(
        'Pagination mode ${pagination.runtimeType} is not supported by '
        '$runtimeType. Supported modes: $supportedPaginationModes',
      );
    }
  }

  /// Helper method to convert legacy pagination parameters to TransactionPagination
  TransactionPagination _getLegacyPagination({
    String? fromId,
    int? pageNumber,
    int limit = 10,
  }) {
    if (fromId != null) {
      return TransactionBasedPagination(
        fromId: fromId,
        itemCount: limit,
      );
    }
    return PagePagination(
      pageNumber: pageNumber ?? 1,
      itemsPerPage: limit,
    );
  }
}
