import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_sdk/src/pubkeys/hive_pubkeys_adapters.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Storage interface for persisting pubkeys between sessions
abstract class PubkeysStorage {
  Future<void> savePubkeys(
    WalletId walletId,
    String assetTicker,
    AssetPubkeys pubkeys,
  );

  /// Returns a map of assetTicker -> stored pubkeys JSON for the wallet
  Future<Map<String, Map<String, dynamic>>> listForWallet(WalletId walletId);
}

class HivePubkeysStorage implements PubkeysStorage {
  static const _boxName = 'pubkeys_cache_v1';
  Box<HiveAssetPubkeysRecord>? _box;
  Future<Box<HiveAssetPubkeysRecord>> _openBox() async {
    registerPubkeysAdapters();
    if (_box != null) return _box!;
    _box = await Hive.openBox<HiveAssetPubkeysRecord>(_boxName);
    return _box!;
  }

  String _keyFor(WalletId walletId, String assetTicker) =>
      '${walletId.compoundId}|$assetTicker';

  @override
  Future<void> savePubkeys(
    WalletId walletId,
    String assetTicker,
    AssetPubkeys pubkeys,
  ) async {
    final box = await _openBox();
    final record = HiveAssetPubkeysRecord.fromDomain(pubkeys);
    await box.put(_keyFor(walletId, assetTicker), record);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> listForWallet(
    WalletId walletId,
  ) async {
    final box = await _openBox();
    final prefix = '${walletId.compoundId}|';
    final result = <String, Map<String, dynamic>>{};
    for (final dynamicKey in box.keys) {
      final key = dynamicKey as String;
      if (!key.startsWith(prefix)) continue;
      final record = box.get(key);
      if (record == null) continue;
      // Build map structure to mirror the expected hydration format
      // used by PubkeyManager._hydrateFromStorage* for fast hydration
      result[key.substring(prefix.length)] = {
        'available': record.available,
        'sync': record.sync,
        'addresses': record.keys
            .map(
              (k) => {
                'address': k.address,
                'derivation_path': k.derivationPath,
                'chain': k.chain,
                'balance': {
                  'spendable': k.spendable,
                  'unspendable': k.unspendable,
                },
              },
            )
            .toList(),
      };
    }
    return result;
  }
}
