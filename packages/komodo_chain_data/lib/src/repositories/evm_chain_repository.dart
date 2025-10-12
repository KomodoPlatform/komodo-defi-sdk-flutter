import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_chain_data/komodo_chain_data.dart';
import 'package:logging/logging.dart';

/// Repository for EVM chain information from chainid.network.
class EvmChainRepository implements ChainRepository {
  EvmChainRepository({HttpClient? httpClient, Duration? cacheTtl})
    : _httpClient = httpClient ?? HttpClient(),
      _cacheTtl = cacheTtl ?? const Duration(hours: 24);

  static const String _chainsUrl = 'https://chainid.network/chains_mini.json';
  static final _log = Logger('EvmChainRepository');

  final HttpClient _httpClient;
  final Duration _cacheTtl;

  List<EvmChainInfo> _cachedChains = [];
  DateTime? _lastFetch;

  /// Default EVM chains to use as fallback.
  static final List<EvmChainInfo> _defaultChains = [
    EvmChainInfo.ethereum(),
    EvmChainInfo.polygon(),
    EvmChainInfo.bnbSmartChain(),
    EvmChainInfo.avalanche(),
    EvmChainInfo.fantom(),
  ];

  @override
  Future<List<ChainInfo>> getChains() async {
    if (isCacheValid && _cachedChains.isNotEmpty) {
      _log.fine('Returning cached EVM chains (${_cachedChains.length} chains)');
      return _cachedChains.cast<ChainInfo>();
    }

    try {
      await refreshChains();
      return _cachedChains.cast<ChainInfo>();
    } catch (e, stackTrace) {
      _log.warning('Failed to fetch EVM chains, using defaults', e, stackTrace);
      return _getDefaultChains().cast<ChainInfo>();
    }
  }

  @override
  Future<void> refreshChains() async {
    _log.info('Fetching EVM chains from $_chainsUrl');

    try {
      final request = await _httpClient.getUrl(Uri.parse(_chainsUrl));
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'KomodoDefiSDK/1.0');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch EVM chains: ${response.statusCode}',
        );
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final chainsJson = json.decode(responseBody) as List<dynamic>;

      _cachedChains = chainsJson
          .map(
            (chainJson) =>
                EvmChainInfo.fromJson(chainJson as Map<String, dynamic>),
          )
          .where((chain) => chain.isMainnet) // Only include mainnet chains
          .toList();

      _lastFetch = DateTime.now();

      _log.info('Successfully fetched ${_cachedChains.length} EVM chains');
    } catch (e, stackTrace) {
      _log.severe('Failed to refresh EVM chains', e, stackTrace);

      // If we have no cached data, use defaults
      if (_cachedChains.isEmpty) {
        _cachedChains = _getDefaultChains();
        _lastFetch = DateTime.now();
        _log.info('Using default EVM chains (${_cachedChains.length} chains)');
      }

      rethrow;
    }
  }

  @override
  List<ChainInfo> getCachedChains() {
    return List.unmodifiable(_cachedChains.cast<ChainInfo>());
  }

  @override
  bool get isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheTtl;
  }

  /// Gets EVM chains as EvmChainInfo objects.
  Future<List<EvmChainInfo>> getEvmChains() async {
    final chains = await getChains();
    return chains.cast<EvmChainInfo>();
  }

  /// Gets EVM chain IDs in WalletConnect format (eip155:chainId).
  Future<List<String>> getEvmChainIds() async {
    final chains = await getEvmChains();
    return chains.map((chain) => chain.walletConnectChainId).toList();
  }

  /// Gets cached EVM chain IDs in WalletConnect format.
  List<String> getCachedEvmChainIds() {
    return _cachedChains.map((chain) => chain.walletConnectChainId).toList();
  }

  /// Gets default EVM chains as fallback.
  List<EvmChainInfo> _getDefaultChains() {
    return List.from(_defaultChains);
  }

  @override
  void dispose() {
    _httpClient.close();
    _cachedChains.clear();
    _lastFetch = null;
  }
}
