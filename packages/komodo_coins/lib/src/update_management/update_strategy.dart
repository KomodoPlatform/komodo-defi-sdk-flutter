import 'package:komodo_coin_updates/komodo_coin_updates.dart';

/// Enum for the type of update request
enum UpdateRequestType {
  backgroundUpdate,
  immediateUpdate,
  scheduledUpdate,
  forceUpdate
}

/// Result of an update operation
class UpdateResult {
  const UpdateResult({
    required this.success,
    required this.updatedAssetCount,
    this.newCommitHash,
    this.error,
    this.previousCommitHash,
  });

  final bool success;
  final int updatedAssetCount;
  final String? newCommitHash;
  final String? previousCommitHash;
  final Exception? error;

  bool get hasNewCommit =>
      newCommitHash != null && newCommitHash != previousCommitHash;
}

/// Strategy interface for managing coin configuration updates
abstract class UpdateStrategy {
  /// Determines whether an update should be performed
  Future<bool> shouldUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
    String? currentCommitHash,
    String? latestCommitHash,
    DateTime? lastUpdateTime,
  });

  /// Executes the update with the appropriate strategy
  Future<UpdateResult> executeUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
  });

  /// Gets the update interval for scheduled updates
  Duration get updateInterval;
}

/// Strategy that performs updates in the background without blocking
class BackgroundUpdateStrategy implements UpdateStrategy {
  const BackgroundUpdateStrategy({
    this.updateInterval = const Duration(hours: 6),
    this.maxRetryAttempts = 3,
  });

  @override
  final Duration updateInterval;
  final int maxRetryAttempts;

  @override
  Future<bool> shouldUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
    String? currentCommitHash,
    String? latestCommitHash,
    DateTime? lastUpdateTime,
  }) async {
    switch (requestType) {
      case UpdateRequestType.backgroundUpdate:
        // Check if enough time has passed since last update
        if (lastUpdateTime != null) {
          final timeSinceUpdate = DateTime.now().difference(lastUpdateTime);
          if (timeSinceUpdate < updateInterval) {
            return false;
          }
        }

        // Check if there's a newer commit available
        try {
          final isLatest = await repository.isLatestCommit();
          return !isLatest;
        } catch (_) {
          // If we can't check, don't update in background
          return false;
        }

      case UpdateRequestType.immediateUpdate:
      case UpdateRequestType.forceUpdate:
        return true;

      case UpdateRequestType.scheduledUpdate:
        // For scheduled updates, always check if we're behind
        try {
          return !(await repository.isLatestCommit());
        } catch (_) {
          return false;
        }
    }
  }

  @override
  Future<UpdateResult> executeUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
  }) async {
    try {
      final previousCommit = await repository.getCurrentCommit();

      await repository.updateCoinConfig();

      final newCommit = await repository.getCurrentCommit();
      final assets = await repository.getAssets();

      return UpdateResult(
        success: true,
        updatedAssetCount: assets.length,
        newCommitHash: newCommit,
        previousCommitHash: previousCommit,
      );
    } catch (e) {
      return UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

/// Strategy that performs immediate synchronous updates
class ImmediateUpdateStrategy implements UpdateStrategy {
  const ImmediateUpdateStrategy({
    this.updateInterval = const Duration(minutes: 30),
  });

  @override
  final Duration updateInterval;

  @override
  Future<bool> shouldUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
    String? currentCommitHash,
    String? latestCommitHash,
    DateTime? lastUpdateTime,
  }) async {
    // Immediate strategy always updates when requested
    switch (requestType) {
      case UpdateRequestType.immediateUpdate:
      case UpdateRequestType.forceUpdate:
        return true;
      case UpdateRequestType.backgroundUpdate:
      case UpdateRequestType.scheduledUpdate:
        // Check if we're behind the latest commit
        try {
          return !(await repository.isLatestCommit());
        } catch (_) {
          return false;
        }
    }
  }

  @override
  Future<UpdateResult> executeUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
  }) async {
    try {
      final previousCommit = await repository.getCurrentCommit();

      // Immediate strategy waits for completion
      await repository.updateCoinConfig();

      final newCommit = await repository.getCurrentCommit();
      final assets = await repository.getAssets();

      return UpdateResult(
        success: true,
        updatedAssetCount: assets.length,
        newCommitHash: newCommit,
        previousCommitHash: previousCommit,
      );
    } catch (e) {
      return UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

/// Strategy that disables all updates (useful for testing or offline mode)
class NoUpdateStrategy implements UpdateStrategy {
  NoUpdateStrategy();

  @override
  Duration get updateInterval => const Duration(days: 365); // Effectively never

  @override
  Future<bool> shouldUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
    String? currentCommitHash,
    String? latestCommitHash,
    DateTime? lastUpdateTime,
  }) async {
    // Only allow force updates
    return requestType == UpdateRequestType.forceUpdate;
  }

  @override
  Future<UpdateResult> executeUpdate({
    required UpdateRequestType requestType,
    required CoinConfigRepository repository,
  }) async {
    if (requestType != UpdateRequestType.forceUpdate) {
      return UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: Exception('Updates are disabled'),
      );
    }

    // Even for force updates, just return current state
    try {
      final currentCommit = await repository.getCurrentCommit();
      final assets = await repository.getAssets();

      return UpdateResult(
        success: true,
        updatedAssetCount: assets.length,
        newCommitHash: currentCommit,
        previousCommitHash: currentCommit,
      );
    } catch (e) {
      return UpdateResult(
        success: false,
        updatedAssetCount: 0,
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
