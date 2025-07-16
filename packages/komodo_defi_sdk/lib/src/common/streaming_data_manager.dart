import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

/// Generic configuration for streaming data managers
class StreamingConfig {
  const StreamingConfig({
    this.pollingInterval = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.cacheExpiry = const Duration(minutes: 5),
  });

  final Duration pollingInterval;
  final int maxRetries;
  final Duration retryDelay;
  final Duration? cacheExpiry;
}

/// Represents a data source identifier
abstract class DataSourceId {
  const DataSourceId();
}

/// Base class for streaming data managers following SOLID principles
abstract class StreamingDataManager<TKey extends DataSourceId, TData> {
  StreamingDataManager({StreamingConfig? config})
    : _config = config ?? const StreamingConfig();

  final StreamingConfig _config;
  final _mutex = Mutex();

  // Stream management
  final Map<TKey, StreamController<TData>> _streamControllers = {};
  final Map<TKey, Timer> _pollingTimers = {};
  final Map<TKey, StreamSubscription<void>> _subscriptions = {};

  // Cache management
  final Map<TKey, TData> _cache = {};
  final Map<TKey, DateTime> _cacheTimestamps = {};
  Timer? _cacheCleanupTimer;

  // State management
  final Set<TKey> _activeStreams = {};
  bool _isDisposed = false;

  /// Initialize the manager
  @mustCallSuper
  Future<void> initialize() async {
    if (_config.cacheExpiry != null) {
      _cacheCleanupTimer = Timer.periodic(
        _config.cacheExpiry!,
        (_) => _cleanupExpiredCache(),
      );
    }
    await onInitialize();
  }

  /// Hook for subclasses to perform initialization
  @protected
  Future<void> onInitialize() async {}

  /// Get cached data if available and not expired
  @protected
  TData? getCached(TKey key) {
    if (!_cache.containsKey(key)) return null;

    if (_config.cacheExpiry != null) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) > _config.cacheExpiry!) {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
        return null;
      }
    }

    return _cache[key];
  }

  /// Update cache with new data
  @protected
  void updateCache(TKey key, TData data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Get data with optional caching
  Future<TData> getData(TKey key) async {
    _assertNotDisposed();

    final cached = getCached(key);
    if (cached != null) return cached;

    final data = await fetchData(key);
    updateCache(key, data);
    return data;
  }

  /// Watch data changes with automatic polling
  Stream<TData> watchData(TKey key) {
    _assertNotDisposed();

    return _mutex.protect(() {
      if (_streamControllers.containsKey(key)) {
        return _streamControllers[key]!.stream;
      }

      final controller = StreamController<TData>.broadcast(
        onListen: () => _startWatching(key),
        onCancel: () => _stopWatching(key),
      );

      _streamControllers[key] = controller;
      return controller.stream;
    });
  }

  /// Start watching data for a specific key
  Future<void> _startWatching(TKey key) async {
    await _mutex.protect(() async {
      if (_activeStreams.contains(key)) return;
      _activeStreams.add(key);

      final cached = getCached(key);
      if (cached != null) {
        _streamControllers[key]?.add(cached);
      }

      await _pollData(key);
      _pollingTimers[key] = Timer.periodic(
        _config.pollingInterval,
        (_) => _pollData(key),
      );
    });
  }

  /// Stop watching data for a specific key
  Future<void> _stopWatching(TKey key) async {
    await _mutex.protect(() async {
      if (!_activeStreams.contains(key)) return;

      _activeStreams.remove(key);
      _pollingTimers[key]?.cancel();
      _pollingTimers.remove(key);

      final controller = _streamControllers[key];
      if (controller != null && !controller.hasListener) {
        await controller.close();
        _streamControllers.remove(key);
      }
    });
  }

  /// Poll data with retry logic
  Future<void> _pollData(TKey key, [int retryCount = 0]) async {
    if (_isDisposed) return;

    try {
      final data = await fetchData(key);
      updateCache(key, data);

      final controller = _streamControllers[key];
      if (controller != null && !controller.isClosed) {
        controller.add(data);
      }
    } catch (error) {
      final controller = _streamControllers[key];

      if (retryCount < _config.maxRetries) {
        await Future.delayed(
          _config.retryDelay * (1 << retryCount),
          () => _pollData(key, retryCount + 1),
        );
      } else if (controller != null && !controller.isClosed) {
        controller.addError(error);
      }
    }
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    if (_config.cacheExpiry == null || _isDisposed) return;

    final now = DateTime.now();
    final keysToRemove = <TKey>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _config.cacheExpiry!) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Assert that the manager is not disposed
  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('${runtimeType} has been disposed');
    }
  }

  /// Abstract method to fetch data - must be implemented by subclasses
  @protected
  Future<TData> fetchData(TKey key);

  /// Dispose of all resources
  @mustCallSuper
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _mutex.protect(() async {
      _cacheCleanupTimer?.cancel();
      for (final timer in _pollingTimers.values) {
        timer.cancel();
      }
      _pollingTimers.clear();

      for (final subscription in _subscriptions.values) {
        await subscription.cancel();
      }
      _subscriptions.clear();

      for (final controller in _streamControllers.values) {
        await controller.close();
      }
      _streamControllers.clear();

      _cache.clear();
      _cacheTimestamps.clear();
      _activeStreams.clear();
    });

    await onDispose();
  }

  /// Hook for subclasses to perform cleanup
  @protected
  Future<void> onDispose() async {}
}

/// Mixin for managers that need to handle authentication state
mixin AuthAwareStreamingMixin<TKey extends DataSourceId, TData>
    on StreamingDataManager<TKey, TData> {
  StreamSubscription<dynamic>? _authSubscription;

  /// Set up auth state listener
  void setupAuthListener(Stream<dynamic> authStream) {
    _authSubscription = authStream.listen((user) {
      if (user == null) {
        onUserLoggedOut();
      } else {
        onUserLoggedIn(user);
      }
    });
  }

  /// Called when user logs out
  @protected
  void onUserLoggedOut() {
    final keys = List<TKey>.from(_activeStreams);
    for (final key in keys) {
      _stopWatching(key);
    }
  }

  /// Called when user logs in
  @protected
  void onUserLoggedIn(dynamic user) {
    // Subclasses can override to handle login
  }

  @override
  Future<void> onDispose() async {
    await _authSubscription?.cancel();
    await super.onDispose();
  }
}
