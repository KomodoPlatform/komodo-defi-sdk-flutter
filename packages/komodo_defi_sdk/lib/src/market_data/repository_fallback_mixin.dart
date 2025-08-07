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

  // Conservative backoff strategy for fallback operations
  static final _fallbackBackoffStrategy = ExponentialBackoff(
    initialDelay: const Duration(milliseconds: 300),
    maxDelay: const Duration(seconds: 5),
    withJitter: true,
  );

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
      // Even when no healthy repos, still filter by support
      final supportingRepos = <CexRepository>[];
      for (final repo in priceRepositories) {
        try {
          if (await repo.supports(assetId, quoteCurrency, requestType)) {
            supportingRepos.add(repo);
          }
        } catch (e) {
          _logger.fine(
            'Error checking support for repository ${repo.runtimeType}: $e',
          );
          // Skip repositories that error on supports check
        }
      }
      return supportingRepos;
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

    // Order: primary first, then other healthy repos that support the asset,
    // then unhealthy repos that support the asset
    final orderedRepos = <CexRepository>[primaryRepo];

    // Add other healthy repositories that support the asset
    for (final repo in healthyRepos) {
      if (repo != primaryRepo) {
        try {
          if (await repo.supports(assetId, quoteCurrency, requestType)) {
            orderedRepos.add(repo);
          }
        } catch (e) {
          _logger.fine(
            'Error checking support for healthy repository ${repo.runtimeType}: $e',
          );
          // Skip repositories that error on supports check
        }
      }
    }

    // Add unhealthy repositories that support the asset as last resort
    for (final repo in priceRepositories) {
      if (!_isRepositoryHealthy(repo)) {
        try {
          if (await repo.supports(assetId, quoteCurrency, requestType)) {
            orderedRepos.add(repo);
          }
        } catch (e) {
          _logger.fine(
            'Error checking support for unhealthy repository ${repo.runtimeType}: $e',
          );
          // Skip repositories that error on supports check
        }
      }
    }

    return orderedRepos;
  }

  /// Generic method to try repositories in order until one succeeds
  /// Uses smart retry logic with maximum 3 total attempts across
  /// all repositories
  Future<T> tryRepositoriesInOrder<T>(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
    Future<T> Function(CexRepository repo) operation,
    String operationName, {
    int maxTotalAttempts = 3,
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
    var attemptCount = 0;

    // Smart retry logic: try each repository in order first, then retry
    // if needed
    // Example with 3 attempts and 2 repos: repo1, repo2, repo1
    for (var attempt = 0; attempt < maxTotalAttempts; attempt++) {
      final repositoryIndex = attempt % repositories.length;
      final repo = repositories[repositoryIndex];

      try {
        attemptCount++;
        _logger.finer(
          'Attempting $operationName for ${assetId.symbol.configSymbol} '
          'with repository ${repo.runtimeType} (attempt $attemptCount/$maxTotalAttempts)',
        );

        final result = await retry(
          () => operation(repo),
          maxAttempts: 1, // Single attempt per call, we handle retries here
          backoffStrategy: _fallbackBackoffStrategy,
        );

        _recordRepositorySuccess(repo);

        if (attemptCount > 1) {
          _logger.info(
            'Successfully fetched $operationName for ${assetId.symbol.configSymbol} '
            'using repository ${repo.runtimeType} on attempt $attemptCount',
          );
        }

        return result;
      } catch (e, s) {
        lastException = e is Exception ? e : Exception(e.toString());
        _recordRepositoryFailure(repo);
        _logger
          ..fine(
            'Repository ${repo.runtimeType} failed for $operationName '
            '${assetId.symbol.configSymbol} (attempt $attemptCount): $e',
          )
          ..finest('Stack trace: $s');
      }
    }

    // All attempts exhausted
    _logger.warning(
      'All $attemptCount attempts failed for $operationName '
      '${assetId.symbol.configSymbol}',
    );
    throw lastException ??
        Exception('All $maxTotalAttempts attempts failed for $operationName');
  }

  /// Tries repositories in order but returns null instead of
  /// throwing on failure
  Future<T?> tryRepositoriesInOrderMaybe<T>(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
    Future<T> Function(CexRepository repo) operation,
    String operationName, {
    int maxTotalAttempts = 3,
  }) async {
    try {
      return await tryRepositoriesInOrder(
        assetId,
        quoteCurrency,
        requestType,
        operation,
        operationName,
        maxTotalAttempts: maxTotalAttempts,
      );
    } catch (e, s) {
      _logger
        ..fine(
          'All attempts failed for $operationName '
          '${assetId.symbol.configSymbol}',
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
  // ignore: public_member_api_docs
  bool isRepositoryHealthyForTest(CexRepository repo) =>
      _isRepositoryHealthy(repo);

  @visibleForTesting
  // ignore: public_member_api_docs
  void recordRepositoryFailureForTest(CexRepository repo) =>
      _recordRepositoryFailure(repo);

  @visibleForTesting
  // ignore: public_member_api_docs
  void recordRepositorySuccessForTest(CexRepository repo) =>
      _recordRepositorySuccess(repo);
}
