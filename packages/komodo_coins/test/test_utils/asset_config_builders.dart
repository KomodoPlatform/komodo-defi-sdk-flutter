/// Test utilities for building asset configurations.
///
/// This module provides convenient builder functions for creating
/// asset configurations for use in tests, reducing duplication
/// and making tests more readable and maintainable.
library;

/// Base configuration that can be shared across all asset types.
Map<String, dynamic> _baseAssetConfig({
  required String coin,
  required String type,
  required String name,
  String? fname,
  int? chainId,
  bool? isTestnet,
  String? trezorCoin,
  bool? active,
  bool? currentlyEnabled,
  bool? walletOnly,
}) {
  return {
    'coin': coin,
    'type': type,
    'name': name,
    'fname': fname ?? name,
    'chain_id': chainId ?? 0,
    'is_testnet': isTestnet ?? false,
    'trezor_coin': trezorCoin ?? name,
    'active': active ?? false,
    'currently_enabled': currentlyEnabled ?? false,
    'wallet_only': walletOnly ?? false,
  };
}

/// Builder for UTXO asset configurations.
class UtxoAssetConfigBuilder {
  UtxoAssetConfigBuilder({
    required String coin,
    required String name,
    String? fname,
    int? chainId,
    bool? isTestnet,
    String? trezorCoin,
  }) {
    _config = _baseAssetConfig(
      coin: coin,
      type: 'UTXO',
      name: name,
      fname: fname,
      chainId: chainId,
      isTestnet: isTestnet,
      trezorCoin: trezorCoin,
    );

    // UTXO defaults
    _config['protocol'] = {'type': 'UTXO'};
    _config['mm2'] = 1;
    _config['required_confirmations'] = 1;
    _config['avg_blocktime'] = 10;
  }
  Map<String, dynamic> _config = {};

  UtxoAssetConfigBuilder withUtxoFields({
    int? pubtype,
    int? p2shtype,
    int? wiftype,
    int? txfee,
    int? txversion,
    bool? segwit,
  }) {
    if (pubtype != null) _config['pubtype'] = pubtype;
    if (p2shtype != null) _config['p2shtype'] = p2shtype;
    if (wiftype != null) _config['wiftype'] = wiftype;
    if (txfee != null) _config['txfee'] = txfee;
    if (txversion != null) _config['txversion'] = txversion;
    if (segwit != null) _config['segwit'] = segwit;
    return this;
  }

  UtxoAssetConfigBuilder withActive(bool active) {
    _config['active'] = active;
    return this;
  }

  UtxoAssetConfigBuilder withWalletOnly(bool walletOnly) {
    _config['wallet_only'] = walletOnly;
    return this;
  }

  UtxoAssetConfigBuilder withCurrentlyEnabled(bool enabled) {
    _config['currently_enabled'] = enabled;
    return this;
  }

  Map<String, dynamic> build() => Map<String, dynamic>.from(_config);
}

/// Standard asset configurations for common test scenarios.
class StandardAssetConfigs {
  /// Creates a basic Komodo UTXO configuration.
  static Map<String, dynamic> komodo() {
    return UtxoAssetConfigBuilder(
      coin: 'KMD',
      name: 'Komodo',
      fname: 'Komodo',
      chainId: 0,
      trezorCoin: 'Komodo',
    )
        .withUtxoFields(
          pubtype: 60,
          p2shtype: 85,
          wiftype: 188,
          txfee: 1000,
        )
        .withActive(true)
        .build();
  }

  /// Creates a basic Bitcoin UTXO configuration.
  static Map<String, dynamic> bitcoin() {
    return UtxoAssetConfigBuilder(
      coin: 'BTC',
      name: 'Bitcoin',
      fname: 'Bitcoin',
      chainId: 0,
      trezorCoin: 'Bitcoin',
    )
        .withUtxoFields(
          pubtype: 0,
          p2shtype: 5,
          wiftype: 128,
          txfee: 1000,
          segwit: true,
        )
        .withActive(true)
        .build();
  }

  /// Creates a simple test coin configuration.
  static Map<String, dynamic> testCoin({
    String coin = 'TEST',
    String name = 'Test Coin',
    bool active = false,
    bool walletOnly = false,
  }) {
    return UtxoAssetConfigBuilder(
      coin: coin,
      name: name,
      chainId: 0,
      trezorCoin: name,
    ).withActive(active).withWalletOnly(walletOnly).build();
  }
}
