import 'dart:io';

import 'package:komodo_chain_data/komodo_chain_data.dart';
import 'package:test/test.dart';

void main() {
  group('EvmChainRepository', () {
    late EvmChainRepository repository;

    setUp(() {
      repository = EvmChainRepository(cacheTtl: const Duration(minutes: 5));
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

        // Get as EvmChainInfo to check specific properties
        final evmChains = await repository.getEvmChains();
        expect(evmChains.first, isA<EvmChainInfo>());
        expect(evmChains.every((chain) => chain.isMainnet), isTrue);
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
        final failingRepository = EvmChainRepository(
          httpClient: _FailingHttpClient(),
          cacheTtl: const Duration(minutes: 5),
        );

        // Act
        final chains = await failingRepository.getChains();

        // Assert
        expect(chains, hasLength(5)); // 5 default chains
        expect(chains.first, isA<ChainInfo>());

        // Get as EvmChainInfo to check specific properties
        final evmChains = await failingRepository.getEvmChains();

        // Verify specific factory constructor chains
        final ethereum = evmChains.firstWhere((chain) => chain.chainId == 1);
        expect(ethereum.name, 'Ethereum Mainnet');
        expect(ethereum.shortName, 'eth');
        expect(ethereum.nativeCurrency.symbol, 'ETH');

        final polygon = evmChains.firstWhere((chain) => chain.chainId == 137);
        expect(polygon.name, 'Polygon Mainnet');
        expect(polygon.shortName, 'matic');
        expect(polygon.nativeCurrency.symbol, 'MATIC');

        // Cleanup
        failingRepository.dispose();
      });

      test('should include all expected default chains', () async {
        // Arrange
        final failingRepository = EvmChainRepository(
          httpClient: _FailingHttpClient(),
          cacheTtl: const Duration(minutes: 5),
        );

        // Act
        final evmChains = await failingRepository.getEvmChains();
        final chainIds = evmChains.map((chain) => chain.chainId).toSet();

        // Assert
        expect(chainIds, contains(1)); // Ethereum
        expect(chainIds, contains(137)); // Polygon
        expect(chainIds, contains(56)); // BNB Smart Chain
        expect(chainIds, contains(43114)); // Avalanche
        expect(chainIds, contains(250)); // Fantom

        // Cleanup
        failingRepository.dispose();
      });

      test('should have all default chains as mainnet', () async {
        // Arrange
        final failingRepository = EvmChainRepository(
          httpClient: _FailingHttpClient(),
          cacheTtl: const Duration(minutes: 5),
        );

        // Act
        final evmChains = await failingRepository.getEvmChains();

        // Assert
        expect(evmChains.every((chain) => chain.isMainnet), isTrue);
        expect(evmChains.any((chain) => chain.isTestnet), isFalse);

        // Cleanup
        failingRepository.dispose();
      });
    });

    group('getEvmChainIds', () {
      test('should return chain IDs in WalletConnect format', () async {
        // Act
        final chainIds = await repository.getEvmChainIds();

        // Assert
        expect(chainIds, isNotEmpty);
        expect(chainIds.every((id) => id.startsWith('eip155:')), isTrue);
      });
    });

    group('getCachedEvmChainIds', () {
      test('should return cached chain IDs without network request', () async {
        // Arrange
        await repository.getChains(); // Populate cache

        // Act
        final chainIds = repository.getCachedEvmChainIds();

        // Assert
        expect(chainIds, isNotEmpty);
        expect(chainIds.every((id) => id.startsWith('eip155:')), isTrue);
      });
    });

    group('cache management', () {
      test('should respect cache TTL', () async {
        // Arrange
        final shortTtlRepository = EvmChainRepository(
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
