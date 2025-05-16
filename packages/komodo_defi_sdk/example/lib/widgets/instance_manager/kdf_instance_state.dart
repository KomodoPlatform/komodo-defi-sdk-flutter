import 'package:flutter/material.dart';
import 'package:kdf_sdk_example/main.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

class KdfInstanceState {
  KdfInstanceState({
    required this.name,
    required this.config,
    required this.sdk,
    required this.instanceData,
    this.isConnected = false,
    this.error,
  });

  final String name;
  final KomodoDefiSdkConfig config;
  final KomodoDefiSdk sdk;
  final InstanceState instanceData;
  final bool isConnected;
  final String? error;

  KdfInstanceState copyWith({
    String? name,
    KomodoDefiSdkConfig? config,
    KomodoDefiSdk? sdk,
    bool? isConnected,
    String? error,
    InstanceState? instanceData,
  }) {
    return KdfInstanceState(
      name: name ?? this.name,
      config: config ?? this.config,
      sdk: sdk ?? this.sdk,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
      instanceData: instanceData ?? this.instanceData,
    );
  }
}

/// Manages multiple KDF instances
class KdfInstanceManager extends ChangeNotifier {
  final Map<String, KdfInstanceState> _instances = {};

  /// Get all instances
  Map<String, KdfInstanceState> get instances => Map.unmodifiable(_instances);

  /// Get a specific instance by name
  KdfInstanceState? getInstance(String name) => _instances[name];

  /// Register a new instance
  Future<void> registerInstance(
    String name,
    KomodoDefiSdkConfig config,
    KomodoDefiSdk sdk,
  ) async {
    if (_instances.containsKey(name)) {
      throw StateError('Instance with name $name already exists');
    }

    _instances[name] = KdfInstanceState(
      name: name,
      config: config,
      sdk: sdk,
      instanceData: InstanceState(),
    );
    notifyListeners();

    try {
      await sdk.initialize();
      _instances[name] = _instances[name]!.copyWith(isConnected: true);
      notifyListeners();
    } catch (e) {
      _instances[name] = _instances[name]!.copyWith(
        isConnected: false,
        error: e.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }

  /// Reconnect an instance
  Future<void> reconnectInstance(String name) async {
    final instance = _instances[name];
    if (instance == null) return;

    try {
      await instance.sdk.initialize();
      _instances[name] = instance.copyWith(isConnected: true);
      notifyListeners();
    } catch (e) {
      _instances[name] = instance.copyWith(
        isConnected: false,
        error: e.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }

  /// Remove an instance
  Future<void> removeInstance(String name) async {
    final instance = _instances[name];
    if (instance == null) return;

    await instance.sdk.dispose();
    _instances.remove(name);
    notifyListeners();
  }

  /// Get all connected instances
  Iterable<KdfInstanceState> get connectedInstances =>
      _instances.values.where((instance) => instance.isConnected);

  /// Get all instances in error state
  Iterable<KdfInstanceState> get errorInstances =>
      _instances.values.where((instance) => instance.error != null);

  /// Check if an instance exists
  bool hasInstance(String name) => _instances.containsKey(name);

  /// Check if an instance is connected
  bool isInstanceConnected(String name) =>
      _instances[name]?.isConnected ?? false;

  @override
  Future<void> dispose() async {
    for (final instance in _instances.values) {
      await instance.sdk.dispose();
    }
    _instances.clear();
    super.dispose();
  }
}

/// Provider widget for KdfInstanceManager
class KdfInstanceManagerProvider extends InheritedNotifier<KdfInstanceManager> {
  const KdfInstanceManagerProvider({
    required super.child,
    required KdfInstanceManager notifier,
    super.key,
  }) : super(notifier: notifier);

  static KdfInstanceManager of(BuildContext context) {
    final provider =
        context
            .dependOnInheritedWidgetOfExactType<KdfInstanceManagerProvider>();
    if (provider == null) {
      throw StateError('No KdfInstanceManagerProvider found in context');
    }
    return provider.notifier!;
  }
}
