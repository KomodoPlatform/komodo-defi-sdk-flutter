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
  String? coinpaprikaId,
  String? coingeckoId,
  String? livecoinwatchId,
  String? explorerUrl,
  String? explorerTxUrl,
  String? explorerAddressUrl,
  String? explorerBlockUrl,
  List<dynamic>? supported,
  bool? active,
  bool? isTestnet,
  bool? currentlyEnabled,
  bool? walletOnly,
  int? rpcport,
  int? mm2,
  int? decimals,
  double? avgBlocktime,
  int? requiredConfirmations,
  String? derivationPath,
  String? signMessagePrefix,
}) {
  return {
    'coin': coin,
    'type': type,
    'name': name,
    'fname': fname ?? name,
    if (coinpaprikaId != null) 'coinpaprika_id': coinpaprikaId,
    if (coingeckoId != null) 'coingecko_id': coingeckoId,
    if (livecoinwatchId != null) 'livecoinwatch_id': livecoinwatchId,
    if (explorerUrl != null) 'explorer_url': explorerUrl,
    if (explorerTxUrl != null) 'explorer_tx_url': explorerTxUrl,
    if (explorerAddressUrl != null) 'explorer_address_url': explorerAddressUrl,
    if (explorerBlockUrl != null) 'explorer_block_url': explorerBlockUrl,
    'supported': supported ?? [],
    'active': active ?? false,
    'is_testnet': isTestnet ?? false,
    'currently_enabled': currentlyEnabled ?? false,
    'wallet_only': walletOnly ?? false,
    if (rpcport != null) 'rpcport': rpcport,
    if (mm2 != null) 'mm2': mm2,
    if (decimals != null) 'decimals': decimals,
    if (avgBlocktime != null) 'avg_blocktime': avgBlocktime,
    if (requiredConfirmations != null)
      'required_confirmations': requiredConfirmations,
    if (derivationPath != null) 'derivation_path': derivationPath,
    if (signMessagePrefix != null) 'sign_message_prefix': signMessagePrefix,
  };
}

/// Builder for UTXO asset configurations.
class UtxoAssetConfigBuilder {
  UtxoAssetConfigBuilder({
    required String coin,
    required String name,
    String? fname,
    String? coinpaprikaId,
    String? coingeckoId,
    String? livecoinwatchId,
  }) {
    _config = _baseAssetConfig(
      coin: coin,
      type: 'UTXO',
      name: name,
      fname: fname,
      coinpaprikaId: coinpaprikaId,
      coingeckoId: coingeckoId,
      livecoinwatchId: livecoinwatchId,
    );

    // UTXO defaults
    _config['protocol'] = {'type': 'UTXO'};
    _config['mm2'] = 1;
    _config['required_confirmations'] = 1;
    _config['avg_blocktime'] = 10;
  }
  Map<String, dynamic> _config = {};

  UtxoAssetConfigBuilder withExplorer({
    String? baseUrl,
    String? txUrl,
    String? addressUrl,
    String? blockUrl,
  }) {
    if (baseUrl != null) _config['explorer_url'] = baseUrl;
    if (txUrl != null) _config['explorer_tx_url'] = txUrl;
    if (addressUrl != null) _config['explorer_address_url'] = addressUrl;
    if (blockUrl != null) _config['explorer_block_url'] = blockUrl;
    return this;
  }

  UtxoAssetConfigBuilder withDerivationPath(String path) {
    _config['derivation_path'] = path;
    return this;
  }

  UtxoAssetConfigBuilder withSignMessagePrefix(String prefix) {
    _config['sign_message_prefix'] = prefix;
    return this;
  }

  UtxoAssetConfigBuilder withElectrum(
    List<Map<String, String>> electrumServers,
  ) {
    _config['electrum'] = electrumServers;
    return this;
  }

  UtxoAssetConfigBuilder withUtxoFields({
    int? pubtype,
    int? p2shtype,
    int? wiftype,
    int? txfee,
    int? txversion,
    int? overwintered,
    int? taddr,
    bool? segwit,
    bool? forceMinRelayFee,
    String? estimateFeeMode,
    int? matureConfirmations,
  }) {
    if (pubtype != null) _config['pubtype'] = pubtype;
    if (p2shtype != null) _config['p2shtype'] = p2shtype;
    if (wiftype != null) _config['wiftype'] = wiftype;
    if (txfee != null) _config['txfee'] = txfee;
    if (txversion != null) _config['txversion'] = txversion;
    if (overwintered != null) _config['overwintered'] = overwintered;
    if (taddr != null) _config['taddr'] = taddr;
    if (segwit != null) _config['segwit'] = segwit;
    if (forceMinRelayFee != null)
      _config['force_min_relay_fee'] = forceMinRelayFee;
    if (estimateFeeMode != null) _config['estimate_fee_mode'] = estimateFeeMode;
    if (matureConfirmations != null)
      _config['mature_confirmations'] = matureConfirmations;
    return this;
  }

