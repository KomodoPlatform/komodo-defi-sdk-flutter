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
