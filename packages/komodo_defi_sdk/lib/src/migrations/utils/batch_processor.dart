import 'dart:async';

/// Generic batch processor for handling large collections in manageable chunks.
///
/// This utility helps process large lists of items (like assets) in batches
/// to avoid overwhelming system resources, API rate limits, or network capacity.
class BatchProcessor<T> {
  /// Creates a new [BatchProcessor] instance.
  ///
  /// The [batchSize] parameter controls how many items are processed in each batch.
  /// The [delayBetweenBatches] parameter adds a delay between batch processing
  /// to prevent overwhelming external services.
  const BatchProcessor({
    required this.batchSize,
    this.delayBetweenBatches = Duration.zero,
  });

  /// Maximum number of items to process in each batch.
  final int batchSize;

  /// Optional delay between processing batches.
  ///
  /// This can help prevent rate limiting or reduce load on external services.
  final Duration delayBetweenBatches;

  /// Processes a list of items in batches using the provided processor function.
  ///
  /// The [items] list is divided into batches of [batchSize], and each batch
  /// is processed using the [processor] function. Results from all batches
  /// are collected and returned as a single list.
  ///
  /// The [processor] function receives:
  /// - [batch]: The current batch of items to process
  /// - [batchIndex]: Zero-based index of the current batch
  /// - [totalBatches]: Total number of batches being processed
  ///
  /// If [delayBetweenBatches] is set, there will be a delay between each batch
  /// (except after the last batch).
  ///
  /// Example:
  /// ```dart
  /// final processor = BatchProcessor<String>(batchSize: 3);
  /// final results = await processor.processBatches(
  ///   ['a', 'b', 'c', 'd', 'e'],
  ///   (batch, index, total) async {
  ///     print('Processing batch $index/$total: $batch');
  ///     return batch.map((item) => item.toUpperCase()).toList();
  ///   },
  /// );
  /// // Results: ['A', 'B', 'C', 'D', 'E']
  /// ```
  Future<List<R>> processBatches<R>(
    List<T> items,
    Future<List<R>> Function(List<T> batch, int batchIndex, int totalBatches) processor,
  ) async {
    if (items.isEmpty) return <R>[];

    final batches = _createBatches(items);
    final results = <R>[];

    for (int i = 0; i < batches.length; i++) {
      final batch = batches[i];
      final batchResults = await processor(batch, i, batches.length);
      results.addAll(batchResults);

      // Add delay between batches (except after the last batch)
      if (i < batches.length - 1 && delayBetweenBatches > Duration.zero) {
        await Future.delayed(delayBetweenBatches);
      }
    }

    return results;
  }

  /// Processes a list of items in batches with progress reporting.
  ///
  /// Similar to [processBatches] but provides a stream of progress updates
  /// and results as each batch is completed.
  ///
  /// The stream emits [BatchProcessingResult] objects containing:
  /// - Current batch results
  /// - Progress information (completed/total batches)
  /// - Accumulated results from all completed batches
  ///
  /// Example:
  /// ```dart
  /// final processor = BatchProcessor<String>(batchSize: 2);
  /// await for (final progress in processor.processBatchesWithProgress(
  ///   ['a', 'b', 'c', 'd'],
  ///   (batch, index, total) async => batch.map((s) => s.toUpperCase()).toList(),
  /// )) {
  ///   print('Batch ${progress.completedBatches}/${progress.totalBatches} done');
  ///   print('Results so far: ${progress.allResults}');
  /// }
  /// ```
  Stream<BatchProcessingResult<R>> processBatchesWithProgress<R>(
    List<T> items,
    Future<List<R>> Function(List<T> batch, int batchIndex, int totalBatches) processor,
  ) async* {
    if (items.isEmpty) {
      yield BatchProcessingResult<R>(
        batchResults: <R>[],
        allResults: <R>[],
        completedBatches: 0,
        totalBatches: 0,
      );
      return;
    }

    final batches = _createBatches(items);
    final allResults = <R>[];

    for (int i = 0; i < batches.length; i++) {
      final batch = batches[i];
      final batchResults = await processor(batch, i, batches.length);
      allResults.addAll(batchResults);

      yield BatchProcessingResult<R>(
        batchResults: batchResults,
        allResults: List<R>.from(allResults),
        completedBatches: i + 1,
        totalBatches: batches.length,
      );

      // Add delay between batches (except after the last batch)
      if (i < batches.length - 1 && delayBetweenBatches > Duration.zero) {
        await Future.delayed(delayBetweenBatches);
      }
    }
  }

