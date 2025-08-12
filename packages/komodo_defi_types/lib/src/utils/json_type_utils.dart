import 'dart:convert';

import 'package:decimal/decimal.dart';

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
    final decoded = jsonDecode(json);
    if (decoded is! JsonMap) {
      return null;
    }
    return decoded;
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
    if (value is! Map) {
      if (nullIfAbsent) return null;
      throw ArgumentError('Cannot traverse a non-Map value');
    }

    if (value.containsKey(key) == false) {
      if (nullIfAbsent) return null;
      if (T == dynamic || T == Null) return null;
      if (defaultValue != null) return defaultValue;
      throw ArgumentError('Key "$key" not found in Map');
    }

    value = value[key];
  }

  if (value == null && defaultValue != null) {
    return defaultValue;
  }

  // Handle various type conversions
  try {
    if (value != null) {
      // Handle List<String> and other list types
      if (T.toString().startsWith('List<') && value is List) {
        final genericType = T.toString().substring(5, T.toString().length - 1);
        switch (genericType) {
          case 'String':
            return value.cast<String>() as T;
          case 'int':
            return value.cast<int>() as T;
          case 'double':
            return value.cast<double>() as T;
          case 'num':
            return value.cast<num>() as T;
          case 'bool':
            return value.cast<bool>() as T;
          default:
            if (genericType == 'JsonMap' || genericType == 'JsonMap') {
              return value.cast<JsonMap>() as T;
            }
        }
      }

      // Handle number to string conversion
      if (T == num && value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed as T;
      }

      // Handle lossy casts if allowed
      if (lossyCast && T == String && value is num) {
        return value.toString() as T;
      }

      // Handle Map conversions
      if (T == JsonMap && value is String) {
        // Instead of attempting to convert a String to a JsonMap,
        // ensure that `value` is parsed as expected.
        try {
          return jsonFromString(value) as T;
        } catch (e) {
          throw ArgumentError(
            'Expected a JSON string to parse, but got an invalid type: '
            '${value.runtimeType}',
          );
        }
      }

      if (T == String && value is JsonMap) {
        return jsonToString(value) as T;
      }

      // In the list handling section:
      if (T == JsonList && value is String) {
        try {
          return jsonListFromString(value) as T;
        } catch (e) {
          throw ArgumentError(
            'Expected a JSON string representing a List, '
            'but got an invalid type: ${value.runtimeType}',
          );
        }
      }
      if (T == JsonList && value is List && value is! JsonList) {
        return value.cast<JsonMap>() as T;
      }

      // Handle general Map type conversion
      if (T != dynamic && value is Map && T.toString().startsWith('Map<')) {
        return _convertMap(value);
      }

      // Cast 0 to false and 1 to true for boolean types
      if (T == bool && value is int && (value == 0 || value == 1)) {
        return (value == 1) as T;
      }

      // Normalize numeric types between int/double for WASM interop
      if (T == int && value is num) {
        return value.toInt() as T;
      }
      if (T == double && value is num) {
        return value.toDouble() as T;
      }

      // Final type check
      if (value is! T) {
        throw ArgumentError(
          'Expected type $T for ${keys.last}, but got ${value.runtimeType}',
        );
      }
    }

    if (nullIfAbsent && value == null) return null;

    return value as T;
  } catch (e) {
    if (nullIfAbsent) return null;
    rethrow;
  }
}

// Helper method to handle lists that might contain maps
dynamic _convertList(List<dynamic> list) {
  return list
      .map(
        (item) => switch (item) {
          Map<dynamic, dynamic>() => _convertMap<JsonMap>(item),
          List<dynamic>() => _convertList(item),
          String() => item, // Keep strings as is
          int() => item, // Keep numbers as is
          double() => item,
          bool() => item, // Keep booleans as is
          null => null, // Keep nulls as is
          _ => item.toString(), // Convert other types to string
        },
      )
      .toList();
}

T _convertMap<T>(Map<dynamic, dynamic> sourceMap) {
  // First, sanitize the map to ensure all keys are strings
  final sanitizedMap = <String, dynamic>{};
  sourceMap.forEach((key, value) {
    final stringKey = key?.toString() ?? '';
    if (value is Map) {
      // Recursively convert nested maps
      sanitizedMap[stringKey] = _convertMap<JsonMap>(value);
    } else if (value is List) {
      // Handle lists and convert any maps within them
      sanitizedMap[stringKey] = _convertList(value);
    } else {
      sanitizedMap[stringKey] = value;
    }
  });

  if (T is JsonMap || T is JsonMap || T is JsonMap?) {
    return sanitizedMap as T;
  } else if ((T is Map<String, Object?>) || (T is Map<String, Object?>?)) {
    return Map<String, Object?>.from(sanitizedMap) as T;
  }

  try {
    return sanitizedMap as T;
  } catch (e) {
    throw ArgumentError('Failed to convert map to expected type $T: $e');
  }
}

// Add convenience method for handling List<String>
extension JsonMapListExtension on JsonMap {
  List<String>? tryGetStringList(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is! List) return null;
    return value.cast<String>();
  }
}

extension JsonMapExtension<T extends JsonMap> on T {
  TVal? valueVArgs<TVal>(List<String> keys, {TVal? defaultValue}) =>
      _traverseJson<TVal?>(this, keys, defaultValue: defaultValue);

  // TODO! Documentation
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

  // TODO! Documentation
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

  bool hasNestedKey(
    String key1, [
    String? key2,
    String? key3,
    String? key4,
    String? key5,
  ]) {
    return valueOrNull<dynamic>(key1, key2, key3, key4, key5) != null;
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
    if (!hasNestedKey(key) || this[key] == '') {
      this[key] = value;
    }
  }

  /// Ensure the entire map has been serialized to JSON types and that no
  /// non-serializable types are present
  JsonMap ensureJson() {
    return jsonFromString(toJsonString());
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
    return JsonMap.from(censoredMap) as T;
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
    final stack = <_CensorTask<K, V>>[_CensorTask(targetMap, censoredMap)];

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

extension StringToDecimal on String? {
  Decimal? get toDecimalOrNull {
    return this == null ? null : Decimal.tryParse(this!);
  }
}
