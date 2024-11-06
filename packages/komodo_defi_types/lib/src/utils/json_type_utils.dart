import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;

JsonMap jsonFromString(String json) {
  final decode = jsonDecode(json);

  assert(
    decode is JsonMap,
    'Tried to parse API response as a Map, but got a ${decode.runtimeType}',
  );

  return decode as JsonMap;
}

JsonMap? tryParseJson(String json) {
  try {
    return jsonFromString(json);
  } catch (e) {
    return null;
  }
}

List<JsonMap> jsonListFromString(String json) {
  final decode = jsonDecode(json);

  assert(
    decode is List,
    'Tried to parse API response as a List, but got a ${decode.runtimeType}',
  );

  return (decode as List).cast<JsonMap>();
}

String jsonToString(dynamic json) => jsonEncode(json);

/// Method to take a JSON map and list of keys to traverse and return the value
T? _traverseJson<T>(
  dynamic json,
  List<dynamic> keys, {
  T? defaultValue,
  bool lossyCast = false,
  bool nullIfAbsent = false,
}) {
  assert(
    !(defaultValue != null && nullIfAbsent),
    'Cannot provide a default value if nullIfAbsent is true',
  );

  dynamic value = json;

  for (var i = 0; i < keys.length; i++) {
    final key = keys[i];
    final isLast = i == keys.length - 1;

    if (value is! Map) {
      // if (value is! Map && !isLast) {
      if (nullIfAbsent) {
        return null;
      }

      throw ArgumentError('Cannot traverse a non-Map value');
    }

    if (value.containsKey(key) == false) {
      if (nullIfAbsent) {
        return null;
      }
      if (T == dynamic || T == Null) {
        return null; // Return null for nullable types //TODO! Fix or remove
      }
      // Check if T is nullable and return null if the key is not found
      if (defaultValue != null) {
        return defaultValue;
      }
      throw ArgumentError('Key "$key" not found in Map');
    }

    value = value[key];
  }

  if (value == null && defaultValue != null) {
    return defaultValue;
  }

  if (T == num && value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) {
      return parsed as T;
    }
  }

  // Whether to do casts that may result in data loss, such as casting a number
  // to a string.
  if (lossyCast && T == String && value is num) {
    return value.toString() as T;
  }

  if (T == JsonMap && value is String) {
    return jsonFromString(value) as T;
  }

  if (T == String && value is JsonMap) {
    return jsonToString(value) as T;
  }

  if (T == JsonList && value is String) {
    return jsonListFromString(value) as T;
  }

  if (T == JsonList && value is List && value is! JsonList) {
    // ignore: unnecessary_cast
    return (value as List).cast<JsonMap>() as T;
  }

  // Handle map type conversion
  if (T != dynamic && value is Map && T.toString().startsWith('Map<')) {
    try {
      // Attempt to convert the map to the expected type
      return _convertMap(value);
    } catch (e) {
      throw ArgumentError(
        'Failed to convert map to expected type $T: $e',
      );
    }
  }

  if (value != null && value is! T) {
    throw ArgumentError(
      'Traversed JSON and expected value of type $T for ${keys.last}, '
      'but got ${value.runtimeType}',
    );
  }

  return value as T;
}

// Helper method to handle lists that might contain maps
dynamic _convertList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) {
      return _convertMap<Map<String, dynamic>>(item);
    } else if (item is List) {
      return _convertList(item);
    }
    return item;
  }).toList();
}

T _convertMap<T>(Map<dynamic, dynamic> sourceMap) {
  // First, sanitize the map to ensure all keys are strings
  final sanitizedMap = <String, dynamic>{};
  sourceMap.forEach((key, value) {
    final stringKey = key?.toString() ?? '';
    if (value is Map) {
      // Recursively convert nested maps
      sanitizedMap[stringKey] = _convertMap<Map<String, dynamic>>(value);
    } else if (value is List) {
      // Handle lists and convert any maps within them
      sanitizedMap[stringKey] = _convertList(value);
    } else {
      sanitizedMap[stringKey] = value;
    }
  });

  if (T is JsonMap || T is Map<String, dynamic> || T is Map<String, dynamic>?) {
    return sanitizedMap as T;
  } else if ((T is Map<String, Object?>) || (T is Map<String, Object?>?)) {
    return Map<String, Object?>.from(sanitizedMap) as T;
  }

  try {
    return sanitizedMap as T;
  } catch (e) {
    throw ArgumentError(
      'Failed to convert map to expected type $T: $e',
    );
  }
}

extension JsonMapExtension<T extends JsonMap> on T {
  TVal? valueVArgs<TVal>(List<String> keys, {TVal? defaultValue}) =>
      _traverseJson<TVal?>(this, keys, defaultValue: defaultValue);

  V value<V>(
    String key1, [
    String? key2,
    String? key3,
    String? key4,
    String? key5,
  ]) {
    final keys = [key1, key2, key3, key4, key5].whereType<String>().toList();
    return _traverseJson<V>(this, keys) as V;
  }

  V? valueOrNull<V>(
    String key1, [
    String? key2,
    String? key3,
    String? key4,
    String? key5,
  ]) {
    final keys = [key1, key2, key3, key4, key5].whereType<String>().toList();
    return _traverseJson<V>(this, keys, nullIfAbsent: true);
  }

  static JsonMap jsonFromString(String json) {
    final decode = jsonDecode(json);

    if (decode is Map) {
      // Ensure all keys are strings and the value is dynamic
      return decode.map((key, value) => MapEntry(key.toString(), value));
    } else {
      throw ArgumentError(
        'Tried to parse API response as a Map, but got a ${decode.runtimeType}',
      );
    }
  }

  static JsonMap? tryParseJson(String json) {
    try {
      return jsonFromString(json);
    } catch (e) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(this);

  void setIfAbsentOrEmpty(String key, dynamic value) {
    if (!containsKey(key) || this[key] == '') {
      this[key] = value;
    }
  }

  // Ensure the entire map has been serialized to JSON types and that no
  // non-serializable types are present
  JsonMap ensureJson() {
    return jsonFromString(jsonEncode(this));
  }
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

extension JsonMapCensoring<T extends Map<dynamic, dynamic>> on T {
  T censorKeys(
    List<String> keys, {
    bool recursive = true,
    String obscuringCharacter = '*',
    bool ensureJsonSerialization = true,
  }) {
    final censoredMap = censorMap(
      keys,
      recursive: recursive,
      obscuringCharacter: obscuringCharacter,
      ensureJsonSerialization: ensureJsonSerialization,
    );

    // Safely cast censoredMap back to T by ensuring type conformity
    return Map<String, dynamic>.from(censoredMap) as T;
  }
}

extension JsonMapDeepMerge on JsonMap {
  JsonMap deepMerge(JsonMap other) {
    final mergedMap = JsonMap.from(this);

    other.forEach((key, value) {
      if (value is JsonMap && containsKey(key) && this[key] is JsonMap) {
        mergedMap[key] = (this[key] as JsonMap).deepMerge(value);
      } else {
        mergedMap[key] = value;
      }
    });

    return mergedMap;
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
    var targetMap = this;

    if (ensureJsonSerialization) {
      final jsonString = jsonEncode(targetMap);
      targetMap = jsonDecode(jsonString) as Map<K, V>;
    }

    final censoredMap = <K, V>{};
    final stack = <_CensorTask<K, V>>[
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
        } else if (recursive && value is Iterable) {
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

// Extension on String/String? to make null if empty
extension StringNullIfNullOrEmpty on String? {
  String? get nullIfEmpty => this?.isEmpty == true ? null : this;
}
