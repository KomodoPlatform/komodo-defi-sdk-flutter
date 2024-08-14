// Extension on JSON Map class
import 'dart:convert';

extension MapExtensions on JsonMap {
  // Method to convert a JSON Map to a JSON String
  String toJsonString() => json.encode(this);
  // Method to convert a JSON String to a JSON Map
  static JsonMap fromJsonString(String jsonString) =>
      json.decode(jsonString) as JsonMap;

  static JsonMap? fromJsonStringOrNull(String jsonString) {
    try {
      return fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }
}

// Extension on JSON List class
extension ListExtensions on JsonList {
  // Method to convert a JSON List to a JSON String
  String toJsonString() => json.encode(this);
  // Method to convert a JSON String to a JSON List
  static JsonList fromJsonString(String jsonString) =>
      (json.decode(jsonString) as List).cast<JsonMap>();

  static JsonList? fromJsonStringOrNull(String jsonString) {
    try {
      return fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }
}

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;
