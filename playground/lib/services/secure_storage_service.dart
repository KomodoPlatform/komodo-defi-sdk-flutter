import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service class that provides secure storage capabilities using flutter_secure_storage
/// for storing sensitive information like passwords and configurations.
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  late final FlutterSecureStorage _secureStorage;

  // Singleton pattern
  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal() {
    // Android options with encryption
    const AndroidOptions androidOptions = AndroidOptions();

    // Default options for all platforms
    const IOSOptions iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );

    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

  /// Writes a string value to secure storage
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Reads a string value from secure storage
  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  /// Deletes a value from secure storage
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  /// Clears all values from secure storage
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  /// Writes a Map or List to secure storage by converting it to JSON
  Future<void> writeObject({
    required String key,
    required dynamic object,
  }) async {
    final jsonString = json.encode(object);
    await write(key: key, value: jsonString);
  }

  /// Reads a Map or List from secure storage by parsing JSON
  Future<dynamic> readObject({required String key}) async {
    final jsonString = await read(key: key);
    if (jsonString == null) return null;
    return json.decode(jsonString);
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey({required String key}) async {
    return await _secureStorage.containsKey(key: key);
  }
}
