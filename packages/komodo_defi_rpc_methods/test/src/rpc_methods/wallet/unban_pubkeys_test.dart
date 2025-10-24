import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:test/test.dart';

void main() {
  group('UnbanPubkeysRequest', () {
    test('creates correct JSON for "All" type', () {
      final request = UnbanPubkeysRequest(
        rpcPass: 'RPC_UserP@SSW0RD',
        unbanBy: const UnbanBy.all(),
      );

      final json = request.toJson();

      expect(json['method'], 'unban_pubkeys');
      expect(json['rpc_pass'], 'RPC_UserP@SSW0RD');
      expect(json['unban_by'], {'type': 'All'});
    });

    test('creates correct JSON for "Few" type with data', () {
      final pubkeys = [
        '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420',
        '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
      ];

      final request = UnbanPubkeysRequest(
        rpcPass: 'RPC_UserP@SSW0RD',
        unbanBy: UnbanBy.few(pubkeys),
      );

      final json = request.toJson();

      expect(json['method'], 'unban_pubkeys');
      expect(json['rpc_pass'], 'RPC_UserP@SSW0RD');
      expect(json['unban_by'], {'type': 'Few', 'data': pubkeys});
    });
  });

  group('UnbanPubkeysResponse', () {
    test('parses response with empty still_banned correctly', () {
      final responseJson = {
        'result': {
          'still_banned': <String, dynamic>{},
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'were_not_banned': <String>[],
        },
      };

      final response = UnbanPubkeysResponse.parse(responseJson);

      expect(response.result.stillBanned, isEmpty);
      expect(response.result.unbanned, hasLength(1));
      expect(
        response
            .result
            .unbanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420'],
        isNotNull,
      );
      expect(
        response
            .result
            .unbanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420']!
            .type,
        'Manual',
      );
      expect(
        response
            .result
            .unbanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420']!
            .reason,
        'testing',
      );
      expect(response.result.wereNotBanned, isEmpty);
    });

    test('parses complex response correctly', () {
      final responseJson = {
        'result': {
          'still_banned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520421':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'were_not_banned': [
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
          ],
        },
      };

      final response = UnbanPubkeysResponse.parse(responseJson);

      // Check still_banned
      expect(response.result.stillBanned, hasLength(1));
      expect(
        response
            .result
            .stillBanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520421']!
            .type,
        'Manual',
      );
      expect(
        response
            .result
            .stillBanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520421']!
            .reason,
        'testing',
      );

      // Check unbanned
      expect(response.result.unbanned, hasLength(1));
      expect(
        response
            .result
            .unbanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420']!
            .type,
        'Manual',
      );
      expect(
        response
            .result
            .unbanned['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420']!
            .reason,
        'testing',
      );

      // Check were_not_banned
      expect(response.result.wereNotBanned, hasLength(1));
      expect(
        response.result.wereNotBanned[0],
        '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
      );
    });

    test('serializes response back to JSON correctly', () {
      final original = {
        'result': {
          'still_banned': <String, dynamic>{},
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'were_not_banned': <String>[],
        },
      };

      final response = UnbanPubkeysResponse.parse(original);
      final serialized = response.toJson();

      expect(serialized['result']['still_banned'], isEmpty);
      expect(serialized['result']['unbanned'], hasLength(1));
      expect(
        serialized['result']['unbanned']['2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420'],
        {'type': 'Manual', 'reason': 'testing'},
      );
      expect(serialized['result']['were_not_banned'], isEmpty);
    });
  });

  group('UnbanType', () {
    test('toString returns correct case', () {
      expect(UnbanType.all.toString(), 'All');
      expect(UnbanType.few.toString(), 'Few');
    });

    test('parse handles case insensitive input', () {
      expect(UnbanType.parse('all'), UnbanType.all);
      expect(UnbanType.parse('ALL'), UnbanType.all);
      expect(UnbanType.parse('All'), UnbanType.all);
      expect(UnbanType.parse('few'), UnbanType.few);
      expect(UnbanType.parse('FEW'), UnbanType.few);
      expect(UnbanType.parse('Few'), UnbanType.few);
    });

    test('parse throws for invalid input', () {
      expect(() => UnbanType.parse('invalid'), throwsArgumentError);
      expect(() => UnbanType.parse(''), throwsArgumentError);
    });
  });

  group('UnbanBy', () {
    test('all constructor sets correct values', () {
      const unbanBy = UnbanBy.all();
      expect(unbanBy.type, UnbanType.all);
      expect(unbanBy.data, isNull);
    });

    test('few constructor sets correct values', () {
      final pubkeys = ['pubkey1', 'pubkey2'];
      final unbanBy = UnbanBy.few(pubkeys);
      expect(unbanBy.type, UnbanType.few);
      expect(unbanBy.data, pubkeys);
    });

    test('toJson works correctly for all type', () {
      const unbanBy = UnbanBy.all();
      final json = unbanBy.toJson();
      expect(json, {'type': 'All'});
    });

    test('toJson works correctly for few type', () {
      final pubkeys = ['pubkey1', 'pubkey2'];
      final unbanBy = UnbanBy.few(pubkeys);
      final json = unbanBy.toJson();
      expect(json, {'type': 'Few', 'data': pubkeys});
    });
  });

  group('BannedPubkeyInfo', () {
    test('fromJson and toJson work correctly with reason', () {
      final json = {'type': 'Manual', 'reason': 'testing'};
      final info = BannedPubkeyInfo.fromJson(json);

      expect(info.type, 'Manual');
      expect(info.reason, 'testing');
      expect(info.toJson(), json);
    });

    test('fromJson and toJson work correctly without reason', () {
      final json = {'type': 'Manual'};
      final info = BannedPubkeyInfo.fromJson(json);

      expect(info.type, 'Manual');
      expect(info.reason, isNull);
      expect(info.toJson(), {'type': 'Manual'});
    });

    test('fromJson handles missing reason field gracefully', () {
      final json = {'type': 'Automatic'};
      final info = BannedPubkeyInfo.fromJson(json);

      expect(info.type, 'Automatic');
      expect(info.reason, isNull);
    });
  });

  group('API Documentation Compliance', () {
    test('request matches API documentation example 1', () {
      final request = UnbanPubkeysRequest(
        rpcPass: 'RPC_UserP@SSW0RD',
        unbanBy: const UnbanBy.all(),
      );

      final json = request.toJson();

      // Should match: {"userpass": "RPC_UserP@SSW0RD", "method": "unban_pubkeys", "unban_by": {"type": "All"}}
      expect(json['rpc_pass'], 'RPC_UserP@SSW0RD');
      expect(json['method'], 'unban_pubkeys');
      expect(json['unban_by']['type'], 'All');
      expect(json['unban_by'].containsKey('data'), false);
    });

    test('request matches API documentation example 2', () {
      final pubkeys = [
        '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420',
        '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
      ];

      final request = UnbanPubkeysRequest(
        rpcPass: 'RPC_UserP@SSW0RD',
        unbanBy: UnbanBy.few(pubkeys),
      );

      final json = request.toJson();

      // Should match API documentation structure
      expect(json['rpc_pass'], 'RPC_UserP@SSW0RD');
      expect(json['method'], 'unban_pubkeys');
      expect(json['unban_by']['type'], 'Few');
      expect(json['unban_by']['data'], pubkeys);
    });

    test('response matches API documentation example 1', () {
      final apiResponseJson = {
        'result': {
          'still_banned': JsonMap(),
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'were_not_banned': <String>[],
        },
      };

      final response = UnbanPubkeysResponse.parse(apiResponseJson);

      // Verify structure matches documentation
      expect(response.result.stillBanned, isEmpty);
      expect(response.result.unbanned, hasLength(1));
      expect(response.result.wereNotBanned, isEmpty);

      final pubkey =
          '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420';
      expect(response.result.unbanned[pubkey]!.type, 'Manual');
      expect(response.result.unbanned[pubkey]!.reason, 'testing');
    });

    test('response matches API documentation example 2', () {
      final apiResponseJson = {
        'result': {
          'still_banned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520421':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'were_not_banned': [
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
          ],
        },
      };

      final response = UnbanPubkeysResponse.parse(apiResponseJson);

      // Verify structure matches documentation
      expect(response.result.stillBanned, hasLength(1));
      expect(response.result.unbanned, hasLength(1));
      expect(response.result.wereNotBanned, hasLength(1));

      // Check still_banned
      final stillBannedPubkey =
          '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520421';
      expect(response.result.stillBanned[stillBannedPubkey]!.type, 'Manual');
      expect(response.result.stillBanned[stillBannedPubkey]!.reason, 'testing');

      // Check unbanned
      final unbannedPubkey =
          '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420';
      expect(response.result.unbanned[unbannedPubkey]!.type, 'Manual');
      expect(response.result.unbanned[unbannedPubkey]!.reason, 'testing');

      // Check were_not_banned
      expect(
        response.result.wereNotBanned[0],
        '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
      );
    });

    test('round trip serialization preserves structure', () {
      final originalJson = {
        'result': {
          'still_banned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520421':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {'type': 'Manual', 'reason': 'testing'},
          },
          'were_not_banned': [
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520422',
          ],
        },
      };

      final response = UnbanPubkeysResponse.parse(originalJson);
      final serialized = response.toJson();

      // Verify the serialized version matches the original structure
      expect(
        serialized['result']!['still_banned'],
        originalJson['result']!['still_banned'],
      );
      expect(
        serialized['result']!['unbanned'],
        originalJson['result']!['unbanned'],
      );
      expect(
        serialized['result']!['were_not_banned'],
        originalJson['result']!['were_not_banned'],
      );
    });

    test('handles response without reason field gracefully', () {
      final apiResponseJson = {
        'result': {
          'still_banned': JsonMap(),
          'unbanned': {
            '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420':
                {
                  'type': 'Automatic',
                  // No reason field provided
                },
          },
          'were_not_banned': <String>[],
        },
      };

      final response = UnbanPubkeysResponse.parse(apiResponseJson);

      // Should parse successfully without throwing an error
      expect(response.result.stillBanned, isEmpty);
      expect(response.result.unbanned, hasLength(1));
      expect(response.result.wereNotBanned, isEmpty);

      final pubkey =
          '2cd3021a2197361fb70b862c412bc8e44cff6951fa1de45ceabfdd9b4c520420';
      expect(response.result.unbanned[pubkey]!.type, 'Automatic');
      expect(response.result.unbanned[pubkey]!.reason, isNull);

      // Should serialize back without the reason field
      final serialized = response.toJson();
      final unbannedData = serialized['result']!['unbanned'] as Map;
      expect(unbannedData[pubkey], {'type': 'Automatic'});
    });
  });
}
