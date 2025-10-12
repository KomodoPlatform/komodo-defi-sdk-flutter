import 'dart:io';

import 'package:komodo_chain_data/komodo_chain_data.dart';
import 'package:test/test.dart';

void main() {
  group('CosmosChainRepository', () {
    late CosmosChainRepository repository;

    setUp(() {
      repository = CosmosChainRepository(cacheTtl: const Duration(minutes: 5));
    });

    tearDown(() {
      repository.dispose();
    });

    group('API integration', () {
      test('should fetch chains from API successfully', () async {
        // Act
        final chains = await repository.getChains();

        // Assert
        expect(chains, isNotEmpty);
        expect(chains.first, isA<ChainInfo>());

        // Get as CosmosChainInfo to check specific properties
        final cosmosChains = await repository.getCosmosChains();
        expect(cosmosChains.first, isA<CosmosChainInfo>());
        expect(cosmosChains.every((chain) => chain.isMainnet), isTrue);
      });

      test('should cache chains after first fetch', () async {
        // Act
        final chains1 = await repository.getChains();
        final chains2 = await repository.getChains();

        // Assert
        expect(chains1, isNotEmpty);
        expect(chains2, isNotEmpty);
        expect(repository.isCacheValid, isTrue);
      });
    });

    group('default chains with factory constructors', () {
      test('should use factory constructor defaults when API fails', () async {
        // Arrange - Create repository with invalid HTTP client to force failure
        final failingRepository = CosmosChainRepository(
          httpClient: _FailingHttpClient(),
          cacheTtl: const Duration(minutes: 5),
        );

        // Act
        final chains = await failingRepository.getChains();

        // Assert
        expect(chains, hasLength(5)); // 5 default chains
        expect(chains.first, isA<ChainInfo>());

        // Get as CosmosChainInfo to check specific properties
        final cosmosChains = await failingRepository.getCosmosChains();

        // Verify specific factory constructor chains
        final cosmosHub = cosmosChains.firstWhere(
          (chain) => chain.chainId == 'cosmoshub-4',
        );
        expect(cosmosHub.prettyName, 'Cosmos Hub');
        expect(cosmosHub.bech32Prefix, 'cosmos');
        expect(cosmosHub.nativeCurrency, 'uatom');

        final osmosis = cosmosChains.firstWhere(
          (chain) => chain.chainId == 'osmosis-1',
        );
        expect(osmosis.prettyName, 'Osmosis');
        expect(osmosis.bech32Prefix, 'osmo');
        expect(osmosis.nativeCurrency, 'uosmo');

        // Cleanup
        failingRepository.dispose();
      });

      test('should include all expected default chains', () async {
        // Arrange
        final failingRepository = CosmosChainRepository(
          httpClient: _FailingHttpClient(),
          cacheTtl: const Duration(minutes: 5),
        );

        // Act
        final cosmosChains = await failingRepository.getCosmosChains();
        final chainIds = cosmosChains.map((chain) => chain.chainId).toSet();

        // Assert
        expect(chainIds, contains('cosmoshub-4')); // Cosmos Hub
        expect(chainIds, contains('osmosis-1')); // Osmosis
        expect(chainIds, contains('juno-1')); // Juno
        expect(chainIds, contains('akashnet-2')); // Akash
        expect(chainIds, contains('secret-4')); // Secret Network

        // Cleanup
        failingRepository.dispose();
      });

      test('should have all default chains as mainnet', () async {
        // Arrange
        final failingRepository = CosmosChainRepository(
          httpClient: _FailingHttpClient(),
          cacheTtl: const Duration(minutes: 5),
        );

        // Act
        final cosmosChains = await failingRepository.getCosmosChains();

        // Assert
        expect(cosmosChains.every((chain) => chain.isMainnet), isTrue);
        expect(cosmosChains.any((chain) => chain.isTestnet), isFalse);

        // Cleanup
        failingRepository.dispose();
      });
    });

    group('getCosmosChainIds', () {
      test('should return chain IDs in WalletConnect format', () async {
        // Act
        final chainIds = await repository.getCosmosChainIds();

        // Assert
        expect(chainIds, isNotEmpty);
        expect(chainIds.every((id) => id.startsWith('cosmos:')), isTrue);
      });
    });

    group('getCachedCosmosChainIds', () {
      test('should return cached chain IDs without network request', () async {
        // Arrange
        await repository.getChains(); // Populate cache

        // Act
        final chainIds = repository.getCachedCosmosChainIds();

        // Assert
        expect(chainIds, isNotEmpty);
        expect(chainIds.every((id) => id.startsWith('cosmos:')), isTrue);
      });
    });

    group('cache management', () {
      test('should respect cache TTL', () async {
        // Arrange
        final shortTtlRepository = CosmosChainRepository(
          cacheTtl: const Duration(milliseconds: 100),
        );

        // Act
        await shortTtlRepository.getChains();
        expect(shortTtlRepository.isCacheValid, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 150));
        expect(shortTtlRepository.isCacheValid, isFalse);

        // Cleanup
        shortTtlRepository.dispose();
      });

      test('should return cached chains when available', () async {
        // Act & Assert
        expect(repository.getCachedChains(), isEmpty);

        // After fetching, cache should be populated
        await repository.getChains();
        expect(repository.getCachedChains(), isNotEmpty);
      });
    });
  });
}

/// Mock HTTP client that always fails to simulate network errors
class _FailingHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    throw const SocketException('Network error');
  }

  @override
  void close({bool force = false}) {}

  // Implement other required methods as no-ops
  @override
  bool get autoUncompress => throw UnimplementedError();
  @override
  set autoUncompress(bool value) => throw UnimplementedError();
  @override
  Duration? get connectionTimeout => throw UnimplementedError();
  @override
  set connectionTimeout(Duration? value) => throw UnimplementedError();
  @override
  Duration get idleTimeout => throw UnimplementedError();
  @override
  set idleTimeout(Duration value) => throw UnimplementedError();
  @override
  int? get maxConnectionsPerHost => throw UnimplementedError();
  @override
  set maxConnectionsPerHost(int? value) => throw UnimplementedError();
  @override
  String? get userAgent => throw UnimplementedError();
  @override
  set userAgent(String? value) => throw UnimplementedError();
  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) => throw UnimplementedError();
  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) => throw UnimplementedError();
  @override
  set authenticate(Future<bool> Function(Uri, String, String?)? f) =>
      throw UnimplementedError();
  @override
  set authenticateProxy(
    Future<bool> Function(String, int, String, String?)? f,
  ) => throw UnimplementedError();
  @override
  set badCertificateCallback(
    bool Function(X509Certificate, String, int)? callback,
  ) => throw UnimplementedError();
  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => throw UnimplementedError();
  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> headUrl(Uri url) => throw UnimplementedError();
  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) => throw UnimplementedError();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> patchUrl(Uri url) => throw UnimplementedError();
  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> postUrl(Uri url) => throw UnimplementedError();
  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      throw UnimplementedError();
  @override
  Future<HttpClientRequest> putUrl(Uri url) => throw UnimplementedError();
  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(Uri, String?, int?)? f,
  ) => throw UnimplementedError();
  @override
  set keyLog(Function(String)? callback) => throw UnimplementedError();
  @override
  set findProxy(String Function(Uri)? f) => throw UnimplementedError();
}
