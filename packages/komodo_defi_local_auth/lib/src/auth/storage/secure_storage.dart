// lib/src/auth/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
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

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _userPrefix = 'user_';
  static const _sessionPrefix = 'session_';
  static const String _lastActiveWalletIdKey = 'lastActiveWalletId';

  String _serializeWalletId(WalletId walletId) =>
      walletId.toJson().toJsonString();
  String _userKeyFor(WalletId walletId) =>
      '$_userPrefix${_serializeWalletId(walletId)}';
  String _sessionKeyFor(WalletId walletId) =>
      '$_sessionPrefix${_serializeWalletId(walletId)}';

  /// Save user data (keyed by serialized WalletId)
  Future<void> saveUser(KdfUser user) async {
    final jsonString = user.toJson().toJsonString();
    await _storage.write(key: _userKeyFor(user.walletId), value: jsonString);
  }

  /// Get user by full WalletId
  Future<KdfUser?> getUserByWalletId(WalletId walletId) async {
    final jsonString = await _storage.read(key: _userKeyFor(walletId));
    if (jsonString == null) return null;
    return KdfUser.fromJson(jsonFromString(jsonString));
  }

  /// Get user by wallet name (fallback for flows that only have name)
  Future<KdfUser?> getUserByName(String walletName) async {
    final all = await _storage.readAll();
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_userPrefix)) continue;
      final value = entry.value;
      if (value.isEmpty) continue;
      try {
        final user = KdfUser.fromJson(jsonFromString(value));
        if (user.walletId.name == walletName) return user;
      } catch (_) {
        // ignore malformed entries
      }
    }
    return null;
  }

  /// Delete user by full WalletId
  Future<void> deleteUserByWalletId(WalletId walletId) async {
    await _storage.delete(key: _userKeyFor(walletId));
  }

  /// Delete user by wallet name
  Future<void> deleteUserByName(String walletName) async {
    final all = await _storage.readAll();
    for (final entry in all.entries) {
      if (!entry.key.startsWith(_userPrefix)) continue;
      final value = entry.value;
      if (value.isEmpty) continue;
      try {
        final user = KdfUser.fromJson(jsonFromString(value));
        if (user.walletId.name == walletName) {
          await _storage.delete(key: entry.key);
        }
      } catch (_) {
        // ignore
      }
    }
  }

  /// Persist a serialized session snapshot for the active wallet (keyed by WalletId)
  Future<void> saveSessionSnapshot(WalletId walletId, JsonMap snapshot) async {
    await _storage.write(
      key: _sessionKeyFor(walletId),
      value: snapshot.toJsonString(),
    );
  }

  /// Retrieve a serialized session snapshot for the wallet, if one exists.
  Future<JsonMap?> getSessionSnapshot(WalletId walletId) async {
    final jsonString = await _storage.read(key: _sessionKeyFor(walletId));
    if (jsonString == null) return null;
    return jsonFromString(jsonString);
  }

  /// Remove the cached session snapshot for the wallet.
  Future<void> deleteSessionSnapshot(WalletId walletId) async {
    await _storage.delete(key: _sessionKeyFor(walletId));
  }

  /// Save the last active wallet id (serialized JSON)
  Future<void> saveLastActiveWalletId(WalletId? walletId) async {
    if (walletId == null) {
      await _storage.delete(key: _lastActiveWalletIdKey);
    } else {
      await _storage.write(
        key: _lastActiveWalletIdKey,
        value: _serializeWalletId(walletId),
      );
    }
  }

  /// Get the last active wallet id
  Future<WalletId?> getLastActiveWalletId() async {
    final val = await _storage.read(key: _lastActiveWalletIdKey);
    if (val == null) return null;
    try {
      return WalletId.fromJson(jsonFromString(val));
    } catch (_) {
      return null;
    }
  }

  /// Clears all secure storage
  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
  }
}
