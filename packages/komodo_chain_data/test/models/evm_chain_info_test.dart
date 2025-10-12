import 'package:komodo_chain_data/src/models/evm_chain_info.dart';
import 'package:test/test.dart';

import '../fixtures/evm_chain_fixtures.dart';

void main() {
  group('EvmChainInfo', () {
    group('factory constructors', () {
      test('ethereum should return correct chain information', () {
        // Act
        final chain = EvmChainInfo.ethereum();

        // Assert
        expect(chain.chainId, 1);
        expect(chain.name, 'Ethereum Mainnet');
        expect(chain.networkId, 1);
        expect(chain.shortName, 'eth');
        expect(chain.rpc, ['https://mainnet.infura.io/v3/']);
        expect(chain.nativeCurrency.name, 'Ether');
        expect(chain.nativeCurrency.symbol, 'ETH');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://ethereum.org');
        expect(chain.walletConnectChainId, 'eip155:1');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
      });

      test('polygon should return correct chain information', () {
        // Act
        final chain = EvmChainInfo.polygon();

        // Assert
        expect(chain.chainId, 137);
        expect(chain.name, 'Polygon Mainnet');
        expect(chain.networkId, 137);
        expect(chain.shortName, 'matic');
        expect(chain.rpc, ['https://polygon-rpc.com/']);
        expect(chain.nativeCurrency.name, 'MATIC');
        expect(chain.nativeCurrency.symbol, 'MATIC');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://polygon.technology');
        expect(chain.walletConnectChainId, 'eip155:137');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
      });

      test('bnbSmartChain should return correct chain information', () {
        // Act
        final chain = EvmChainInfo.bnbSmartChain();

        // Assert
        expect(chain.chainId, 56);
        expect(chain.name, 'BNB Smart Chain Mainnet');
        expect(chain.networkId, 56);
        expect(chain.shortName, 'bnb');
        expect(chain.rpc, ['https://bsc-dataseed1.binance.org/']);
        expect(chain.nativeCurrency.name, 'BNB Chain Native Token');
        expect(chain.nativeCurrency.symbol, 'BNB');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://www.bnbchain.org/en');
        expect(chain.walletConnectChainId, 'eip155:56');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
      });

      test('avalanche should return correct chain information', () {
        // Act
        final chain = EvmChainInfo.avalanche();

        // Assert
        expect(chain.chainId, 43114);
        expect(chain.name, 'Avalanche C-Chain');
        expect(chain.networkId, 43114);
        expect(chain.shortName, 'avax');
        expect(chain.rpc, ['https://api.avax.network/ext/bc/C/rpc']);
        expect(chain.nativeCurrency.name, 'Avalanche');
        expect(chain.nativeCurrency.symbol, 'AVAX');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://www.avax.network');
        expect(chain.walletConnectChainId, 'eip155:43114');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
      });

      test('fantom should return correct chain information', () {
        // Act
        final chain = EvmChainInfo.fantom();

        // Assert
        expect(chain.chainId, 250);
        expect(chain.name, 'Fantom Opera');
        expect(chain.networkId, 250);
        expect(chain.shortName, 'ftm');
        expect(chain.rpc, ['https://rpc.ftm.tools/']);
        expect(chain.nativeCurrency.name, 'Fantom');
        expect(chain.nativeCurrency.symbol, 'FTM');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://fantom.foundation');
        expect(chain.walletConnectChainId, 'eip155:250');
        expect(chain.isMainnet, isTrue);
        expect(chain.isTestnet, isFalse);
      });
    });

    group('JSON serialization', () {
      test('toJson should produce expected output format', () {
        // Arrange
        final chain = EvmChainInfo.ethereum();

        // Act
        final json = chain.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['chainId'], 1);
        expect(json['name'], 'Ethereum Mainnet');
        expect(json['networkId'], 1);
        expect(json['shortName'], 'eth');
        expect(json['rpc'], ['https://mainnet.infura.io/v3/']);
        expect(json['nativeCurrency'], isA<Map<String, dynamic>>());
        final nativeCurrency = json['nativeCurrency'] as Map<String, dynamic>;
        expect(nativeCurrency['name'], 'Ether');
        expect(nativeCurrency['symbol'], 'ETH');
        expect(nativeCurrency['decimals'], 18);
        expect(json['faucets'], isEmpty);
        expect(json['infoURL'], 'https://ethereum.org');
      });

      test('toJson should handle minimal chain correctly', () {
        // Arrange
        const chain = EvmChainInfo(
          chainId: 999,
          name: 'Test Chain',
          networkId: 999,
          shortName: 'test',
          nativeCurrency: NativeCurrency(
            name: 'Test Token',
            symbol: 'TEST',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Act
        final json = chain.toJson();

        // Assert
        expect(json['chainId'], 999);
        expect(json['name'], 'Test Chain');
        expect(json['networkId'], 999);
        expect(json['shortName'], 'test');
        expect(json['rpc'], isEmpty);
        expect(json['nativeCurrency'], isA<Map<String, dynamic>>());
        final nativeCurrency = json['nativeCurrency'] as Map<String, dynamic>;
        expect(nativeCurrency['name'], 'Test Token');
        expect(nativeCurrency['symbol'], 'TEST');
        expect(nativeCurrency['decimals'], 18);
        expect(json['faucets'], isEmpty);
        expect(json['infoURL'], '');
      });
    });

    group('JSON deserialization', () {
      test('fromJson should work with Ethereum mainnet fixture', () {
        // Act
        final chain = EvmChainInfo.fromJson(EvmChainFixtures.ethereumMainnet);

        // Assert
        expect(chain.chainId, 1);
        expect(chain.name, 'Ethereum Mainnet');
        expect(chain.networkId, 1);
        expect(chain.shortName, 'eth');
        expect(chain.nativeCurrency.name, 'Ether');
        expect(chain.nativeCurrency.symbol, 'ETH');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.rpc, isA<List<String>>());
        expect(chain.rpc.length, greaterThan(0));
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://ethereum.org');
        expect(chain.walletConnectChainId, 'eip155:1');
      });

      test('fromJson should work with BNB Smart Chain fixture', () {
        // Act
        final chain = EvmChainInfo.fromJson(EvmChainFixtures.bnbSmartChain);

        // Assert
        expect(chain.chainId, 56);
        expect(chain.name, 'BNB Smart Chain Mainnet');
        expect(chain.networkId, 56);
        expect(chain.shortName, 'bnb');
        expect(chain.nativeCurrency.name, 'BNB Chain Native Token');
        expect(chain.nativeCurrency.symbol, 'BNB');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.rpc, isA<List<String>>());
        expect(chain.rpc.length, greaterThan(0));
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://www.bnbchain.org/en');
        expect(chain.walletConnectChainId, 'eip155:56');
      });

      test('fromJson should work with Polygon mainnet fixture', () {
        // Act
        final chain = EvmChainInfo.fromJson(EvmChainFixtures.polygonMainnet);

        // Assert
        expect(chain.chainId, 137);
        expect(chain.name, 'Polygon Mainnet');
        expect(chain.networkId, 137);
        expect(chain.shortName, 'matic');
        expect(chain.nativeCurrency.name, 'MATIC');
        expect(chain.nativeCurrency.symbol, 'MATIC');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.rpc, isA<List<String>>());
        expect(chain.rpc.length, greaterThan(0));
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, 'https://polygon.technology/');
        expect(chain.walletConnectChainId, 'eip155:137');
      });

      test('fromJson should work with testnet fixture (Goerli)', () {
        // Act
        final chain = EvmChainInfo.fromJson(EvmChainFixtures.goerliTestnet);

        // Assert
        expect(chain.chainId, 5);
        expect(chain.name, 'Goerli');
        expect(chain.networkId, 5);
        expect(chain.shortName, 'gor');
        expect(chain.nativeCurrency.name, 'Goerli Ether');
        expect(chain.nativeCurrency.symbol, 'ETH');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.rpc, isA<List<String>>());
        expect(chain.rpc.length, greaterThan(0));
        expect(chain.faucets, isA<List<String>>());
        expect(chain.faucets.length, greaterThan(0));
        expect(chain.infoURL, 'https://goerli.net/#about');
        expect(chain.walletConnectChainId, 'eip155:5');
        expect(chain.isTestnet, isTrue);
        expect(chain.isMainnet, isFalse);
      });

      test('fromJson should work with minimal chain fixture', () {
        // Act
        final chain = EvmChainInfo.fromJson(EvmChainFixtures.minimalChain);

        // Assert
        expect(chain.chainId, 999);
        expect(chain.name, 'Test Chain');
        expect(chain.networkId, 999);
        expect(chain.shortName, 'test');
        expect(chain.nativeCurrency.name, 'Test Token');
        expect(chain.nativeCurrency.symbol, 'TEST');
        expect(chain.nativeCurrency.decimals, 18);
        expect(chain.rpc, isEmpty);
        expect(chain.faucets, isEmpty);
        expect(chain.infoURL, '');
        expect(chain.walletConnectChainId, 'eip155:999');
      });
    });

    group('schema validation', () {
      test('should match chainid.network API schema structure', () {
        // Arrange
        final chain = EvmChainInfo.ethereum();
        final expectedKeys = {
          'name',
          'chainId',
          'shortName',
          'networkId',
          'nativeCurrency',
          'rpc',
          'faucets',
          'infoURL',
        };

        // Act
        final json = chain.toJson();

        // Assert - Check that all expected keys are present
        for (final key in expectedKeys) {
          expect(json.containsKey(key), isTrue, reason: 'Missing key: $key');
        }

        // Verify correct field names match API schema
        expect(json.containsKey('chainId'), isTrue);
        expect(json.containsKey('networkId'), isTrue);
        expect(json.containsKey('shortName'), isTrue);
        expect(json.containsKey('nativeCurrency'), isTrue);
        expect(json.containsKey('infoURL'), isTrue);

        // Verify nativeCurrency structure
        expect(json['nativeCurrency'], isA<Map<String, dynamic>>());
        final nativeCurrency = json['nativeCurrency'] as Map<String, dynamic>;
        expect(nativeCurrency.containsKey('name'), isTrue);
        expect(nativeCurrency.containsKey('symbol'), isTrue);
        expect(nativeCurrency.containsKey('decimals'), isTrue);
      });

      test('should handle all required fields from API schema', () {
        // Arrange - Using real API fixture
        const apiData = EvmChainFixtures.ethereumMainnet;

        // Act
        final chain = EvmChainInfo.fromJson(apiData);

        // Assert - All required fields should be present
        expect(chain.name, isNotEmpty);
        expect(chain.chainId, isPositive);
        expect(chain.shortName, isNotEmpty);
        expect(chain.networkId, isPositive);
        expect(chain.nativeCurrency.name, isNotEmpty);
        expect(chain.nativeCurrency.symbol, isNotEmpty);
        expect(chain.nativeCurrency.decimals, isPositive);
        expect(chain.rpc, isA<List<String>>());
        expect(chain.faucets, isA<List<String>>());
        expect(chain.infoURL, isNotEmpty);
      });

      test('should roundtrip serialize/deserialize correctly', () {
        // Arrange
        final originalChain = EvmChainInfo.fromJson(
          EvmChainFixtures.bnbSmartChain,
        );

        // Act
        final json = originalChain.toJson();
        final deserializedChain = EvmChainInfo.fromJson(json);

        // Assert
        expect(deserializedChain, equals(originalChain));
        expect(deserializedChain.chainId, originalChain.chainId);
        expect(deserializedChain.name, originalChain.name);
        expect(
          deserializedChain.nativeCurrency.symbol,
          originalChain.nativeCurrency.symbol,
        );
        expect(deserializedChain.rpc, originalChain.rpc);
        expect(deserializedChain.faucets, originalChain.faucets);
      });
    });

    group('network type detection', () {
      test('should correctly identify mainnet chains', () {
        // Arrange & Act
        final mainnetChain = EvmChainInfo.fromJson(
          EvmChainFixtures.ethereumMainnet,
        );

        // Assert
        expect(mainnetChain.isMainnet, isTrue);
        expect(mainnetChain.isTestnet, isFalse);
      });

      test('should correctly identify testnet chains by name - goerli', () {
        // Arrange & Act
        final testnetChain = EvmChainInfo.fromJson(
          EvmChainFixtures.goerliTestnet,
        );

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });

      test('should correctly identify testnet chains by name - sepolia', () {
        // Arrange & Act
        const testnetChain = EvmChainInfo(
          chainId: 11155111,
          name: 'Sepolia',
          networkId: 11155111,
          shortName: 'sep',
          nativeCurrency: NativeCurrency(
            name: 'Sepolia Ether',
            symbol: 'ETH',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });

      test(
        'should correctly identify testnet chains by name - test keyword',
        () {
          // Arrange & Act
          final testnetChain = EvmChainInfo.fromJson(
            EvmChainFixtures.bnbTestnet,
          );

          // Assert
          expect(testnetChain.isTestnet, isTrue);
          expect(testnetChain.isMainnet, isFalse);
        },
      );

      test('should correctly identify testnet chains by name - rinkeby', () {
        // Arrange & Act
        const testnetChain = EvmChainInfo(
          chainId: 4,
          name: 'Rinkeby',
          networkId: 4,
          shortName: 'rin',
          nativeCurrency: NativeCurrency(
            name: 'Rinkeby Ether',
            symbol: 'ETH',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });

      test('should correctly identify testnet chains by name - kovan', () {
        // Arrange & Act
        const testnetChain = EvmChainInfo(
          chainId: 42,
          name: 'Kovan',
          networkId: 42,
          shortName: 'kov',
          nativeCurrency: NativeCurrency(
            name: 'Kovan Ether',
            symbol: 'ETH',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });

      test('should correctly identify testnet chains by name - ropsten', () {
        // Arrange & Act
        const testnetChain = EvmChainInfo(
          chainId: 3,
          name: 'Ropsten',
          networkId: 3,
          shortName: 'rop',
          nativeCurrency: NativeCurrency(
            name: 'Ropsten Ether',
            symbol: 'ETH',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Assert
        expect(testnetChain.isTestnet, isTrue);
        expect(testnetChain.isMainnet, isFalse);
      });
    });

    group('walletConnectChainId', () {
      test('should format chain ID correctly', () {
        // Arrange
        const chain = EvmChainInfo(
          chainId: 999,
          name: 'Custom Chain',
          networkId: 999,
          shortName: 'custom',
          nativeCurrency: NativeCurrency(
            name: 'Custom Token',
            symbol: 'CUSTOM',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Act & Assert
        expect(chain.walletConnectChainId, 'eip155:999');
      });

      test('should format chain ID correctly for real chains', () {
        // Arrange
        final ethereumChain = EvmChainInfo.fromJson(
          EvmChainFixtures.ethereumMainnet,
        );
        final bnbChain = EvmChainInfo.fromJson(EvmChainFixtures.bnbSmartChain);

        // Act & Assert
        expect(ethereumChain.walletConnectChainId, 'eip155:1');
        expect(bnbChain.walletConnectChainId, 'eip155:56');
      });
    });

    group('equality and immutability', () {
      test('should support equality comparison', () {
        // Arrange
        final chain1 = EvmChainInfo.ethereum();
        final chain2 = EvmChainInfo.ethereum();
        const chain3 = EvmChainInfo(
          chainId: 999,
          name: 'Different Chain',
          networkId: 999,
          shortName: 'diff',
          nativeCurrency: NativeCurrency(
            name: 'Different Token',
            symbol: 'DIFF',
            decimals: 18,
          ),
          rpc: [],
          faucets: [],
          infoURL: '',
        );

        // Act & Assert
        expect(chain1, equals(chain2));
        expect(chain1, isNot(equals(chain3)));
      });

      test('should support copyWith functionality', () {
        // Arrange
        final original = EvmChainInfo.ethereum();

        // Act
        final modified = original.copyWith(
          name: 'Modified Ethereum',
          rpc: ['https://custom-rpc.com'],
        );

        // Assert
        expect(modified.chainId, original.chainId); // Unchanged
        expect(modified.name, 'Modified Ethereum'); // Changed
        expect(modified.rpc, ['https://custom-rpc.com']); // Changed
        expect(modified.networkId, original.networkId); // Unchanged
        expect(modified.shortName, original.shortName); // Unchanged
        expect(modified.nativeCurrency, original.nativeCurrency); // Unchanged
      });

      test('should have consistent hashCode', () {
        // Arrange
        final chain1 = EvmChainInfo.ethereum();
        final chain2 = EvmChainInfo.ethereum();

        // Act & Assert
        expect(chain1.hashCode, equals(chain2.hashCode));
      });

      test('should support deep equality for nested objects', () {
        // Arrange
        final chain1 = EvmChainInfo.fromJson(EvmChainFixtures.ethereumMainnet);
        final chain2 = EvmChainInfo.fromJson(EvmChainFixtures.ethereumMainnet);

        // Act & Assert
        expect(chain1, equals(chain2));
        expect(chain1.nativeCurrency, equals(chain2.nativeCurrency));
        expect(chain1.hashCode, equals(chain2.hashCode));
      });
    });

    group('NativeCurrency', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        const currency = NativeCurrency(
          name: 'Ether',
          symbol: 'ETH',
          decimals: 18,
        );

        // Act
        final json = currency.toJson();
        final deserialized = NativeCurrency.fromJson(json);

        // Assert
        expect(deserialized, equals(currency));
        expect(json['name'], 'Ether');
        expect(json['symbol'], 'ETH');
        expect(json['decimals'], 18);
      });

      test('should support equality comparison', () {
        // Arrange
        const currency1 = NativeCurrency(
          name: 'Ether',
          symbol: 'ETH',
          decimals: 18,
        );
        const currency2 = NativeCurrency(
          name: 'Ether',
          symbol: 'ETH',
          decimals: 18,
        );
        const currency3 = NativeCurrency(
          name: 'MATIC',
          symbol: 'MATIC',
          decimals: 18,
        );

        // Act & Assert
        expect(currency1, equals(currency2));
        expect(currency1, isNot(equals(currency3)));
        expect(currency1.hashCode, equals(currency2.hashCode));
      });
    });
  });
}
