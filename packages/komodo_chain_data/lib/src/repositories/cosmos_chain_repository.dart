import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_chain_data/komodo_chain_data.dart';
import 'package:logging/logging.dart';

/// Repository for Cosmos chain information from chains.cosmos.directory.
class CosmosChainRepository implements ChainRepository {
  CosmosChainRepository({HttpClient? httpClient, Duration? cacheTtl})
    : _httpClient = httpClient ?? HttpClient(),
      _cacheTtl = cacheTtl ?? const Duration(hours: 24);

  static const String _chainsUrl = 'https://chains.cosmos.directory/';
  static final _log = Logger('CosmosChainRepository');

  final HttpClient _httpClient;
  final Duration _cacheTtl;

  List<CosmosChainInfo> _cachedChains = [];
  DateTime? _lastFetch;

  /// Default Cosmos chains to use as fallback.
  static final List<CosmosChainInfo> _defaultChains = [
    CosmosChainInfo.cosmosHub(),
    CosmosChainInfo.osmosis(),
    CosmosChainInfo.juno(),
    CosmosChainInfo.akash(),
    CosmosChainInfo.secret(),
  ];

  @override
  Future<List<ChainInfo>> getChains() async {
    if (isCacheValid && _cachedChains.isNotEmpty) {
      _log.fine(
        'Returning cached Cosmos chains (${_cachedChains.length} chains)',
      );
      return _cachedChains.cast<ChainInfo>();
    }

    try {
      await refreshChains();
      return _cachedChains.cast<ChainInfo>();
    } catch (e, stackTrace) {
      _log.warning(
        'Failed to fetch Cosmos chains, using defaults',
        e,
        stackTrace,
      );
      return _getDefaultChains().cast<ChainInfo>();
    }
  }

  @override
  Future<void> refreshChains() async {
    _log.info('Fetching Cosmos chains from $_chainsUrl');

    try {
      final request = await _httpClient.getUrl(Uri.parse(_chainsUrl));
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'KomodoDefiSDK/1.0');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch Cosmos chains: ${response.statusCode}',
        );
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final responseJson = json.decode(responseBody) as Map<String, dynamic>;

      // The chains.cosmos.directory API returns a different structure
      // We need to handle the 'chains' array or individual chain objects
      List<dynamic> chainsJson;
      if (responseJson.containsKey('chains')) {
        chainsJson = responseJson['chains'] as List<dynamic>;
      } else {
        // If the response is a single chain or different format, adapt accordingly
        chainsJson = [responseJson];
      }

      _cachedChains = chainsJson
          .map(
            (chainJson) =>
                CosmosChainInfo.fromJson(chainJson as Map<String, dynamic>),
          )
          .where((chain) => chain.isMainnet) // Only include mainnet chains
          .toList();

      _lastFetch = DateTime.now();

      _log.info('Successfully fetched ${_cachedChains.length} Cosmos chains');
    } catch (e, stackTrace) {
      _log.severe('Failed to refresh Cosmos chains', e, stackTrace);

      // If we have no cached data, use defaults
      if (_cachedChains.isEmpty) {
        _cachedChains = _getDefaultChains();
        _lastFetch = DateTime.now();
        _log.info(
          'Using default Cosmos chains (${_cachedChains.length} chains)',
        );
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

  /// Gets Cosmos chains as CosmosChainInfo objects.
  Future<List<CosmosChainInfo>> getCosmosChains() async {
    final chains = await getChains();
    return chains.cast<CosmosChainInfo>();
  }

  /// Gets Cosmos chain IDs in WalletConnect format (cosmos:chainId).
  Future<List<String>> getCosmosChainIds() async {
    final chains = await getCosmosChains();
    return chains.map((chain) => chain.walletConnectChainId).toList();
  }

  /// Gets cached Cosmos chain IDs in WalletConnect format.
  List<String> getCachedCosmosChainIds() {
    return _cachedChains.map((chain) => chain.walletConnectChainId).toList();
  }

  /// Gets default Cosmos chains as fallback.
  List<CosmosChainInfo> _getDefaultChains() {
    return List.from(_defaultChains);
  }

  @override
  void dispose() {
    _httpClient.close();
    _cachedChains.clear();
    _lastFetch = null;
  }
}
