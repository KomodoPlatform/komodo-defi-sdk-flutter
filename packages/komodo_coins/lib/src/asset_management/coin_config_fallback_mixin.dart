import 'dart:async';

import 'package:komodo_coins/src/asset_management/loading_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:logging/logging.dart';

/// Mixin that provides fallback functionality for coin configuration managers
mixin CoinConfigFallbackMixin {
  static final _logger = Logger('CoinConfigFallbackMixin');

  // Source health tracking
  final Map<String, DateTime> _sourceFailures = {};
  final Map<String, int> _sourceFailureCounts = {};
  static const _sourceBackoffDuration = Duration(minutes: 10);
  static const _maxFailureCount = 3;

  // Conservative backoff strategy for fallback operations
  static final _fallbackBackoffStrategy = ExponentialBackoff(
    initialDelay: const Duration(milliseconds: 500),
    withJitter: true,
  );

  /// Must be implemented by the mixing class
  List<CoinConfigSource> get configSources;

  /// Must be implemented by the mixing class
  LoadingStrategy get loadingStrategy;

  /// Checks if a source is healthy (not in backoff period)
  bool _isSourceHealthy(CoinConfigSource source) {
    final sourceId = source.sourceId;
    final lastFailure = _sourceFailures[sourceId];
    final failureCount = _sourceFailureCounts[sourceId] ?? 0;

    if (lastFailure == null || failureCount < _maxFailureCount) {
      return true;
    }

    final backoffEnd = lastFailure.add(_sourceBackoffDuration);
    final isHealthy = DateTime.now().isAfter(backoffEnd);

    if (isHealthy) {
      // Reset failure count after backoff period
      _sourceFailureCounts[sourceId] = 0;
      _sourceFailures.remove(sourceId);
      _logger.fine('Source ${source.displayName} is healthy again');
    }

    return isHealthy;
  }

  /// Records a source failure
  void _recordSourceFailure(CoinConfigSource source) {
    final sourceId = source.sourceId;
    _sourceFailures[sourceId] = DateTime.now();
    _sourceFailureCounts[sourceId] = (_sourceFailureCounts[sourceId] ?? 0) + 1;

    final failureCount = _sourceFailureCounts[sourceId]!;
    _logger.warning(
      'Recorded failure for source ${source.displayName} '
      '($failureCount/$_maxFailureCount failures)',
    );
  }

  /// Records a source success
  void _recordSourceSuccess(CoinConfigSource source) {
    final sourceId = source.sourceId;
    if (_sourceFailureCounts.containsKey(sourceId)) {
      _sourceFailureCounts[sourceId] = 0;
      _sourceFailures.remove(sourceId);
      _logger.fine('Recorded success for source ${source.displayName}');
    }
  }

  /// Gets healthy sources in order based on the loading strategy
  Future<List<CoinConfigSource>> _getHealthySourcesInOrder(
    LoadingRequestType requestType,
  ) async {
    // Filter healthy sources
    final healthySources = configSources.where(_isSourceHealthy).toList();

    if (healthySources.isEmpty) {
      _logger.warning(
        'No healthy sources available, using all sources',
      );
      // Filter by availability when no healthy sources
      final availableSources = <CoinConfigSource>[];
      for (final source in configSources) {
        try {
          if (source.supports(requestType) && await source.isAvailable()) {
            availableSources.add(source);
          }
        } catch (e, s) {
          _logger.fine(
            'Error checking availability for source ${source.displayName}',
            e,
            s,
          );
        }
      }
      return availableSources;
    }

    // Use strategy to order sources
    final orderedSources = await loadingStrategy.selectSources(
      requestType: requestType,
      availableSources: healthySources,
    );

    return orderedSources;
  }

  /// Tries sources in order with fallback logic
  Future<T> trySourcesInOrder<T>(
    LoadingRequestType requestType,
    Future<T> Function(CoinConfigSource source) operation, {
    String? operationName,
    int maxTotalAttempts = 3,
  }) async {
    final sources = await _getHealthySourcesInOrder(
      requestType,
    );

    if (sources.isEmpty) {
      throw StateError(
        'No source supports $requestType for $operationName',
      );
    }

    Exception? lastException;
    var attemptCount = 0;

    // Smart retry logic: try each source in order first, then retry if needed
    // Example with 3 attempts and 2 sources: source1, source2, source1
    for (var attempt = 0; attempt < maxTotalAttempts; attempt++) {
      final sourceIndex = attempt % sources.length;
      final source = sources[sourceIndex];

      try {
        attemptCount++;
        _logger.finer(
          'Attempting $operationName with source ${source.displayName} '
          '(attempt $attemptCount/$maxTotalAttempts)',
        );

        final result = await retry(
          () => operation(source),
          maxAttempts: 1, // Single attempt per call, we handle retries here
          backoffStrategy: _fallbackBackoffStrategy,
        );

        _recordSourceSuccess(source);

        if (attemptCount > 1) {
          _logger.info(
            'Successfully executed $operationName '
            'using source ${source.displayName} on attempt $attemptCount',
          );
        }

        return result;
      } catch (e, s) {
        lastException = e is Exception ? e : Exception(e.toString());
        _recordSourceFailure(source);
        _logger
          ..fine(
            'Source ${source.displayName} failed for $operationName '
            '(attempt $attemptCount): $e',
          )
          ..finest('Stack trace: $s');
      }
    }

    // All attempts exhausted
    _logger.warning(
      'All sources failed for $operationName after $attemptCount attempts',
    );
    throw lastException ?? Exception('All sources failed');
  }

  /// Tries sources in order, returns null on failure instead of throwing
  Future<T?> trySourcesInOrderMaybe<T>(
    LoadingRequestType requestType,
    Future<T> Function(CoinConfigSource source) operation,
    String operationName, {
    int maxTotalAttempts = 3,
  }) async {
    try {
      return await trySourcesInOrder(
        requestType,
        operation,
        maxTotalAttempts: maxTotalAttempts,
        operationName: operationName,
      );
    } catch (e, s) {
      _logger.info('Failed to execute $operationName, returning null', e, s);
      return null;
    }
  }

  /// Clears all source health data
  void clearSourceHealthData() {
    _sourceFailures.clear();
    _sourceFailureCounts.clear();
    _logger.fine('Cleared source health data');
  }

  /// Gets the current health status of all sources
  Map<String, bool> getSourceHealthStatus() {
    final status = <String, bool>{};
    for (final source in configSources) {
      status[source.sourceId] = _isSourceHealthy(source);
    }
    return status;
  }

  /// Gets failure count for a specific source
  int getSourceFailureCount(String sourceId) {
    return _sourceFailureCounts[sourceId] ?? 0;
  }
}
