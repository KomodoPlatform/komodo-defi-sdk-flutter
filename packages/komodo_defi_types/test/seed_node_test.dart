import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

void main() {
  group('SeedNode', () {
    test('should create SeedNode from JSON', () {
      final json = {
        'name': 'seed-node-1',
        'host': 'seed01.kmdefi.net',
        'contact': [
          {'email': 'admin@example.com'}
        ]
      };

      final seedNode = SeedNode.fromJson(json);

      expect(seedNode.name, equals('seed-node-1'));
      expect(seedNode.host, equals('seed01.kmdefi.net'));
      expect(seedNode.contact.length, equals(1));
      expect(seedNode.contact.first.email, equals('admin@example.com'));
    });

    test('should convert SeedNode to JSON', () {
      final seedNode = SeedNode(
        name: 'seed-node-2',
        host: 'seed02.kmdefi.net',
        contact: [
          SeedNodeContact(email: 'test@example.com'),
        ],
      );

      final json = seedNode.toJson();

      expect(json['name'], equals('seed-node-2'));
      expect(json['host'], equals('seed02.kmdefi.net'));
      expect(json['contact'], isA<List<dynamic>>());
      expect((json['contact'] as List).length, equals(1));
      expect(
          (json['contact'] as List).first['email'], equals('test@example.com'));
    });

    test('should create list of SeedNodes from JSON list', () {
      final jsonList = [
        {
          'name': 'seed-node-1',
          'host': 'seed01.kmdefi.net',
          'contact': [
            {'email': ''}
          ]
        },
        {
          'name': 'seed-node-2',
          'host': 'seed02.kmdefi.net',
          'contact': [
            {'email': ''}
          ]
        }
      ];

      final seedNodes = SeedNode.fromJsonList(jsonList);

      expect(seedNodes.length, equals(2));
      expect(seedNodes[0].name, equals('seed-node-1'));
      expect(seedNodes[0].host, equals('seed01.kmdefi.net'));
      expect(seedNodes[1].name, equals('seed-node-2'));
      expect(seedNodes[1].host, equals('seed02.kmdefi.net'));
    });

    test('should handle equality correctly', () {
      final seedNode1 = SeedNode(
        name: 'test',
        host: 'example.com',
        contact: [SeedNodeContact(email: 'test@example.com')],
      );

      final seedNode2 = SeedNode(
        name: 'test',
        host: 'example.com',
        contact: [SeedNodeContact(email: 'test@example.com')],
      );

      final seedNode3 = SeedNode(
        name: 'different',
        host: 'example.com',
        contact: [SeedNodeContact(email: 'test@example.com')],
      );

      expect(seedNode1, equals(seedNode2));
      expect(seedNode1, isNot(equals(seedNode3)));
    });
  });

  group('SeedNodeContact', () {
    test('should create SeedNodeContact from JSON', () {
      final json = {'email': 'test@example.com'};
      final contact = SeedNodeContact.fromJson(json);

      expect(contact.email, equals('test@example.com'));
    });

    test('should convert SeedNodeContact to JSON', () {
      final contact = SeedNodeContact(email: 'test@example.com');
      final json = contact.toJson();

      expect(json['email'], equals('test@example.com'));
    });
  });
}
