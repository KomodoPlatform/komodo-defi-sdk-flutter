import 'package:hive/hive.dart';

import '../persistence_provider.dart';

/// A [PersistenceProvider] that uses a Hive box as the underlying storage.
///
/// The type parameters are:
/// - `K`: The type of the primary key of the objects that the provider stores.
/// - `T`: The type of the objects that the provider stores. The objects must
/// implement the [ObjectWithPrimaryKey] interface.
class HiveBoxProvider<K, T extends ObjectWithPrimaryKey<K>>
    extends PersistenceProvider<K, T> {
  HiveBoxProvider({
    required this.name,
  });

  HiveBoxProvider.init({
    required this.name,
    required Box<T> box,
  }) : _box = box;

  final String name;
  Box<T>? _box;

  static Future<HiveBoxProvider<K, T>>
      create<K, T extends ObjectWithPrimaryKey<K>>({
    required String name,
  }) async {
    final Box<T> box = await Hive.openBox<T>(name);
    return HiveBoxProvider<K, T>.init(name: name, box: box);
  }

  @override
  Future<void> delete(K key) async {
    _box ??= await Hive.openBox<T>(name);
    await _box!.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    _box ??= await Hive.openBox<T>(name);
    await _box!.deleteAll(_box!.keys);
  }

  @override
  Future<T?> get(K key) async {
    _box ??= await Hive.openBox<T>(name);
    return _box!.get(key);
  }

  @override
  Future<List<T?>> getAll() async {
    _box ??= await Hive.openBox<T>(name);
    return _box!.values.toList();
  }

  @override
  Future<void> insert(T object) async {
    _box ??= await Hive.openBox<T>(name);
    await _box!.put(object.primaryKey, object);
  }

  @override
  Future<void> insertAll(List<T> objects) async {
    _box ??= await Hive.openBox<T>(name);

    final Map<K, T> map = <K, T>{};
    for (final T object in objects) {
      map[object.primaryKey] = object;
    }

    await _box!.putAll(map);
  }

  @override
  Future<void> update(T object) async {
    // Hive replaces the object if it already exists.
    await insert(object);
  }

  @override
  Future<void> updateAll(List<T> objects) async {
    await insertAll(objects);
  }

  @override
  Future<bool> exists() async {
    return Hive.boxExists(name);
  }

  @override
  Future<bool> containsKey(K key) async {
    _box ??= await Hive.openBox<T>(name);

    return _box!.containsKey(key);
  }
}
