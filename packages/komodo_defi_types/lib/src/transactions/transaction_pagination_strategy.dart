/// Represents different ways to paginate transaction history
sealed class TransactionPagination {
  const TransactionPagination();

  /// Get the limit of transactions to return, if applicable
  int? get limit;
}

/// Standard page-based pagination
class PagePagination extends TransactionPagination {
  const PagePagination({
    required this.pageNumber,
    required this.itemsPerPage,
  });

  final int pageNumber;
  final int itemsPerPage;

  @override
  int get limit => itemsPerPage;
}

/// Pagination from a specific transaction ID
class TransactionBasedPagination extends TransactionPagination {
  const TransactionBasedPagination({
    required this.fromId,
    required this.itemCount,
  });

  final String fromId;
  final int itemCount;

  @override
  int get limit => itemCount;
}

/// Pagination by block range
class BlockRangePagination extends TransactionPagination {
  const BlockRangePagination({
    required this.fromBlock,
    required this.toBlock,
    this.maxItems,
  });

  final int fromBlock;
  final int toBlock;
  final int? maxItems;

  @override
  int? get limit => maxItems;
}

/// Pagination by timestamp range
class TimestampRangePagination extends TransactionPagination {
  const TimestampRangePagination({
    required this.fromTimestamp,
    required this.toTimestamp,
    this.maxItems,
  });

  final DateTime fromTimestamp;
  final DateTime toTimestamp;
  final int? maxItems;

  @override
  int? get limit => maxItems;
}

/// Contract-specific pagination (e.g., for ERC20 token transfers)
class ContractEventPagination extends TransactionPagination {
  const ContractEventPagination({
    required this.contractAddress,
    required this.fromBlock,
    this.toBlock,
    this.maxItems,
  });

  final String contractAddress;
  final int fromBlock;
  final int? toBlock;
  final int? maxItems;

  @override
  int? get limit => maxItems;
}