  UtxoAssetConfigBuilder withVariants(List<String> otherTypes) {
    _config['other_types'] = otherTypes;
    return this;
  }

  Map<String, dynamic> build() => Map<String, dynamic>.from(_config);
}

/// Builder for ERC20 asset configurations.
class Erc20AssetConfigBuilder {
  Erc20AssetConfigBuilder({
    required String coin,
    required String name,
    String? fname,
    String? coinpaprikaId,
    String? coingeckoId,
    String? livecoinwatchId,
  }) {
    _config = _baseAssetConfig(
      coin: coin,
      type: 'ERC-20',
      name: name,
      fname: fname,
      coinpaprikaId: coinpaprikaId,
      coingeckoId: coingeckoId,
      livecoinwatchId: livecoinwatchId,
    );

    // ERC20 defaults
    _config['protocol'] = {'type': 'ERC20'};
    _config['mm2'] = 1;
    _config['chain_id'] = 1;
    _config['decimals'] = 18;
    _config['avg_blocktime'] = 13.5;
    _config['required_confirmations'] = 3;
    _config['derivation_path'] = "m/44'/60'";
  }
  Map<String, dynamic> _config = {};

  Erc20AssetConfigBuilder withExplorer({
    String? baseUrl,
    String? txUrl,
    String? addressUrl,
    String? blockUrl,
  }) {
    if (baseUrl != null) _config['explorer_url'] = baseUrl;
    if (txUrl != null) _config['explorer_tx_url'] = txUrl;
    if (addressUrl != null) _config['explorer_address_url'] = addressUrl;
    if (blockUrl != null) _config['explorer_block_url'] = blockUrl;
    return this;
  }

  Erc20AssetConfigBuilder withChainId(int chainId) {
    _config['chain_id'] = chainId;
    return this;
  }

  Erc20AssetConfigBuilder withDecimals(int decimals) {
    _config['decimals'] = decimals;
    return this;
  }

  Erc20AssetConfigBuilder withSwapContracts({
    String? swapContractAddress,
    String? fallbackSwapContract,
  }) {
    if (swapContractAddress != null)
      _config['swap_contract_address'] = swapContractAddress;
    if (fallbackSwapContract != null)
      _config['fallback_swap_contract'] = fallbackSwapContract;
    return this;
  }

  Erc20AssetConfigBuilder withNodes(List<Map<String, String>> nodes) {
    _config['nodes'] = nodes;
    return this;
  }

  Erc20AssetConfigBuilder withToken({
    String? contractAddress,
    String? parentCoin,
  }) {
    if (contractAddress != null) {
      _config['contract_address'] = contractAddress;
      _config['protocol'] = {
        'type': 'ERC-20',
        'protocol_data': {
          'platform': parentCoin ?? 'ETH',
          'contract_address': contractAddress,
        },
      };
    }
    if (parentCoin != null) _config['parent_coin'] = parentCoin;
    return this;
  }

  Map<String, dynamic> build() => Map<String, dynamic>.from(_config);
}

/// Builder for Tendermint asset configurations.
class TendermintAssetConfigBuilder {
  TendermintAssetConfigBuilder({
    required String coin,
    required String name,
    String? fname,
    String? coinpaprikaId,
    String? coingeckoId,
  }) {
    _config = _baseAssetConfig(
      coin: coin,
      type: 'Tendermint',
      name: name,
      fname: fname,
      coinpaprikaId: coinpaprikaId,
      coingeckoId: coingeckoId,
    );

    // Tendermint defaults
    _config['mm2'] = 1;
    _config['decimals'] = 6;
    _config['required_confirmations'] = 1;
    _config['avg_blocktime'] = 6;
  }
  Map<String, dynamic> _config = {};

  TendermintAssetConfigBuilder withExplorer({
    String? baseUrl,
    String? txUrl,
    String? addressUrl,
    String? blockUrl,
  }) {
    if (baseUrl != null) _config['explorer_url'] = baseUrl;
    if (txUrl != null) _config['explorer_tx_url'] = txUrl;
    if (addressUrl != null) _config['explorer_address_url'] = addressUrl;
    if (blockUrl != null) _config['explorer_block_url'] = blockUrl;
    return this;
  }

  TendermintAssetConfigBuilder withProtocolData({
    required String accountPrefix,
    required String chainId,
    String? chainRegistryName,
  }) {
    _config['protocol'] = {
      'type': 'Tendermint',
      'protocol_data': {
        'account_prefix': accountPrefix,
        'chain_id': chainId,
        if (chainRegistryName != null) 'chain_registry_name': chainRegistryName,
      },
    };
    return this;
  }

  TendermintAssetConfigBuilder withRpcUrls(List<Map<String, String>> rpcUrls) {
    _config['rpc_urls'] = rpcUrls;
    return this;
  }

  TendermintAssetConfigBuilder withDerivationPath(String path) {
    _config['derivation_path'] = path;
    return this;
  }

