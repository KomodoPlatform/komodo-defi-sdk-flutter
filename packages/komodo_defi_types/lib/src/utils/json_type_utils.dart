import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

JsonMap jsonFromString(String json) {
  final decode = jsonDecode(json);

  assert(
    decode is JsonMap,
    'Tried to parse API response as a Map, but got a ${decode.runtimeType}',
  );

  return decode as JsonMap;
}

String jsonToString(dynamic json) => jsonEncode(json);

// Method to take a JSON map and list of keys to traverse and return the value
T _traverseJson<T>(
  JsonMap json,
  List<dynamic> keys, {
  T? defaultValue,
}) {
  dynamic value = json;

  for (final key in keys) {
    if (value is! JsonMap) {
      throw ArgumentError('Cannot traverse a non-Map value');
    }

    value = value[key];

    // TODO: Fuzzy-type matching for keys
  }

  if (value == null && defaultValue != null) {
    return defaultValue;
  }

  if (value != null && value is! T) {
    throw ArgumentError(
      'Traversed JSON and expected value of type $T, but got ${value.runtimeType}',
    );
  }

  return value as T;
}

extension JsonMapExtension<T extends JsonMap> on T {
  TVal nestedValue<TVal>(List<String> keys, {TVal? defaultValue}) =>
      _traverseJson<TVal>(this, keys, defaultValue: defaultValue);

  V value<V>(
    String key, [
    dynamic key2,
    dynamic key3,
    dynamic key4,
    dynamic key5,
  ]) {
    final keys = [key, key2, key3, key4, key5].whereType<String>().toList();
    return _traverseJson<V>(this, keys);
  }

  static JsonMap fromJsonString(String jsonString) =>
      jsonDecode(jsonString) as JsonMap;

  static JsonMap? fromJsonStringOrNull(String jsonString) {
    try {
      return fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(this);
}

extension ListExtensions<T extends JsonList> on T {
  String toJsonString() => jsonEncode(this);

  static JsonList fromJsonString(String jsonString) =>
      (jsonDecode(jsonString) as List).cast<JsonMap>();

  static JsonList? fromJsonStringOrNull(String jsonString) {
    try {
      return fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }
}

extension JsonMapCensoring<T extends JsonMap> on T {
  T censorKeys(
    List<String> keys, {
    bool recursive = true,
    String obscuringCharacter = '*',
    bool ensureJsonSerialization = true,
  }) {
    return censorMap(
      keys,
      recursive: recursive,
      obscuringCharacter: obscuringCharacter,
      ensureJsonSerialization: ensureJsonSerialization,
    ) as T;
  }
}

extension MapCensoring<K, V> on Map<K, V> {
  /// Searches for the keys in the map and replaces the values with the
  /// obscured character. If [recursive] is set to true, it will also search
  /// for the keys in nested maps or lists. Optionally, encodes and decodes
  /// the map to ensure it's fully serialized as JSON.
  Map<K, V> censorMap(
    List<K> keys, {
    bool recursive = true,
    String obscuringCharacter = '*',
    bool ensureJsonSerialization = false,
  }) {
    Map<K, V> targetMap = this;

    if (ensureJsonSerialization) {
      final jsonString = jsonEncode(targetMap);
      targetMap = jsonDecode(jsonString) as Map<K, V>;
    }

    final Map<K, V> censoredMap = {};
    final List<_CensorTask<K, V>> stack = [
      _CensorTask(targetMap, censoredMap),
    ];

    while (stack.isNotEmpty) {
      final currentTask = stack.removeLast();
      final currentMap = currentTask.sourceMap;
      final currentCensoredMap = currentTask.targetMap;

      currentMap.forEach((key, value) {
        if (keys.contains(key)) {
          if (value is String) {
            currentCensoredMap[key] = obscuringCharacter * value.length as V;
          } else if (value is num) {
            currentCensoredMap[key] =
                obscuringCharacter * value.toString().length as V;
          } else {
            currentCensoredMap[key] = obscuringCharacter as V;
          }
        } else if (recursive && value is Map) {
          final nestedCensoredMap = <K, V>{};
          currentCensoredMap[key] = nestedCensoredMap as V;
          stack.add(_CensorTask(value as Map<K, V>, nestedCensoredMap));
        } else if (recursive && value is List) {
          final censoredList = <V>[];
          currentCensoredMap[key] = censoredList as V;
          for (final element in value) {
            if (element is Map<K, V>) {
              final nestedCensoredMap = <K, V>{};
              censoredList.add(nestedCensoredMap as V);
              stack.add(_CensorTask(element, nestedCensoredMap));
            } else {
              censoredList.add(element as V);
            }
          }
        } else {
          currentCensoredMap[key] = value;
        }
      });
    }

    return censoredMap;
  }
}

class _CensorTask<K, V> {
  _CensorTask(this.sourceMap, this.targetMap);

  final Map<K, V> sourceMap;
  final Map<K, V> targetMap;
}