  /// Processes items in parallel batches up to a maximum concurrency limit.
  ///
  /// Unlike [processBatches] which processes batches sequentially, this method
  /// can process multiple batches concurrently up to [maxConcurrency].
  ///
  /// This is useful when the processor function involves I/O operations
  /// that can benefit from parallel execution.
  ///
  /// Example:
  /// ```dart
  /// final processor = BatchProcessor<String>(batchSize: 2);
  /// final results = await processor.processBatchesConcurrently(
  ///   ['a', 'b', 'c', 'd', 'e', 'f'],
  ///   maxConcurrency: 2,
  ///   (batch, index, total) async {
  ///     await Future.delayed(Duration(seconds: 1)); // Simulate I/O
  ///     return batch.map((item) => item.toUpperCase()).toList();
  ///   },
  /// );
  /// ```
  Future<List<R>> processBatchesConcurrently<R>(
    List<T> items,
    Future<List<R>> Function(List<T> batch, int batchIndex, int totalBatches) processor, {
    int maxConcurrency = 3,
  }) async {
    if (items.isEmpty) return <R>[];

    final batches = _createBatches(items);
    final results = <R>[];

    // Process batches in groups up to maxConcurrency
    for (int i = 0; i < batches.length; i += maxConcurrency) {
      final batchGroup = batches.skip(i).take(maxConcurrency);
      final futures = batchGroup.map((batch) {
        final batchIndex = batches.indexOf(batch);
        return processor(batch, batchIndex, batches.length);
      });

      final batchGroupResults = await Future.wait(futures);
      for (final batchResults in batchGroupResults) {
        results.addAll(batchResults);
      }

      // Add delay between batch groups (except after the last group)
      if (i + maxConcurrency < batches.length && delayBetweenBatches > Duration.zero) {
        await Future.delayed(delayBetweenBatches);
      }
    }

    return results;
  }

  /// Divides the input list into batches of the specified size.
  ///
  /// The last batch may contain fewer items than [batchSize] if the total
  /// number of items is not evenly divisible by the batch size.
  List<List<T>> _createBatches(List<T> items) {
    final batches = <List<T>>[];

    for (int i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      batches.add(items.sublist(i, end));
    }

    return batches;
  }

  /// Creates batches from a list and returns them without processing.
  ///
  /// This is useful when you need to get the batch structure without
  /// actually processing the items.
  List<List<T>> createBatches(List<T> items) => _createBatches(items);
}

/// Result of processing a single batch with progress information.
///
/// Contains the results from the current batch as well as accumulated
/// results from all completed batches and progress tracking.
class BatchProcessingResult<T> {
  /// Creates a new [BatchProcessingResult].
  const BatchProcessingResult({
    required this.batchResults,
    required this.allResults,
    required this.completedBatches,
    required this.totalBatches,
  });

  /// Results from processing the current batch.
  final List<T> batchResults;

  /// Accumulated results from all completed batches so far.
  final List<T> allResults;

  /// Number of batches completed so far.
  final int completedBatches;

  /// Total number of batches to process.
  final int totalBatches;

  /// Whether all batches have been completed.
  bool get isComplete => completedBatches >= totalBatches;

  /// Progress as a percentage (0.0 to 1.0).
  double get progress => totalBatches > 0 ? completedBatches / totalBatches : 1.0;

  @override
  String toString() {
    return 'BatchProcessingResult('
        'batchResults: ${batchResults.length} items, '
        'allResults: ${allResults.length} items, '
        'progress: $completedBatches/$totalBatches'
        ')';
  }
}