  Map<String, dynamic> build() => Map<String, dynamic>.from(_config);
}

/// Convenience functions for creating common asset configurations.
class AssetConfigBuilders {
  /// Creates a standard Bitcoin UTXO configuration.
  static Map<String, dynamic> bitcoin() {
    return UtxoAssetConfigBuilder(
          coin: 'BTC',
          name: 'Bitcoin',
          fname: 'Bitcoin',
          coinpaprikaId: 'btc-bitcoin',
          coingeckoId: 'bitcoin',
          livecoinwatchId: 'BTC',
        )
        .withExplorer(
          baseUrl: 'https://blockstream.info/',
          txUrl: 'tx/',
          addressUrl: 'address/',
          blockUrl: 'block/',
        )
        .withDerivationPath("m/44'/0'")
        .withSignMessagePrefix('Bitcoin Signed Message:\n')
        .withElectrum([
          {
            'url': 'electrum1.cipig.net:10000',
            'ws_url': 'electrum1.cipig.net:30000',
          },
        ])
        .withUtxoFields(
          pubtype: 0,
          p2shtype: 5,
          wiftype: 128,
          txfee: 1000,
          txversion: 2,
          overwintered: 0,
          taddr: 28,
          segwit: true,
          forceMinRelayFee: false,
          estimateFeeMode: 'ECONOMICAL',
          matureConfirmations: 101,
        )
        .build();
  }

  /// Creates a standard Ethereum ERC20 configuration.
  static Map<String, dynamic> ethereum() {
    return Erc20AssetConfigBuilder(
          coin: 'ETH',
          name: 'Ethereum',
          fname: 'Ethereum',
          coinpaprikaId: 'eth-ethereum',
          coingeckoId: 'ethereum',
          livecoinwatchId: 'ETH',
        )
        .withExplorer(
          baseUrl: 'https://etherscan.io/',
          txUrl: 'tx/',
          addressUrl: 'address/',
          blockUrl: 'block/',
        )
        .withSwapContracts(
          swapContractAddress: '0x8500AFc0bc5214728082163326C2FF0C73f4a871',
          fallbackSwapContract: '0x8500AFc0bc5214728082163326C2FF0C73f4a871',
        )
        .withNodes([
          {
            'url': 'https://mainnet.infura.io/v3/YOUR-PROJECT-ID',
            'ws_url': 'wss://mainnet.infura.io/ws/v3/YOUR-PROJECT-ID',
          },
        ])
        .build();
  }

  /// Creates a standard USDT ERC20 token configuration.
  static Map<String, dynamic> usdtErc20() {
    return Erc20AssetConfigBuilder(
          coin: 'USDT-ERC20',
          name: 'Tether',
          fname: 'Tether',
          coinpaprikaId: 'usdt-tether',
          coingeckoId: 'tether',
          livecoinwatchId: 'USDT',
        )
        .withExplorer(
          baseUrl: 'https://etherscan.io/',
          txUrl: 'tx/',
          addressUrl: 'address/',
          blockUrl: 'block/',
        )
        .withDecimals(6)
        .withToken(
          contractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
          parentCoin: 'ETH',
        )
        .withSwapContracts(
          swapContractAddress: '0x8500AFc0bc5214728082163326C2FF0C73f4a871',
          fallbackSwapContract: '0x8500AFc0bc5214728082163326C2FF0C73f4a871',
        )
        .withNodes([
          {
            'url': 'https://mainnet.infura.io/v3/YOUR-PROJECT-ID',
            'ws_url': 'wss://mainnet.infura.io/ws/v3/YOUR-PROJECT-ID',
          },
        ])
        .build();
  }

  /// Creates a standard Cosmos Tendermint configuration.
  static Map<String, dynamic> cosmos() {
    return TendermintAssetConfigBuilder(
          coin: 'ATOM',
          name: 'Cosmos',
          fname: 'Cosmos',
          coinpaprikaId: 'atom-cosmos',
          coingeckoId: 'cosmos',
        )
        .withExplorer(
          baseUrl: 'https://www.mintscan.io/cosmos/',
          txUrl: 'txs/',
          addressUrl: 'account/',
          blockUrl: 'blocks/',
        )
        .withProtocolData(
          accountPrefix: 'cosmos',
          chainId: 'cosmoshub-4',
          chainRegistryName: 'cosmos',
        )
        .withRpcUrls([
          {'url': 'https://rpc-cosmos.blockapsis.com'},
        ])
        .withDerivationPath("m/44'/118'")
        .build();
  }

  /// Creates a Komodo UTXO configuration with SmartChain support.
  static Map<String, dynamic> komodoWithSmartChain() {
    return UtxoAssetConfigBuilder(coin: 'KMD', name: 'Komodo', fname: 'Komodo')
        .withElectrum([
          {'url': 'electrum1.cipig.net:10001'},
        ])
        .withVariants(['SmartChain'])
        .build();
  }
}
