// lib/src/auth/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class Storage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class SecureLocalStorage {
  factory SecureLocalStorage() => _instance;
  SecureLocalStorage._();
  static final SecureLocalStorage _instance = SecureLocalStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _userPrefix = 'user_';

  /// Save user data
  Future<void> saveUser(KdfUser user) async {
    final jsonString = user.toJson().toJsonString();
    await _storage.write(
      key: '$_userPrefix${user.walletId.name}',
      value: jsonString,
    );
  }

  /// Get user data
  Future<KdfUser?> getUser(String walletName) async {
    final jsonString = await _storage.read(key: '$_userPrefix$walletName');
    if (jsonString == null) return null;
    return KdfUser.fromJson(jsonFromString(jsonString));
  }

  /// Delete user data
  Future<void> deleteUser(String walletName) async {
    await _storage.delete(key: '$_userPrefix$walletName');
  }
}
