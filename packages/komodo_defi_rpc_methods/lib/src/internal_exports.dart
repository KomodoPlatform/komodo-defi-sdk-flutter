import 'dart:convert';

export 'package:komodo_defi_rpc_methods/src/client/api_client.dart';
export 'package:komodo_defi_rpc_methods/src/models/models.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

JsonMap decodeJson(String json) {
  final decode = jsonDecode(json);

  assert(
    decode is JsonMap,
    'Tried to parse API response as a Map, but got a ${decode.runtimeType}',
  );

  return decode as JsonMap;
}

String encodeJson(dynamic json) => jsonEncode(json);

// Method to take a JSON map and list of keys to traverse and return the value
T _traverseJson<T extends dynamic>(JsonMap json, List<String> keys) {
  dynamic value = json;

  for (final key in keys) {
    if (value is! JsonMap) {
      throw ArgumentError('Cannot traverse a non-Map value');
    }

    value = value[key];
  }

  return value as T;
}

extension JsonMapExtension on JsonMap {
  T nestedValue<T extends dynamic>(List<String> keys) =>
      _traverseJson<T>(this, keys);

  T value<T extends dynamic>(String key) => this[key] as T;
}
