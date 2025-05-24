/// A generic interface for objects that have a primary key.
///
/// This interface is used to define the primary key of objects that are stored
/// in a persistence provider. The primary key is used to uniquely identify the
/// object.
///
/// The type parameter `T` is the type of the primary key.
abstract class ObjectWithPrimaryKey<T> {
  T get primaryKey;
}

typedef TableWithStringPK = ObjectWithPrimaryKey<String>;
typedef TableWithIntPK = ObjectWithPrimaryKey<int>;
typedef TableWithDoublePK = ObjectWithPrimaryKey<double>;

/// A generic interface for a persistence provider.
///
/// This interface defines the basic CRUD operations that a persistence provider
/// should implement. The operations are asynchronous and return a [Future].
///
/// The type parameters are:
/// - `K`: The type of the primary key of the objects that the provider stores.
/// - `T`: The type of the objects that the provider stores. The objects must
///  implement the [ObjectWithPrimaryKey] interface.
abstract class PersistenceProvider<K, T extends ObjectWithPrimaryKey<K>> {
  Future<T?> get(K key);
  Future<List<T?>> getAll();
  Future<bool> containsKey(K key);
  Future<void> insert(T object);
  Future<void> insertAll(List<T> objects);
  Future<void> update(T object);
  Future<void> updateAll(List<T> objects);
  Future<void> delete(K key);
  Future<void> deleteAll();
  Future<bool> exists();
}
