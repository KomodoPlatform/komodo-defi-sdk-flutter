import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/hive/hive_adapters.dart';
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';

class _FakeHive implements HiveInterface {
  final List<TypeAdapter<dynamic>> _registered = [];
  @override
  bool isAdapterRegistered(int typeId) {
    return _registered.any((a) => a.typeId == typeId);
  }

  @override
  void registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool internal = false,
    bool override = false,
  }) {
    _registered.add(adapter);
  }

  // Unused members for these tests
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeIsolatedHive implements IsolatedHiveInterface {
  final List<TypeAdapter<dynamic>> _registered = [];
  @override
  bool isAdapterRegistered(int typeId) {
    return _registered.any((a) => a.typeId == typeId);
  }

  @override
  void registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool internal = false,
    bool override = false,
  }) {
    _registered.add(adapter);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('HiveRegistrar.registerAdapters is idempotent', () {
    final fake = _FakeHive();
    fake.registerAdapters();
    final initial = fake._registered.length;
    fake.registerAdapters();
    expect(fake._registered.length, initial);
    expect(fake.isAdapterRegistered(AssetAdapter().typeId), isTrue);
  });

  test('IsolatedHiveRegistrar.registerAdapters is idempotent', () {
    final fake = _FakeIsolatedHive();
    fake.registerAdapters();
    final initial = fake._registered.length;
    fake.registerAdapters();
    expect(fake._registered.length, initial);
    expect(fake.isAdapterRegistered(AssetAdapter().typeId), isTrue);
  });
}
