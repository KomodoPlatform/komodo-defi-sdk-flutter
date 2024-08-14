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

String encodeJson(dynamic json) => jsonEncode(json);

// Method to take a JSON map and list of keys to traverse and return the value
T _traverseJson<T extends dynamic>(
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

  // If the value is found and is not the same as the value type passed,
  // throw an error
  if (value != null && value is! T) {
    throw ArgumentError(
      'Traversed JSON and expected value of type $T, but got ${value.runtimeType}',
    );
  }

  return value as T;
}

extension JsonMapExtension on Map<String, dynamic> {
  T nestedValue<T extends dynamic>(List<String> keys, {T? defaultValue}) =>
      _traverseJson<T>(this, keys, defaultValue: defaultValue);

  // TOODO: Consider if we should support non-string keys
  V value<V extends dynamic>(
    String key, [
    dynamic key2,
    dynamic key3,
    dynamic key4,
    dynamic key5,
  ]) {
    final keys = [key, key2, key3, key4, key5].toList();
    return _traverseJson<V>(this, keys);
  }

  static JsonMap fromJsonString(String jsonString) =>
      json.decode(jsonString) as JsonMap;
}
