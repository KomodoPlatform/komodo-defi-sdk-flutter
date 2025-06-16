import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base class for swap history strategies
abstract class SwapHistoryStrategy {
  /// Creates a new swap history strategy
  const SwapHistoryStrategy();

  /// Returns true if this strategy supports the given asset
  bool supportsAsset(Asset asset);

  /// Returns the set of supported pagination modes for this strategy
  Set<Type> get supportedPaginationModes;

  /// Fetches swap history using the appropriate API method
  Future<MyRecentSwapsResponse> fetchSwapHistory(
    ApiClient client,
    SwapHistoryPagination pagination, {
    String? myCoin,
    String? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  });

  /// Validates that the provided pagination mode is supported
  void validatePagination(SwapHistoryPagination pagination) {
    if (!supportedPaginationModes.contains(pagination.runtimeType)) {
      throw UnsupportedError(
        'Pagination mode ${pagination.runtimeType} not supported by '
        '$runtimeType',
      );
    }
  }
}

/// Factory for creating appropriate swap history strategies
class SwapHistoryStrategyFactory {
  /// Creates a new strategy factory with authentication context
  SwapHistoryStrategyFactory()
    : _strategies = [
        const V2SwapHistoryStrategy(),
        const LegacySwapHistoryStrategy(),
      ];

  final List<SwapHistoryStrategy> _strategies;

  /// Returns the appropriate strategy for the given asset
  SwapHistoryStrategy forAsset(Asset asset) {
    final strategy = _strategies.firstWhere(
      (strategy) => strategy.supportsAsset(asset),
      orElse:
          () =>
              throw UnsupportedError(
                'No strategy found for asset ${asset.id.id}',
              ),
    );

    return strategy;
  }

  /// Returns the most appropriate strategy for general use
  /// (not asset-specific)
  SwapHistoryStrategy get general => _strategies.first;
}

/// Strategy for fetching swap history using the v2 API
class V2SwapHistoryStrategy extends SwapHistoryStrategy {
  /// Creates a V2 swap history strategy with authentication context
  const V2SwapHistoryStrategy();

  @override
  Set<Type> get supportedPaginationModes => {
    PageBasedSwapPagination,
    UuidBasedSwapPagination,
  };

  @override
  Future<MyRecentSwapsResponse> fetchSwapHistory(
    ApiClient client,
    SwapHistoryPagination pagination, {
    String? myCoin,
    String? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  }) async {
    validatePagination(pagination);

    return switch (pagination) {
      final PageBasedSwapPagination p => client.rpc.swap.myRecentSwaps(
        myCoin: myCoin,
        otherCoin: otherCoin,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        limit: p.itemsPerPage,
        pageNumber: p.pageNumber,
      ),
      final UuidBasedSwapPagination u => client.rpc.swap.myRecentSwaps(
        myCoin: myCoin,
        otherCoin: otherCoin,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        fromUuid: u.fromUuid,
        limit: u.itemCount,
      ),
      _ =>
        throw UnsupportedError(
          'Pagination mode ${pagination.runtimeType} not supported',
        ),
    };
  }

  static const List<Type> _supportedProtocols = [
    UtxoProtocol,
    QtumProtocol,
    TendermintProtocol,
    Erc20Protocol,
  ];

  @override
  bool supportsAsset(Asset asset) =>
      _supportedProtocols.any((type) => asset.protocol.runtimeType == type);
}

/// Strategy for fetching swap history using the legacy API
class LegacySwapHistoryStrategy extends SwapHistoryStrategy {
  /// Creates a legacy swap history strategy
  const LegacySwapHistoryStrategy();

  @override
  Set<Type> get supportedPaginationModes => {
    PageBasedSwapPagination,
    UuidBasedSwapPagination,
  };

  @override
  Future<MyRecentSwapsResponse> fetchSwapHistory(
    ApiClient client,
    SwapHistoryPagination pagination, {
    String? myCoin,
    String? otherCoin,
    int? fromTimestamp,
    int? toTimestamp,
  }) async {
    validatePagination(pagination);

    return switch (pagination) {
      final PageBasedSwapPagination p => client.rpc.swap.myRecentSwaps(
        myCoin: myCoin,
        otherCoin: otherCoin,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        limit: p.itemsPerPage,
        pageNumber: p.pageNumber,
      ),
      final UuidBasedSwapPagination u => client.rpc.swap.myRecentSwaps(
        myCoin: myCoin,
        otherCoin: otherCoin,
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        fromUuid: u.fromUuid,
        limit: u.itemCount,
      ),
      _ =>
        throw UnsupportedError(
          'Pagination mode ${pagination.runtimeType} not supported',
        ),
    };
  }

  @override
  bool supportsAsset(Asset asset) => true; // Legacy supports all assets
}

/// Base class for swap history pagination
abstract class SwapHistoryPagination {
  /// Creates a new swap history pagination
  const SwapHistoryPagination();

  /// The maximum number of items to return
  int? get limit;
}

/// Page-based pagination for swap history
class PageBasedSwapPagination extends SwapHistoryPagination {
  /// Creates page-based pagination
  const PageBasedSwapPagination({
    required this.pageNumber,
    required this.itemsPerPage,
  });

  /// The page number to retrieve
  final int pageNumber;

  /// Number of items per page
  final int itemsPerPage;

  @override
  int get limit => itemsPerPage;
}

/// UUID-based pagination for swap history
class UuidBasedSwapPagination extends SwapHistoryPagination {
  /// Creates UUID-based pagination
  const UuidBasedSwapPagination({
    required this.fromUuid,
    required this.itemCount,
  });

  /// The UUID to start fetching from
  final String fromUuid;

  /// Number of items to fetch
  final int itemCount;

  @override
  int get limit => itemCount;
}
