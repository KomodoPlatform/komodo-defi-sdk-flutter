import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Mixin that provides repository fallback functionality for market data managers
mixin RepositoryFallbackMixin {
  static final _logger = Logger('RepositoryFallbackMixin');

  // Repository health tracking
  final Map<Type, DateTime> _repositoryFailures = {};
  final Map<Type, int> _repositoryFailureCounts = {};
  static const _repositoryBackoffDuration = Duration(minutes: 5);
  static const _maxFailureCount = 3;

  /// Must be implemented by the mixing class
  List<CexRepository> get priceRepositories;
  RepositorySelectionStrategy get selectionStrategy;

  /// Checks if a repository is healthy (not in backoff period)
  bool _isRepositoryHealthy(CexRepository repo) {
    final repoType = repo.runtimeType;
    final lastFailure = _repositoryFailures[repoType];
    final failureCount = _repositoryFailureCounts[repoType] ?? 0;

    if (lastFailure == null || failureCount < _maxFailureCount) {
      return true;
    }

    final backoffEnd = lastFailure.add(_repositoryBackoffDuration);
    final isHealthy = DateTime.now().isAfter(backoffEnd);

    if (isHealthy) {
      // Reset failure count after backoff period
      _repositoryFailureCounts[repoType] = 0;
      _repositoryFailures.remove(repoType);
    }

    return isHealthy;
  }

  /// Records a repository failure
  void _recordRepositoryFailure(CexRepository repo) {
    final repoType = repo.runtimeType;
    _repositoryFailures[repoType] = DateTime.now();
    _repositoryFailureCounts[repoType] =
        (_repositoryFailureCounts[repoType] ?? 0) + 1;

    _logger.info(
      'Repository ${repo.runtimeType} failure recorded '
      '(count: ${_repositoryFailureCounts[repoType]})',
    );
  }

  /// Records a repository success
  void _recordRepositorySuccess(CexRepository repo) {
    final repoType = repo.runtimeType;
    if (_repositoryFailureCounts.containsKey(repoType)) {
      _repositoryFailureCounts[repoType] = 0;
      _repositoryFailures.remove(repoType);
    }
  }

  /// Gets repositories ordered by health and preference
  Future<List<CexRepository>> _getHealthyRepositoriesInOrder(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
  ) async {
    // Filter healthy repositories
    final healthyRepos = priceRepositories.where(_isRepositoryHealthy).toList();

    if (healthyRepos.isEmpty) {
      _logger.warning(
        'No healthy repositories available, using all repositories',
      );
      return priceRepositories;
    }

    // Get primary repository from healthy ones
    final primaryRepo = await selectionStrategy.selectRepository(
      assetId: assetId,
      fiatCurrency: quoteCurrency,
      requestType: requestType,
      availableRepositories: healthyRepos,
    );

    if (primaryRepo == null) {
      // No repository supports this asset/currency combination
      return <CexRepository>[];
    }

    // Order: primary first, then other healthy repos, then unhealthy repos
    final orderedRepos = <CexRepository>[primaryRepo];

    // Add other healthy repositories
    for (final repo in healthyRepos) {
      if (repo != primaryRepo) {
        orderedRepos.add(repo);
      }
    }

    // Add unhealthy repositories as last resort
    for (final repo in priceRepositories) {
      if (!_isRepositoryHealthy(repo)) {
        orderedRepos.add(repo);
      }
    }

    return orderedRepos;
  }

  /// Generic method to try repositories in order until one succeeds
  Future<T> tryRepositoriesInOrder<T>(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
    Future<T> Function(CexRepository repo) operation,
    String operationName, {
    int maxAttemptsPerRepo = 2,
  }) async {
    final repositories = await _getHealthyRepositoriesInOrder(
      assetId,
      quoteCurrency,
      requestType,
    );

    if (repositories.isEmpty) {
      throw StateError(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for $operationName',
      );
    }

    Exception? lastException;

    for (int i = 0; i < repositories.length; i++) {
      final repo = repositories[i];
      try {
        _logger.finer(
          'Attempting $operationName for ${assetId.symbol.configSymbol} '
          'with repository ${repo.runtimeType} (attempt ${i + 1}/${repositories.length})',
        );

        final result = await retry(
          () => operation(repo),
          maxAttempts: maxAttemptsPerRepo,
        );

        _recordRepositorySuccess(repo);

        if (i > 0) {
          _logger.info(
            'Successfully fetched $operationName for ${assetId.symbol.configSymbol} '
            'using fallback repository ${repo.runtimeType}',
          );
        }

        return result;
      } catch (e, s) {
        lastException = e is Exception ? e : Exception(e.toString());
        _recordRepositoryFailure(repo);
        _logger
          ..fine(
            'Repository ${repo.runtimeType} failed for $operationName '
            '${assetId.symbol.configSymbol}: $e',
          )
          ..finest('Stack trace: $s');
      }
    }

    // All repositories failed
    _logger.warning(
      'All repositories failed for $operationName ${assetId.symbol.configSymbol}',
    );
    throw lastException ??
        Exception('All repositories failed for $operationName');
  }

  /// Tries repositories in order but returns null instead of throwing on failure
  Future<T?> tryRepositoriesInOrderMaybe<T>(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
    Future<T> Function(CexRepository repo) operation,
    String operationName, {
    int maxAttemptsPerRepo = 2,
  }) async {
    try {
      return await tryRepositoriesInOrder(
        assetId,
        quoteCurrency,
        requestType,
        operation,
        operationName,
        maxAttemptsPerRepo: maxAttemptsPerRepo,
      );
    } catch (e, s) {
      _logger
        ..fine(
          'All repositories failed for $operationName ${assetId.symbol.configSymbol}: $e',
        )
        ..finest('Stack trace: $s');
      return null;
    }
  }

  /// Clears repository health tracking data
  void clearRepositoryHealthData() {
    _repositoryFailures.clear();
    _repositoryFailureCounts.clear();
  }

  // Expose health tracking methods for testing
  @visibleForTesting
  bool isRepositoryHealthyForTest(CexRepository repo) =>
      _isRepositoryHealthy(repo);

  @visibleForTesting
  void recordRepositoryFailureForTest(CexRepository repo) =>
      _recordRepositoryFailure(repo);

  @visibleForTesting
  void recordRepositorySuccessForTest(CexRepository repo) =>
      _recordRepositorySuccess(repo);
}
