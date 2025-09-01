import 'dart:async';

import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

abstract class KeyValueStore {
  Future<JsonMap?> get(String key);
  Future<void> set(String key, JsonMap value);
}

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, JsonMap> _store = {};

  @override
  Future<JsonMap?> get(String key) async => _store[key];

  @override
  Future<void> set(String key, JsonMap value) async {
    _store[key] = value;
  }
}

