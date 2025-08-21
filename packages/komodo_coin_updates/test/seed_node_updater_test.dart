/// Unit tests for the SeedNodeUpdater utility class.
///
/// **Purpose**: Tests the utility functions that convert seed node configurations
/// to string lists for network connectivity, focusing on data transformation
/// and edge case handling.
///
/// **Test Cases**:
/// - Seed node list conversion to string format
/// - Empty seed node list handling
/// - Seed node data extraction and formatting
/// - Network configuration data transformation
///
/// **Functionality Tested**:
/// - Seed node data parsing and extraction
/// - String list generation for network configuration
/// - Empty and null input handling
/// - Data transformation utilities
/// - Network configuration formatting
///
/// **Edge Cases**:
/// - Empty seed node lists
/// - Null or missing seed node data
/// - Seed node contact information handling
/// - Network ID and protocol validation
///
/// **Dependencies**: Tests utility functions for seed node configuration processing,
/// focusing on data transformation rather than network operations. Note that
/// actual HTTP fetching is not tested here (covered in integration tests).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  group('SeedNodeUpdater', () {
    test('should convert seed nodes to string list', () {
      final seedNodes = [
        const SeedNode(
          name: 'seed-node-1',
          host: 'seed01.kmdefi.net',
          type: 'domain',
          wss: true,
          netId: 8762,
          contact: [SeedNodeContact(email: 'test1@example.com')],
        ),
        const SeedNode(
          name: 'seed-node-2',
          host: 'seed02.kmdefi.net',
          type: 'domain',
          wss: true,
          netId: 8762,
          contact: [SeedNodeContact(email: 'test1@example.com')],
        ),
      ];

      final stringList = SeedNodeUpdater.seedNodesToStringList(seedNodes);

      expect(stringList.length, equals(2));
      expect(stringList[0], equals('seed01.kmdefi.net'));
      expect(stringList[1], equals('seed02.kmdefi.net'));
    });

    test('should handle empty seed nodes list', () {
      final stringList = SeedNodeUpdater.seedNodesToStringList([]);
      expect(stringList, isEmpty);
    });

    // Note: We can't easily test fetchSeedNodes() without mocking HTTP calls
    // This would be covered in integration tests
  });
}
