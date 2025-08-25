import 'dart:async';

import 'package:test/test.dart';
import 'package:komodo_defi_sdk/src/migrations/utils/batch_processor.dart';

void main() {
  group('BatchProcessor Tests', () {
    group('Constructor and Configuration', () {
      test('should create BatchProcessor with specified batch size', () {
        // Arrange & Act
        const processor = BatchProcessor<String>(batchSize: 5);

        // Assert
        expect(processor.batchSize, equals(5));
        expect(processor.delayBetweenBatches, equals(Duration.zero));
      });

      test('should create BatchProcessor with delay between batches', () {
        // Arrange & Act
        const processor = BatchProcessor<String>(
          batchSize: 3,
          delayBetweenBatches: Duration(seconds: 1),
        );

        // Assert
        expect(processor.batchSize, equals(3));
        expect(processor.delayBetweenBatches, equals(Duration(seconds: 1)));
      });
    });

    group('Create Batches', () {
      test('should create correct batches for even division', () {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 3);
        final items = [1, 2, 3, 4, 5, 6];

        // Act
        final batches = processor.createBatches(items);

        // Assert
        expect(batches, hasLength(2));
        expect(batches[0], equals([1, 2, 3]));
        expect(batches[1], equals([4, 5, 6]));
      });

      test('should create correct batches for uneven division', () {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 4);
        final items = [1, 2, 3, 4, 5, 6, 7];

        // Act
        final batches = processor.createBatches(items);

        // Assert
        expect(batches, hasLength(2));
        expect(batches[0], equals([1, 2, 3, 4]));
        expect(batches[1], equals([5, 6, 7]));
      });

      test('should handle single batch case', () {
        // Arrange
        const processor = BatchProcessor<String>(batchSize: 10);
        final items = ['a', 'b', 'c'];

        // Act
        final batches = processor.createBatches(items);

        // Assert
        expect(batches, hasLength(1));
        expect(batches[0], equals(['a', 'b', 'c']));
      });

      test('should handle empty list', () {
        // Arrange
        const processor = BatchProcessor<String>(batchSize: 5);
        final items = <String>[];

        // Act
        final batches = processor.createBatches(items);

        // Assert
        expect(batches, isEmpty);
      });

      test('should handle single item', () {
        // Arrange
        const processor = BatchProcessor<String>(batchSize: 3);
        final items = ['single'];

        // Act
        final batches = processor.createBatches(items);

        // Assert
        expect(batches, hasLength(1));
        expect(batches[0], equals(['single']));
      });
    });

    group('Process Batches', () {
      test('should process all items in batches', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 2);
        final items = [1, 2, 3, 4, 5];
        final processedBatches = <List<int>>[];

        // Act
        final results = await processor.processBatches<String>(
          items,
          (batch, batchIndex, totalBatches) async {
            processedBatches.add(List<int>.from(batch));
            return batch.map((item) => 'processed_$item').toList();
          },
        );

        // Assert
        expect(results, hasLength(5));
        expect(results, equals(['processed_1', 'processed_2', 'processed_3', 'processed_4', 'processed_5']));
        expect(processedBatches, hasLength(3));
        expect(processedBatches[0], equals([1, 2]));
        expect(processedBatches[1], equals([3, 4]));
        expect(processedBatches[2], equals([5]));
      });

      test('should provide correct batch indices and total count', () async {
        // Arrange
        const processor = BatchProcessor<String>(batchSize: 2);
        final items = ['a', 'b', 'c', 'd'];
        final batchInfo = <Map<String, int>>[];

        // Act
        await processor.processBatches<String>(
          items,
          (batch, batchIndex, totalBatches) async {
            batchInfo.add({
              'batchIndex': batchIndex,
              'totalBatches': totalBatches,
              'batchSize': batch.length,
            });
            return batch;
          },
        );

        // Assert
        expect(batchInfo, hasLength(2));
        expect(batchInfo[0]['batchIndex'], equals(0));
        expect(batchInfo[0]['totalBatches'], equals(2));
        expect(batchInfo[0]['batchSize'], equals(2));
        expect(batchInfo[1]['batchIndex'], equals(1));
        expect(batchInfo[1]['totalBatches'], equals(2));
        expect(batchInfo[1]['batchSize'], equals(2));
      });

      test('should handle empty input list', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 3);
        final items = <int>[];

        // Act
        final results = await processor.processBatches<String>(
          items,
          (batch, batchIndex, totalBatches) async {
            return batch.map((item) => item.toString()).toList();
          },
        );

        // Assert
        expect(results, isEmpty);
      });

      test('should respect delay between batches', () async {
        // Arrange
        const processor = BatchProcessor<int>(
          batchSize: 1,
          delayBetweenBatches: Duration(milliseconds: 50),
        );
        final items = [1, 2, 3];
        final timestamps = <DateTime>[];

        // Act
        final stopwatch = Stopwatch()..start();
        await processor.processBatches<int>(
          items,
          (batch, batchIndex, totalBatches) async {
            timestamps.add(DateTime.now());
            return batch;
          },
        );
        stopwatch.stop();

        // Assert
        expect(timestamps, hasLength(3));
        expect(stopwatch.elapsedMilliseconds, greaterThan(90)); // At least 2 delays of 50ms
      });

      test('should not add delay after last batch', () async {
        // Arrange
        const processor = BatchProcessor<int>(
          batchSize: 2,
          delayBetweenBatches: Duration(milliseconds: 100),
        );
        final items = [1, 2];

        // Act
        final stopwatch = Stopwatch()..start();
        await processor.processBatches<int>(
          items,
          (batch, batchIndex, totalBatches) async => batch,
        );
        stopwatch.stop();

        // Assert - Should complete quickly since there's only one batch (no delay)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('Process Batches With Progress', () {
      test('should emit progress updates for each batch', () async {
        // Arrange
        const processor = BatchProcessor<String>(batchSize: 2);
        final items = ['a', 'b', 'c', 'd', 'e'];
        final progressUpdates = <BatchProcessingResult<String>>[];

        // Act
        await for (final progress in processor.processBatchesWithProgress<String>(
          items,
          (batch, batchIndex, totalBatches) async {
            return batch.map((item) => item.toUpperCase()).toList();
          },
        )) {
          progressUpdates.add(progress);
        }

        // Assert
        expect(progressUpdates, hasLength(3));

        // First batch
        expect(progressUpdates[0].completedBatches, equals(1));
        expect(progressUpdates[0].totalBatches, equals(3));
        expect(progressUpdates[0].batchResults, equals(['A', 'B']));
        expect(progressUpdates[0].allResults, equals(['A', 'B']));
        expect(progressUpdates[0].progress, equals(1.0 / 3.0));
        expect(progressUpdates[0].isComplete, isFalse);

        // Second batch
        expect(progressUpdates[1].completedBatches, equals(2));
        expect(progressUpdates[1].totalBatches, equals(3));
        expect(progressUpdates[1].batchResults, equals(['C', 'D']));
        expect(progressUpdates[1].allResults, equals(['A', 'B', 'C', 'D']));
        expect(progressUpdates[1].progress, equals(2.0 / 3.0));
        expect(progressUpdates[1].isComplete, isFalse);

        // Third batch
        expect(progressUpdates[2].completedBatches, equals(3));
        expect(progressUpdates[2].totalBatches, equals(3));
        expect(progressUpdates[2].batchResults, equals(['E']));
        expect(progressUpdates[2].allResults, equals(['A', 'B', 'C', 'D', 'E']));
        expect(progressUpdates[2].progress, equals(1.0));
        expect(progressUpdates[2].isComplete, isTrue);
      });

      test('should handle empty input list', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 3);
        final items = <int>[];
        final progressUpdates = <BatchProcessingResult<int>>[];

        // Act
        await for (final progress in processor.processBatchesWithProgress<int>(
          items,
          (batch, batchIndex, totalBatches) async => batch,
        )) {
          progressUpdates.add(progress);
        }

        // Assert
        expect(progressUpdates, hasLength(1));
        expect(progressUpdates[0].completedBatches, equals(0));
        expect(progressUpdates[0].totalBatches, equals(0));
        expect(progressUpdates[0].batchResults, isEmpty);
        expect(progressUpdates[0].allResults, isEmpty);
        expect(progressUpdates[0].isComplete, isTrue);
      });

      test('should maintain immutable results lists', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 2);
        final items = [1, 2, 3];
        final allResultsReferences = <List<int>>[];

        // Act
        await for (final progress in processor.processBatchesWithProgress<int>(
          items,
          (batch, batchIndex, totalBatches) async => batch,
        )) {
          allResultsReferences.add(progress.allResults);
        }

        // Assert - Each progress update should have independent list instances
        expect(allResultsReferences[0], equals([1, 2]));
        expect(allResultsReferences[1], equals([1, 2, 3]));

        // Modifying one shouldn't affect the other
        allResultsReferences[0].clear();
        expect(allResultsReferences[1], equals([1, 2, 3]));
      });
    });

    group('Process Batches Concurrently', () {
      test('should process multiple batches concurrently', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 2);
        final items = [1, 2, 3, 4, 5, 6];
        final processingOrder = <String>[];
        final completer = Completer<void>();
        var processedBatches = 0;

        // Act
        final results = await processor.processBatchesConcurrently<String>(
          items,
          (batch, batchIndex, totalBatches) async {
            processingOrder.add('start_batch_$batchIndex');

            // Simulate different processing times
            final delay = Duration(milliseconds: 50 * (3 - batchIndex)); // Reverse order delays
            await Future.delayed(delay);

            processingOrder.add('end_batch_$batchIndex');
            processedBatches++;

            if (processedBatches == totalBatches) {
              completer.complete();
            }

            return batch.map((item) => 'result_$item').toList();
          },
          maxConcurrency: 2,
        );

        await completer.future;

        // Assert
        expect(results, hasLength(6));
        expect(results, contains('result_1'));
        expect(results, contains('result_6'));

        // Should start multiple batches before any finish (concurrent execution)
        final startIndex0 = processingOrder.indexOf('start_batch_0');
        final startIndex1 = processingOrder.indexOf('start_batch_1');
        final endIndex0 = processingOrder.indexOf('end_batch_0');

        expect(startIndex0, greaterThanOrEqualTo(0));
        expect(startIndex1, greaterThanOrEqualTo(0));
        expect(startIndex1, lessThan(endIndex0)); // Batch 1 should start before batch 0 ends
      });

      test('should respect max concurrency limit', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 1);
        final items = [1, 2, 3, 4, 5];
        var maxConcurrentBatches = 0;
        var currentConcurrentBatches = 0;

        // Act
        await processor.processBatchesConcurrently<int>(
          items,
          (batch, batchIndex, totalBatches) async {
            currentConcurrentBatches++;
            maxConcurrentBatches =
                currentConcurrentBatches > maxConcurrentBatches
                    ? currentConcurrentBatches
                    : maxConcurrentBatches;

            await Future.delayed(Duration(milliseconds: 10));

            currentConcurrentBatches--;
            return batch;
          },
          maxConcurrency: 2,
        );

        // Assert
        expect(maxConcurrentBatches, lessThanOrEqualTo(2));
      });

      test('should handle single batch', () async {
        // Arrange
        const processor = BatchProcessor<String>(batchSize: 10);
        final items = ['a', 'b', 'c'];

        // Act
        final results = await processor.processBatchesConcurrently<String>(
          items,
          (batch, batchIndex, totalBatches) async {
            return batch.map((item) => item.toUpperCase()).toList();
          },
          maxConcurrency: 3,
        );

        // Assert
        expect(results, equals(['A', 'B', 'C']));
      });

      test('should handle empty input', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 5);
        final items = <int>[];

        // Act
        final results = await processor.processBatchesConcurrently<int>(
          items,
          (batch, batchIndex, totalBatches) async => batch,
          maxConcurrency: 2,
        );

        // Assert
        expect(results, isEmpty);
      });
    });

    group('BatchProcessingResult', () {
      test('should calculate progress correctly', () {
        // Arrange & Act
        const result1 = BatchProcessingResult<String>(
          batchResults: ['a'],
          allResults: ['a'],
          completedBatches: 1,
          totalBatches: 4,
        );

        const result2 = BatchProcessingResult<String>(
          batchResults: ['d'],
          allResults: ['a', 'b', 'c', 'd'],
          completedBatches: 4,
          totalBatches: 4,
        );

        const resultEmpty = BatchProcessingResult<String>(
          batchResults: [],
          allResults: [],
          completedBatches: 0,
          totalBatches: 0,
        );

        // Assert
        expect(result1.progress, equals(0.25));
        expect(result1.isComplete, isFalse);

        expect(result2.progress, equals(1.0));
        expect(result2.isComplete, isTrue);

        expect(resultEmpty.progress, equals(1.0));
        expect(resultEmpty.isComplete, isTrue);
      });

      test('should have meaningful toString representation', () {
        // Arrange & Act
        const result = BatchProcessingResult<int>(
          batchResults: [1, 2],
          allResults: [1, 2, 3, 4],
          completedBatches: 2,
          totalBatches: 3,
        );

        final stringRepresentation = result.toString();

        // Assert
        expect(stringRepresentation, contains('BatchProcessingResult('));
        expect(stringRepresentation, contains('batchResults: 2 items'));
        expect(stringRepresentation, contains('allResults: 4 items'));
        expect(stringRepresentation, contains('progress: 2/3'));
      });
    });

    group('Error Handling', () {
      test('should propagate errors from processor function', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 2);
        final items = [1, 2, 3, 4];

        // Act & Assert
        expect(
          () => processor.processBatches<int>(
            items,
            (batch, batchIndex, totalBatches) async {
              if (batchIndex == 1) {
                throw Exception('Processing error');
              }
              return batch;
            },
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should propagate errors in progress stream', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 1);
        final items = [1, 2];
        var errorCaught = false;

        // Act
        try {
          await for (final _ in processor.processBatchesWithProgress<int>(
            items,
            (batch, batchIndex, totalBatches) async {
              if (batchIndex == 1) {
                throw Exception('Processing error');
              }
              return batch;
            },
          )) {
            // Processing updates
          }
        } catch (e) {
          errorCaught = true;
          expect(e, isA<Exception>());
        }

        // Assert
        expect(errorCaught, isTrue);
      });

      test('should propagate errors in concurrent processing', () async {
        // Arrange
        const processor = BatchProcessor<int>(batchSize: 1);
        final items = [1, 2, 3];

        // Act & Assert
        expect(
          () => processor.processBatchesConcurrently<int>(
            items,
            (batch, batchIndex, totalBatches) async {
              if (batch.first == 2) {
                throw Exception('Concurrent processing error');
              }
              return batch;
            },
            maxConcurrency: 2,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
