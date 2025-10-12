import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_chain_data/src/models/cosmos_asset.dart';
import 'package:komodo_chain_data/src/models/cosmos_chain_info.dart';
import 'package:komodo_chain_data/src/models/cosmos_explorer.dart';

import '../fixtures/cosmos_chain_fixtures.dart';

void main() {
  group('CosmosChainInfo', () {
    group('factory constructors', () {
      test('cosmosHub should return correct chain information', () {
        // Act
        final chain = CosmosChainInfo.cosmosHub();

        // Assert
        expect(chain.chainId, 'cosmoshub-4');
        expect(chain.name, 'cosmoshub');
        expect(chain.chainName, 'cosmoshub');
        expect(chain.prettyName, 'Cosmos Hub');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'cosmos');
        expect(chain.symbol, 'ATOM');
        expect(chain.display, 'atom');
        expect(chain.denom, 'uatom');
        expect(chain.decimals, 6);
        expect(chain.nativeCurrency, 'uatom');
        expect(chain.slip44, 118);
        expect(chain.walletConnectChainId, 'cosmos:cosmoshub-4');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
        expect(chain.primaryRpcEndpoint, 'https://cosmos-rpc.publicnode.com');
        expect(chain.primaryRestEndpoint, 'https://cosmos-rest.publicnode.com');
      });

      test('osmosis should return correct chain information', () {
        // Act
        final chain = CosmosChainInfo.osmosis();

        // Assert
        expect(chain.chainId, 'osmosis-1');
        expect(chain.name, 'osmosis');
        expect(chain.chainName, 'osmosis');
        expect(chain.prettyName, 'Osmosis');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'osmo');
        expect(chain.symbol, 'OSMO');
        expect(chain.display, 'osmo');
        expect(chain.denom, 'uosmo');
        expect(chain.decimals, 6);
        expect(chain.nativeCurrency, 'uosmo');
        expect(chain.slip44, 118);
        expect(chain.walletConnectChainId, 'cosmos:osmosis-1');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
        expect(chain.primaryRpcEndpoint, 'https://osmosis-rpc.polkachu.com');
        expect(chain.primaryRestEndpoint, 'https://osmosis-api.polkachu.com');
      });

      test('akash should return correct chain information', () {
        // Act
        final chain = CosmosChainInfo.akash();

        // Assert
        expect(chain.chainId, 'akashnet-2');
        expect(chain.name, 'akash');
        expect(chain.chainName, 'akash');
        expect(chain.prettyName, 'Akash');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'akash');
        expect(chain.symbol, 'AKT');
        expect(chain.display, 'akt');
        expect(chain.denom, 'uakt');
        expect(chain.decimals, 6);
        expect(chain.nativeCurrency, 'uakt');
        expect(chain.slip44, 118);
        expect(chain.walletConnectChainId, 'cosmos:akashnet-2');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
        expect(
          chain.primaryRpcEndpoint,
          'https://akash-mainnet-rpc.cosmonautstakes.com/',
        );
        expect(
          chain.primaryRestEndpoint,
          'https://akash-mainnet-rest.cosmonautstakes.com/',
        );
      });
    });

    group('JSON serialization', () {
      test('toJson should produce expected output format', () {
        // Arrange
        final chain = CosmosChainInfo.cosmosHub();

        // Act
        final json = chain.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['chain_id'], 'cosmoshub-4');
        expect(json['name'], 'cosmoshub');
        expect(json['chain_name'], 'cosmoshub');
        expect(json['pretty_name'], 'Cosmos Hub');
        expect(json['network_type'], 'mainnet');
        expect(json['status'], 'live');
        expect(json['bech32_prefix'], 'cosmos');
        expect(json['symbol'], 'ATOM');
        expect(json['display'], 'atom');
        expect(json['denom'], 'uatom');
        expect(json['decimals'], 6);
        expect(json['slip44'], 118);
        expect(json['best_apis'], isA<Map<String, dynamic>>());
        expect(json['proxy_status'], isA<Map<String, dynamic>>());
        expect(json['versions'], isA<Map<String, dynamic>>());
      });

      test('toJson should handle optional fields correctly', () {
        // Arrange
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.minimalChain,
        );

        // Act
        final json = chain.toJson();

        // Assert
        expect(json['chain_id'], 'test-1');
        expect(json['name'], 'testchain');
        expect(json['height'], isNull);
        expect(json['image'], isNull);
        expect(json['website'], isNull);
        expect(json['coingecko_id'], isNull);
        expect(json['keywords'], isNull);
        expect(json['prices'], isNull);
        expect(json['services'], isNull);
      });
    });

    group('JSON deserialization', () {
      test('fromJson should work with real Cosmos Hub API data', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.chainId, 'cosmoshub-4');
        expect(chain.name, 'cosmoshub');
        expect(chain.chainName, 'cosmoshub');
        expect(chain.prettyName, 'Cosmos Hub');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'cosmos');
        expect(chain.slip44, 118);
        expect(chain.symbol, 'ATOM');
        expect(chain.display, 'atom');
        expect(chain.denom, 'uatom');
        expect(chain.decimals, 6);
        expect(chain.image, contains('atom.svg'));
        expect(chain.website, 'https://cosmos.network');
        expect(chain.height, 23704830);
        expect(chain.coingeckoId, 'cosmos');
        expect(chain.walletConnectChainId, 'cosmos:cosmoshub-4');
        expect(chain.nativeCurrency, 'uatom');
        expect(chain.primaryRpcEndpoint, 'https://cosmos-rpc.publicnode.com');
        expect(chain.primaryRestEndpoint, 'https://cosmos-rest.publicnode.com');
      });

      test('fromJson should work with Osmosis API data', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.osmosisChain,
        );

        // Assert
        expect(chain.chainId, 'osmosis-1');
        expect(chain.name, 'osmosis');
        expect(chain.chainName, 'osmosis');
        expect(chain.prettyName, 'Osmosis');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'osmo');
        expect(chain.slip44, 118);
        expect(chain.symbol, 'OSMO');
        expect(chain.display, 'osmo');
        expect(chain.denom, 'uosmo');
        expect(chain.decimals, 6);
        expect(chain.image, contains('osmo.svg'));
        expect(chain.website, 'https://osmosis.zone');
        expect(chain.height, 22017642);
        expect(chain.walletConnectChainId, 'cosmos:osmosis-1');
        expect(chain.primaryRpcEndpoint, 'https://osmosis-rpc.polkachu.com');
        expect(chain.primaryRestEndpoint, 'https://osmosis-api.polkachu.com');
      });

      test('fromJson should work with Akash API data', () {
        // Act
        final chain = CosmosChainInfo.fromJson(CosmosChainFixtures.akashChain);

        // Assert
        expect(chain.chainId, 'akashnet-2');
        expect(chain.name, 'akash');
        expect(chain.chainName, 'akash');
        expect(chain.prettyName, 'Akash');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'akash');
        expect(chain.slip44, 118);
        expect(chain.symbol, 'AKT');
        expect(chain.display, 'akt');
        expect(chain.denom, 'uakt');
        expect(chain.decimals, 6);
        expect(chain.coingeckoId, 'akash-network');
        expect(chain.image, contains('akt.svg'));
        expect(chain.website, 'https://akash.network/');
        expect(chain.height, 23704830);
        expect(chain.walletConnectChainId, 'cosmos:akashnet-2');
        expect(chain.prices, isNull); // Akash fixture doesn't have prices
        expect(chain.assets, isA<List<CosmosAsset>>());
        expect(chain.assets!.length, 1);
        expect(chain.assets!.first.symbol, 'AKT');
      });

      test('fromJson should work with minimal data', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.minimalChain,
        );

        // Assert
        expect(chain.chainId, 'test-1');
        expect(chain.name, 'testchain');
        expect(chain.chainName, 'testchain');
        expect(chain.prettyName, 'Test Chain');
        expect(chain.networkType, 'mainnet');
        expect(chain.status, 'live');
        expect(chain.bech32Prefix, 'test');
        expect(chain.slip44, 118);
        expect(chain.symbol, 'TEST');
        expect(chain.display, 'test');
        expect(chain.denom, 'utest');
        expect(chain.decimals, 6);
        expect(chain.height, isNull);
        expect(chain.image, isNull);
        expect(chain.website, isNull);
        expect(chain.coingeckoId, isNull);
        expect(chain.keywords, isNull);
        expect(chain.prices, isNull);
        expect(chain.services, isNull);
        expect(chain.primaryRpcEndpoint, isNull);
        expect(chain.primaryRestEndpoint, isNull);
      });

      test('fromJson should handle assets array correctly', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.assets, isA<List<CosmosAsset>>());
        expect(chain.assets!.length, 1);

        final asset = chain.assets!.first;
        expect(asset.name, 'Cosmos Hub Atom');
        expect(asset.symbol, 'ATOM');
        expect(asset.denom, 'uatom');
        expect(asset.decimals, 6);
        expect(asset.base, isA<CosmosDenomUnit>());
        expect(asset.display, isA<CosmosDenomUnit>());
        expect(asset.denomUnits, isA<List<CosmosDenomUnit>>());
        expect(asset.logoUris, isA<CosmosLogoUris?>());
      });

      test('fromJson should handle explorers array correctly', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.explorers, isA<List<CosmosExplorer>>());
        expect(chain.explorers!.length, 2);

        final explorer = chain.explorers!.first;
        expect(explorer.kind, 'Chainroot');
        expect(explorer.url, contains('explorer.chainroot.io'));
        expect(explorer.txPage, contains(r'${txHash}'));
        expect(explorer.accountPage, contains(r'${accountAddress}'));
      });
    });

    group('API schema validation', () {
      test('should match chains.cosmos.directory schema structure', () {
        // Arrange
        final chain = CosmosChainInfo.cosmosHub();
        final expectedKeys = {
          'name',
          'path',
          'chain_name',
          'network_type',
          'pretty_name',
          'chain_id',
          'status',
          'bech32_prefix',
          'slip44',
          'symbol',
          'display',
          'denom',
          'decimals',
          'best_apis',
          'proxy_status',
          'versions',
        };

        // Act
        final json = chain.toJson();

        // Assert - Check that all required keys are present
        for (final key in expectedKeys) {
          expect(
            json.containsKey(key),
            isTrue,
            reason: 'Missing required key: $key',
          );
        }

        // Verify snake_case conversion
        expect(json.containsKey('chain_id'), isTrue);
        expect(json.containsKey('chainId'), isFalse);
        expect(json.containsKey('chain_name'), isTrue);
        expect(json.containsKey('chainName'), isFalse);
        expect(json.containsKey('pretty_name'), isTrue);
        expect(json.containsKey('prettyName'), isFalse);
        expect(json.containsKey('network_type'), isTrue);
        expect(json.containsKey('networkType'), isFalse);
        expect(json.containsKey('bech32_prefix'), isTrue);
        expect(json.containsKey('best_apis'), isTrue);
        expect(json.containsKey('bestApis'), isFalse);
        expect(json.containsKey('proxy_status'), isTrue);
        expect(json.containsKey('proxyStatus'), isFalse);
        expect(json.containsKey('coingecko_id'), isTrue);
        expect(json.containsKey('coingeckoId'), isFalse);
      });

      test('should handle full API response structure', () {
        // Act
        final response = CosmosChainFixtures.fullApiResponse;
        final chains = response['chains'] as List<dynamic>;
        final firstChain = CosmosChainInfo.fromJson(
          chains.first as Map<String, dynamic>,
        );

        // Assert - Should parse without errors
        expect(firstChain.chainId, 'cosmoshub-4');
        expect(firstChain.name, 'cosmoshub');
        expect(firstChain.walletConnectChainId, 'cosmos:cosmoshub-4');
        expect(firstChain.isMainnet, isTrue);

        // Verify repository structure
        final repository = response['repository'] as Map<String, dynamic>;
        expect(repository['url'], contains('github.com'));
        expect(repository['branch'], 'master');
        expect(repository['commit'], isA<String>());
        expect(repository['timestamp'], isA<int>());
      });
    });

    group('network type detection', () {
      test('should correctly identify mainnet chains', () {
        // Act
        final mainnetChain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(mainnetChain.isMainnet, isTrue);
        expect(mainnetChain.isTestnet, isFalse);
        expect(mainnetChain.networkType, 'mainnet');
      });

      test('should correctly identify testnet chains by networkType', () {
        // Arrange
        final testnetData = Map<String, dynamic>.from(
          CosmosChainFixtures.minimalChain,
        );
        testnetData['network_type'] = 'testnet';
        testnetData['chain_id'] = 'theta-testnet-001';

        // Act
        final testnetChain = CosmosChainInfo.fromJson(testnetData);

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
        expect(testnetChain.networkType, 'testnet');
      });

      test('should correctly identify testnet chains by name', () {
        // Arrange
        final testnetData = Map<String, dynamic>.from(
          CosmosChainFixtures.minimalChain,
        );
        testnetData['name'] = 'osmosis testnet';
        testnetData['chain_id'] = 'osmo-test-4';

        // Act
        final testnetChain = CosmosChainInfo.fromJson(testnetData);

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });

      test('should correctly identify testnet chains by chainId', () {
        // Arrange
        final testnetData = Map<String, dynamic>.from(
          CosmosChainFixtures.minimalChain,
        );
        testnetData['chain_id'] = 'osmo-test-4';

        // Act
        final testnetChain = CosmosChainInfo.fromJson(testnetData);

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });
    });

    group('helper methods', () {
      test('walletConnectChainId should format chain ID correctly', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.walletConnectChainId, 'cosmos:cosmoshub-4');
      });

      test('nativeCurrency should return denom', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.nativeCurrency, 'uatom');
        expect(chain.nativeCurrency, chain.denom);
      });

      test('primaryRpcEndpoint should return first RPC endpoint', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.primaryRpcEndpoint, 'https://cosmos-rpc.publicnode.com');
      });

      test('primaryRestEndpoint should return first REST endpoint', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );

        // Assert
        expect(chain.primaryRestEndpoint, 'https://cosmos-rest.publicnode.com');
      });

      test('primaryRpcEndpoint should return null when no RPC endpoints', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.minimalChain,
        );

        // Assert
        expect(chain.primaryRpcEndpoint, isNull);
      });

      test('primaryRestEndpoint should return null when no REST endpoints', () {
        // Act
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.minimalChain,
        );

        // Assert
        expect(chain.primaryRestEndpoint, isNull);
      });
    });

    group('equality and immutability', () {
      test('should support equality comparison', () {
        // Arrange
        final chain1 = CosmosChainInfo.cosmosHub();
        final chain2 = CosmosChainInfo.cosmosHub();
        final chain3 = CosmosChainInfo.osmosis();

        // Act & Assert
        expect(chain1, equals(chain2));
        expect(chain1, isNot(equals(chain3)));
      });

      test('should support copyWith functionality', () {
        // Arrange
        final original = CosmosChainInfo.cosmosHub();

        // Act
        final modified = original.copyWith(
          name: 'modified-cosmoshub',
          prettyName: 'Modified Cosmos Hub',
        );

        // Assert
        expect(modified.chainId, original.chainId); // Unchanged
        expect(modified.name, 'modified-cosmoshub'); // Changed
        expect(modified.prettyName, 'Modified Cosmos Hub'); // Changed
        expect(modified.bech32Prefix, original.bech32Prefix); // Unchanged
        expect(modified.symbol, original.symbol); // Unchanged
      });

      test('should have consistent hashCode', () {
        // Arrange
        final chain1 = CosmosChainInfo.cosmosHub();
        final chain2 = CosmosChainInfo.cosmosHub();

        // Act & Assert
        expect(chain1.hashCode, equals(chain2.hashCode));
      });

      test('should be immutable', () {
        // Arrange
        final chain = CosmosChainInfo.fromJson(
          CosmosChainFixtures.cosmosHubChain,
        );
        final originalChainId = chain.chainId;

        // Act - Try to modify (this should not be possible with Freezed)
        // The object is immutable, so we can only create new instances
        final modifiedChain = chain.copyWith(chainId: 'modified-chain-id');

        // Assert
        expect(chain.chainId, originalChainId); // Original unchanged
        expect(
          modifiedChain.chainId,
          'modified-chain-id',
        ); // New instance changed
        expect(chain, isNot(equals(modifiedChain))); // Different objects
      });
    });
  });
}
