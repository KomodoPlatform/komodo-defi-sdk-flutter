import 'dart:async';
import 'dart:convert';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_sdk/src/security/private_key_export_request.dart';
import 'package:komodo_defi_sdk/src/security/security_manager.dart';
import 'package:komodo_defi_sdk/src/security/tron_export_key.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _Auth extends Mock implements KomodoDefiLocalAuth {}

class _Activation extends Mock implements SharedActivationCoordinator {}

class _Assets extends Mock implements IAssetProvider {}

class _Client implements ApiClient {
  final requests = <Map<String, dynamic>>[];
  late FutureOr<Map<String, dynamic>> Function(Map<String, dynamic>) respond;
  @override
  Future<Map<String, dynamic>> executeRpc(Map<String, dynamic> request) async {
    requests.add(request);
    return respond(request);
  }
}

Asset tron({String network = 'Mainnet', String ticker = 'TRX'}) =>
    Asset.fromJson({
      'coin': ticker,
      'type': 'TRX',
      'name': 'TRON',
      'fname': 'TRON',
      'wallet_only': true,
      'mm2': 1,
      'decimals': 6,
      'derivation_path': "m/44'/195'",
      'nodes': const <Map<String, dynamic>>[],
      'protocol': {
        'type': 'TRX',
        'protocol_data': {'network': network},
      },
    }, knownIds: const {});

Asset token(Asset parent) => Asset.fromJson(
  {
    'coin': 'USDT-TRC20',
    'type': 'TRC-20',
    'name': 'Tether',
    'fname': 'Tether',
    'wallet_only': true,
    'mm2': 1,
    'decimals': 6,
    'derivation_path': "m/44'/195'",
    'nodes': const <Map<String, dynamic>>[],
    'parent_coin': parent.id.id,
    'protocol': {
      'type': 'TRC20',
      'protocol_data': {
        'platform': parent.id.id,
        'contract_address': 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
      },
    },
  },
  knownIds: {parent.id},
);

Asset utxo(String ticker) => Asset(
  id: AssetId(
    id: ticker,
    name: ticker,
    symbol: AssetSymbol(assetConfigId: ticker),
    chainId: AssetChainId(chainId: 0, decimalsValue: 8),
    derivationPath: "m/44'/0'",
    subClass: CoinSubClass.utxo,
  ),
  protocol: UtxoProtocol.fromJson({
    'type': 'UTXO',
    'protocol': {'type': 'UTXO'},
    'is_testnet': true,
    'electrum': <Map<String, dynamic>>[],
  }),
  isWalletOnly: true,
  signMessagePrefix: null,
);

Map<String, dynamic> offline(String ticker, {int count = 11}) => {
  'mmrpc': '2.0',
  'result': [
    {
      'coin': ticker,
      'addresses': [
        for (var i = 0; i < count; i++)
          {
            'derivation_path': "m/44'/0'/0'/0/$i",
            'pubkey': 'synthetic-public',
            'address': 'synthetic-address-$i',
            'priv_key': 'synthetic-private-$i',
          },
      ],
    },
  ],
};

void main() {
  final trx = tron();
  final usdt = token(trx);
  final btc = utxo('BTC');
  final scalar = '0' * 63 + '1'; // Public fixture, used only with mock RPCs.
  final key = TronExportKey.parse(scalar);
  late _Client client;
  late _Auth auth;
  late _Activation activation;
  late _Assets assets;
  late SecurityManager manager;
  late int generation;
  late KdfUser? user;
  late Map<AssetId, AssetActivationState> states;
  late List<String> enabled;
  late List<Map<String, dynamic>> metadata;

  setUpAll(() {
    registerFallbackValue(trx.id);
  });
  setUp(() {
    generation = 1;
    user = const KdfUser(
      walletId: WalletId(
        name: 'fixture',
        pubkeyHash: 'verified-public-identity',
        authOptions: AuthOptions(derivationMethod: DerivationMethod.hdWallet),
      ),
      isBip39Seed: true,
    );
    auth = _Auth();
    when(() => auth.isAuthTransitionInProgress).thenReturn(false);
    when(() => auth.authGeneration).thenAnswer((_) => generation);
    when(() => auth.currentUser).thenAnswer((_) async => user);
    states = {
      trx.id: AssetActivationState.active(trx.id),
      usdt.id: AssetActivationState.active(usdt.id),
    };
    activation = _Activation();
    when(() => activation.activationStates).thenAnswer((_) => states);
    assets = _Assets();
    final catalog = {
      for (final a in [trx, usdt, btc]) a.id: a,
    };
    when(
      () => assets.fromId(any()),
    ).thenAnswer((call) => catalog[call.positionalArguments[0]]);
    when(() => assets.findAssetsByConfigId(any())).thenAnswer(
      (call) => catalog.values
          .where((a) => a.id.id == call.positionalArguments[0])
          .toSet(),
    );
    when(
      () => assets.getActivatedAssets(),
    ).thenAnswer((_) async => [btc, trx, usdt]);
    enabled = ['TRX', 'USDT-TRC20'];
    metadata = [
      {
        'address': key.address,
        'derivation_path': "m/44'/195'/0'/0/7",
        'chain': 'External',
      },
    ];
    client = _Client();
    client.respond = (request) {
      switch (request['method']) {
        case 'get_private_keys':
          return offline((request['params'] as Map)['coins'][0] as String);
        case 'get_enabled_coins':
          return {
            'mmrpc': '2.0',
            'result': {
              'coins': [
                for (final ticker in enabled) {'ticker': ticker},
              ],
            },
          };
        case 'show_priv_key':
          return {
            'result': {'coin': request['coin'], 'priv_key': scalar},
          };
        case 'account_balance':
          return {
            'mmrpc': '2.0',
            'result': {
              'account_index': 0,
              'total_pages': 1,
              'addresses': metadata,
            },
          };
        default:
          throw StateError('Unexpected RPC');
      }
    };
    manager = SecurityManager(client, auth, assets, activation);
  });

  test(
    'mixed export preserves offline range and verifies one shared active TRON key',
    () async {
      final result = await manager.exportPrivateKeys();
      expect(result.isComplete, isTrue);
      expect(result.hasLimitedCoverage, isTrue);
      expect(result.keysByAsset[btc.id], hasLength(11));
      expect(
        result.keysByAsset[trx.id]!.single.hdInfo!.derivationPath,
        "m/44'/195'/0'/0/7",
      );
      expect(result.keysByAsset[usdt.id]!.single.privateKey, scalar);
      expect(result.outcomes.last.signingAssetId, trx.id);
      expect(
        client.requests.where((r) => r['method'] == 'show_priv_key'),
        hasLength(1),
      );
      expect(
        client.requests.any((r) => (r['method'] as String).contains('enable')),
        isTrue,
      ); // get_enabled_coins only
      expect(client.requests.map((r) => r['method']).toSet(), {
        'get_private_keys',
        'get_enabled_coins',
        'show_priv_key',
        'account_balance',
      });
    },
  );

  test('valid scalar and public address vector, leading zeros preserved', () {
    expect(key.privateKey, scalar);
    expect(key.address, 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC');
    expect(key.publicKey.startsWith('0479be667e'), isTrue);
    for (final invalid in ['', '00', '0' * 64, 'f' * 64, 'z' * 64]) {
      expect(() => TronExportKey.parse(invalid), throwsFormatException);
    }
  });

  test('partial export retains BTC when TRON metadata is unrelated', () async {
    metadata = [
      {
        'address': 'unrelated',
        'derivation_path': "m/44'/195'/0'/0/0",
        'chain': 'External',
      },
    ];
    final result = await manager.exportPrivateKeys();
    expect(result.isComplete, isFalse);
    expect(result.keysByAsset.keys, [btc.id]);
    expect(
      result.outcomes.last.failure,
      PrivateKeyExportFailure.metadataUnverified,
    );
  });

  test(
    'same address with wrong coin path cannot authenticate a TRON key',
    () async {
      metadata.single['derivation_path'] = "m/44'/60'/0'/0/7";
      final result = await manager.exportPrivateKeys();
      expect(
        result.outcomes[1].failure,
        PrivateKeyExportFailure.metadataUnverified,
      );
    },
  );

  test(
    'unactivated and failed assets do not trigger activation or key retrieval',
    () async {
      states[trx.id] = AssetActivationState.failed(trx.id);
      enabled = [];
      final result = await manager.exportPrivateKeys();
      expect(
        result.outcomes[1].failure,
        PrivateKeyExportFailure.activationFailed,
      );
      expect(
        result.outcomes[2].failure,
        PrivateKeyExportFailure.activationFailed,
      );
      expect(
        client.requests.any((r) => r['method'] == 'show_priv_key'),
        isFalse,
      );
    },
  );

  test('explicit range refuses narrower TRON substitution', () async {
    final result = await manager.exportPrivateKeys(
      request: PrivateKeyExportRequest(
        assets: [trx.id],
        startIndex: 7,
        endIndex: 7,
      ),
    );
    expect(
      result.outcomes.single.failure,
      PrivateKeyExportFailure.requestedCoverageUnavailable,
    );
    expect(client.requests, isEmpty);
  });

  test('strict compatibility map never invokes online fallback', () async {
    client.respond = (_) => {'error': 'unsupported synthetic protocol'};
    await expectLater(
      manager.getPrivateKeys(assets: [trx.id]),
      throwsA(anything),
    );
    expect(client.requests.map((r) => r['method']), ['get_private_keys']);
  });

  test('default mode still validates malformed range before RPC', () async {
    await expectLater(
      manager.exportPrivateKeys(
        request: const PrivateKeyExportRequest(startIndex: 0, endIndex: 101),
      ),
      throwsArgumentError,
    );
    expect(client.requests, isEmpty);
  });

  test(
    'rejects a truncated offline response rather than claiming full range',
    () async {
      client.respond = (_) => offline('BTC', count: 1);
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [btc.id]),
      );
      expect(
        result.outcomes.single.failure,
        PrivateKeyExportFailure.invalidResponse,
      );
    },
  );

  test(
    'session transition while RPC pending discards every asset result',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      client.respond = (_) => pending.future;
      final operation = manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [btc.id]),
      );
      await Future<void>.delayed(Duration.zero);
      generation++; // Includes sign-out/sign-in to the same identity.
      pending.complete(offline('BTC'));
      await expectLater(
        operation,
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
    },
  );

  test('identity degradation with unchanged generation fails closed', () async {
    final session = await manager.captureExportSession();
    user = KdfUser(
      walletId: WalletId(
        name: 'fixture',
        authOptions: user!.walletId.authOptions,
      ),
      isBip39Seed: true,
    );
    await expectLater(
      manager.ensureExportSessionCurrent(session),
      throwsA(isA<PrivateKeyExportSessionChangedException>()),
    );
  });

  test(
    'diagnostics stay redacted while deliberate recovery JSON retains keys',
    () async {
      final result = await manager.exportPrivateKeys();
      {
        expect(result.toString(), isNot(contains(scalar)));
        expect(result.outcomes.toString(), isNot(contains(scalar)));
        expect(result.keysByAsset.toString(), isNot(contains(scalar)));
        expect(jsonEncode(result.toJson()), contains(scalar));
      }
    },
  );
  test(
    'offline concurrency is bounded at two and requested order preserved',
    () async {
      final coins = [btc, utxo('KMD'), utxo('LTC'), utxo('DOGE')];
      for (final coin in coins) {
        when(() => assets.fromId(coin.id)).thenReturn(coin);
      }
      var current = 0;
      var maximum = 0;
      client.respond = (request) async {
        current++;
        if (current > maximum) maximum = current;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        current--;
        return offline((request['params'] as Map)['coins'][0] as String);
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(
          assets: coins.map((coin) => coin.id).toList(),
        ),
      );
      expect(maximum, 2);
      expect(result.isComplete, isTrue);
      expect(
        result.outcomes.map((outcome) => outcome.assetId),
        coins.map((coin) => coin.id),
      );
    },
  );

  test(
    'session change during enabled read prevents secret retrieval',
    () async {
      client.respond = (request) {
        generation++;
        return {
          'mmrpc': '2.0',
          'result': {
            'coins': [
              {'ticker': 'TRX'},
            ],
          },
        };
      };
      await expectLater(
        manager.exportPrivateKeys(
          request: PrivateKeyExportRequest(assets: [trx.id]),
        ),
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
      expect(client.requests.map((request) => request['method']), [
        'get_enabled_coins',
      ]);
    },
  );

  test(
    'session change during fresh metadata discards retrieved TRON key',
    () async {
      final respond = client.respond;
      client.respond = (request) {
        if (request['method'] == 'account_balance') generation++;
        return respond(request);
      };
      await expectLater(
        manager.exportPrivateKeys(
          request: PrivateKeyExportRequest(assets: [trx.id]),
        ),
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
    },
  );

  test(
    'deactivation after key retrieval produces an unavailable outcome',
    () async {
      final respond = client.respond;
      client.respond = (request) {
        if (request['method'] == 'show_priv_key') enabled = [];
        return respond(request);
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [trx.id]),
      );
      expect(result.hasKeys, isFalse);
      expect(
        result.outcomes.single.failure,
        PrivateKeyExportFailure.assetUnavailable,
      );
    },
  );

  test('malformed online scalar produces no key or parser detail', () async {
    final respond = client.respond;
    client.respond = (request) => request['method'] == 'show_priv_key'
        ? {
            'result': {'coin': 'TRX', 'priv_key': 'SYNTHETIC_INVALID_SECRET'},
          }
        : respond(request);
    final result = await manager.exportPrivateKeys(
      request: PrivateKeyExportRequest(assets: [trx.id]),
    );
    expect(result.hasKeys, isFalse);
    expect(
      result.outcomes.single.failure,
      PrivateKeyExportFailure.invalidResponse,
    );
    expect(
      jsonEncode(result.toJson()).contains('SYNTHETIC_INVALID_SECRET'),
      isFalse,
    );
  });

  test(
    'legacy TRON verifies owner address and never uses GasFree address',
    () async {
      user = const KdfUser(
        walletId: WalletId(
          name: 'fixture',
          pubkeyHash: 'verified-public-identity',
          authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
        ),
        isBip39Seed: true,
      );
      final respond = client.respond;
      client.respond = (request) => request['method'] == 'my_balance'
          ? {
              'coin': 'TRX',
              'address': key.address,
              'gasfree_address': 'custody-address',
              'balance': '0',
              'unspendable_balance': '0',
            }
          : respond(request);
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [trx.id]),
      );
      expect(result.isComplete, isTrue);
      expect(result.keysByAsset[trx.id]!.single.publicKeyAddress, key.address);
      expect(result.keysByAsset[trx.id]!.single.hdInfo, isNull);
      expect(
        client.requests.any(
          (request) => request['method'] == 'account_balance',
        ),
        isFalse,
      );
    },
  );

  test(
    'unknown platform and unrecognized network fail before online key RPC',
    () async {
      enabled = ['USDT-TRC20'];
      when(() => assets.findAssetsByConfigId('TRX')).thenReturn({});
      final unknown = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );
      expect(
        unknown.outcomes.single.failure,
        PrivateKeyExportFailure.invalidPlatform,
      );
      final alternate = tron(network: 'Unknown');
      when(() => assets.fromId(trx.id)).thenReturn(alternate);
      final invalid = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [trx.id]),
      );
      expect(
        invalid.outcomes.single.failure,
        PrivateKeyExportFailure.invalidPlatform,
      );
      expect(client.requests, isEmpty);
    },
  );

  test('pending assets remain explicit in default export coverage', () async {
    states[trx.id] = AssetActivationState.activating(trx.id);
    final result = await manager.exportPrivateKeys();
    expect(
      result.outcomes[1].failure,
      PrivateKeyExportFailure.activationPending,
    );
    expect(result.outcomes[0].isSuccess, isTrue);
  });

  test(
    'shielded account preserves viewing key and alternate derivation metadata',
    () async {
      final shielded = Asset(
        id: btc.id.copyWith(id: 'ZEC', subClass: CoinSubClass.zhtlc),
        protocol: ZhtlcProtocol.fromJson({
          'type': 'ZHTLC',
          'protocol': {'type': 'ZHTLC'},
          'light_wallet_d_servers': <String>[],
        }),
        isWalletOnly: true,
        signMessagePrefix: null,
      );
      when(() => assets.fromId(shielded.id)).thenReturn(shielded);
      client.respond = (_) => {
        'mmrpc': '2.0',
        'result': [
          {
            'coin': 'ZEC',
            'addresses': [
              {
                'derivation_path': "m/44'/0'/0'",
                'z_derivation_path': "m/32'/133'/0'",
                'pubkey': '',
                'address': 'synthetic-shielded-address',
                'priv_key': 'synthetic-spending-key',
                'viewing_key': 'synthetic-viewing-key',
              },
            ],
          },
        ],
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [shielded.id]),
      );
      expect(result.isComplete, isTrue);
      expect(
        result.outcomes.single.coverage!.kind,
        PrivateKeyExportCoverageKind.offlineAccount,
      );
      final exported = result.keysByAsset[shielded.id]!.single;
      expect(exported.viewingKey, 'synthetic-viewing-key');
      expect(exported.hdInfo!.zDerivationPath, "m/32'/133'/0'");
      expect(exported.toJson()['viewing_key'], 'synthetic-viewing-key');
      expect(exported.toString().contains('synthetic-viewing-key'), isFalse);
    },
  );
  for (final compatibility in [false, true]) {
    test(
      'snapshots asset selection before authentication await (compatibility=$compatibility)',
      () async {
        final read = Completer<KdfUser?>();
        var reads = 0;
        when(
          () => auth.currentUser,
        ).thenAnswer((_) => reads++ == 0 ? read.future : Future.value(user));
        final selected = [btc.id];
        final operation = compatibility
            ? manager.getPrivateKeys(assets: selected)
            : manager.exportPrivateKeys(
                request: PrivateKeyExportRequest(assets: selected),
              );
        selected.clear();
        selected.add(trx.id);
        read.complete(user);
        final result = await operation;
        final keys = compatibility
            ? result as Map<AssetId, List<PrivateKey>>
            : (result as PrivateKeyExportResult).keysByAsset;
        expect(keys.keys, [btc.id]);
        expect(client.requests.map((request) => request['method']), [
          'get_private_keys',
        ]);
      },
    );
  }

  test(
    'ERC20 offline export uses its own configured derivation path',
    () async {
      final asset = Asset(
        id: btc.id.copyWith(id: 'ERC20-FIXTURE', subClass: CoinSubClass.erc20),
        protocol: Erc20Protocol.fromJson({
          'type': 'ERC-20',
          'nodes': <Map<String, dynamic>>[],
          'fallback_swap_contract': '',
          'swap_contract_address': '0x0000000000000000000000000000000000000001',
          'derivation_path': "m/44'/60'",
          'decimals': 18,
          'protocol': {
            'type': 'ERC20',
            'protocol_data': {
              'platform': 'ETH',
              'contract_address': '0x0000000000000000000000000000000000000001',
            },
          },
        }),
        isWalletOnly: true,
        signMessagePrefix: null,
      );
      when(() => assets.fromId(asset.id)).thenReturn(asset);
      client.respond = (_) => {
        'mmrpc': '2.0',
        'result': [
          {
            'coin': asset.id.id,
            'addresses': [
              for (var i = 0; i < 11; i++)
                {
                  'derivation_path': "m/44'/60'/0'/0/$i",
                  'pubkey': 'public',
                  'address': 'synthetic-erc20-$i',
                  'priv_key': 'synthetic-erc20-secret-$i',
                },
            ],
          },
        ],
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [asset.id]),
      );
      expect(result.isComplete, isTrue);
      expect(
        result.outcomes.single.coverage!.kind,
        PrivateKeyExportCoverageKind.offlineHdRange,
      );
      expect(
        result.keysByAsset[asset.id]!.first.hdInfo!.derivationPath,
        "m/44'/60'/0'/0/0",
      );
    },
  );
  test('refuses a NEW capability during a pending auth transition', () async {
    when(() => auth.isAuthTransitionInProgress).thenReturn(true);
    await expectLater(
      manager.captureExportSession(),
      throwsA(isA<PrivateKeyExportSessionChangedException>()),
    );
    verifyNever(() => auth.currentUser);
    expect(client.requests, isEmpty);
  });

  test('rejects transition that starts during identity verification', () async {
    when(() => auth.currentUser).thenAnswer((_) async {
      when(() => auth.isAuthTransitionInProgress).thenReturn(true);
      return user;
    });
    await expectLater(
      manager.captureExportSession(),
      throwsA(isA<PrivateKeyExportSessionChangedException>()),
    );
  });
  test(
    'final synchronous guard rejects auth changes after asynchronous verification',
    () async {
      final session = await manager.captureExportSession();
      await manager.ensureExportSessionCurrent(session);
      generation++;
      expect(
        () => manager.ensureExportSessionCurrentSync(session),
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
    },
  );

  test(
    'manager disposal immediately revokes existing and new capabilities',
    () async {
      final session = await manager.captureExportSession();
      final disposal = manager.dispose();
      expect(
        () => manager.ensureExportSessionCurrentSync(session),
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
      await expectLater(
        manager.captureExportSession(),
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
      await disposal;
    },
  );
  test(
    'TRC20 does not export while its signing platform activation is pending',
    () async {
      enabled = ['USDT-TRC20'];
      states[trx.id] = AssetActivationState.activating(trx.id);
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );
      expect(
        result.outcomes.single.failure,
        PrivateKeyExportFailure.activationPending,
      );
      expect(client.requests, isEmpty);
    },
  );

  test(
    'TRON verifies fresh path against current config with retained AssetId',
    () async {
      final retained = trx.copyWith(
        id: trx.id.copyWith(derivationPath: "m/44'/999'"),
      );
      when(() => assets.fromId(trx.id)).thenReturn(retained);
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [trx.id]),
      );
      expect(result.isComplete, isTrue);
      expect(
        result.keysByAsset[trx.id]!.single.hdInfo!.derivationPath,
        "m/44'/195'/0'/0/7",
      );
    },
  );

  for (final hdWallet in [true, false]) {
    test('TRC20 exports its verified parent key when only the token is listed '
        '(HD=$hdWallet)', () async {
      enabled = ['USDT-TRC20'];
      if (!hdWallet) {
        user = const KdfUser(
          walletId: WalletId(
            name: 'fixture',
            pubkeyHash: 'verified-public-identity',
            authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
          ),
          isBip39Seed: true,
        );
        final respond = client.respond;
        client.respond = (request) => request['method'] == 'my_balance'
            ? {
                'coin': 'TRX',
                'address': key.address,
                'gasfree_address': 'custody-address',
                'balance': '0',
                'unspendable_balance': '0',
              }
            : respond(request);
      }

      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );

      expect(result.isComplete, isTrue);
      expect(result.hasLimitedCoverage, isTrue);
      expect(result.keysByAsset.keys, [usdt.id]);
      final outcome = result.outcomes.single;
      expect(outcome.signingAssetId, trx.id);
      expect(
        outcome.coverage!.kind,
        PrivateKeyExportCoverageKind.activeAddressOnly,
      );
      final exported = outcome.keys.single;
      expect(exported.assetId, usdt.id);
      expect(exported.privateKey, scalar);
      expect(exported.publicKeyAddress, key.address);
      if (hdWallet) {
        expect(exported.hdInfo!.derivationPath, "m/44'/195'/0'/0/7");
        expect(outcome.coverage!.derivationPath, "m/44'/195'/0'/0/7");
        expect(outcome.coverage!.accountIndex, 0);
        expect(outcome.coverage!.chain, 'External');
      } else {
        expect(exported.hdInfo, isNull);
        expect(outcome.coverage!.derivationPath, isNull);
      }
      expect(client.requests.map((request) => request['method']), [
        'get_enabled_coins',
        'show_priv_key',
        if (hdWallet) 'account_balance' else 'my_balance',
        'get_enabled_coins',
      ]);
      expect(client.requests[1]['coin'], 'TRX');
      expect(
        hdWallet
            ? (client.requests[2]['params'] as Map)['coin']
            : client.requests[2]['coin'],
        'TRX',
      );
    });
  }

  test(
    'TRC20 export remains available when only TRX disappears during retrieval',
    () async {
      final respond = client.respond;
      client.respond = (request) {
        if (request['method'] == 'show_priv_key') enabled = ['USDT-TRC20'];
        return respond(request);
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );
      expect(result.isComplete, isTrue);
      expect(result.outcomes.single.signingAssetId, trx.id);
      expect(result.keysByAsset[usdt.id]!.single.privateKey, scalar);
      expect(
        client.requests.where(
          (request) => request['method'] == 'get_enabled_coins',
        ),
        hasLength(2),
      );
    },
  );

  for (final remaining in [
    <String>[],
    ['TRX'],
    ['OTHER-TRC20'],
  ]) {
    test('TRC20 export discards the key when its token disappears '
        '(remaining=$remaining)', () async {
      enabled = ['USDT-TRC20'];
      final respond = client.respond;
      client.respond = (request) {
        if (request['method'] == 'show_priv_key') enabled = remaining;
        return respond(request);
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );
      expect(result.hasKeys, isFalse);
      expect(
        result.outcomes.single.failure,
        PrivateKeyExportFailure.assetUnavailable,
      );
      expect(
        client.requests.where(
          (request) => request['method'] == 'show_priv_key',
        ),
        hasLength(1),
      );
    });
  }

  for (final (tickers, failure) in [
    (<String>[], PrivateKeyExportFailure.platformNotEnabled),
    (['OTHER-TRC20'], PrivateKeyExportFailure.platformNotEnabled),
    (['TRX'], PrivateKeyExportFailure.assetUnavailable),
    (['TRX', 'OTHER-TRC20'], PrivateKeyExportFailure.assetUnavailable),
  ]) {
    test(
      'TRC20 export requires its own freshly enabled ticker (enabled=$tickers)',
      () async {
        enabled = tickers;
        final result = await manager.exportPrivateKeys(
          request: PrivateKeyExportRequest(assets: [usdt.id]),
        );
        expect(result.hasKeys, isFalse);
        expect(result.outcomes.single.failure, failure);
        expect(client.requests.map((request) => request['method']), [
          'get_enabled_coins',
        ]);
      },
    );
  }

  test('direct TRX export still requires its own enabled ticker', () async {
    enabled = ['USDT-TRC20'];
    final result = await manager.exportPrivateKeys(
      request: PrivateKeyExportRequest(assets: [trx.id]),
    );
    expect(result.hasKeys, isFalse);
    expect(
      result.outcomes.single.failure,
      PrivateKeyExportFailure.platformNotEnabled,
    );
    expect(client.requests.map((request) => request['method']), [
      'get_enabled_coins',
    ]);
  });

  test('token-only activation cannot bypass an ambiguous platform', () async {
    enabled = ['USDT-TRC20'];
    when(
      () => assets.findAssetsByConfigId('TRX'),
    ).thenReturn({trx, trx.copyWith(isWalletOnly: false)});
    final result = await manager.exportPrivateKeys(
      request: PrivateKeyExportRequest(assets: [usdt.id]),
    );
    expect(result.hasKeys, isFalse);
    expect(
      result.outcomes.single.failure,
      PrivateKeyExportFailure.invalidPlatform,
    );
    expect(client.requests, isEmpty);
  });

  test('token-only activation cannot bypass a mismatched parent ID', () async {
    enabled = ['USDT-TRC20'];
    final mismatched = usdt.copyWith(id: usdt.id.copyWith(parentId: btc.id));
    when(() => assets.fromId(usdt.id)).thenReturn(mismatched);
    final result = await manager.exportPrivateKeys(
      request: PrivateKeyExportRequest(assets: [usdt.id]),
    );
    expect(result.hasKeys, isFalse);
    expect(
      result.outcomes.single.failure,
      PrivateKeyExportFailure.invalidPlatform,
    );
    expect(client.requests, isEmpty);
  });

  for (final method in ['show_priv_key', 'account_balance', 'my_balance']) {
    test('token-only export fails closed when parent $method fails', () async {
      enabled = ['USDT-TRC20'];
      if (method == 'my_balance') {
        user = const KdfUser(
          walletId: WalletId(
            name: 'fixture',
            pubkeyHash: 'verified-public-identity',
            authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
          ),
          isBip39Seed: true,
        );
      }
      final respond = client.respond;
      client.respond = (request) {
        if (request['method'] == method) {
          throw StateError('Synthetic RPC failure');
        }
        return respond(request);
      };
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );
      expect(result.hasKeys, isFalse);
      expect(
        result.outcomes.single.failure,
        PrivateKeyExportFailure.metadataUnverified,
      );
      expect(
        client.requests.where((request) => request['method'] == method),
        isNotEmpty,
      );
    });
  }

  for (final field in ['address', 'derivation_path']) {
    test('token-only export rejects mismatched parent $field', () async {
      enabled = ['USDT-TRC20'];
      metadata.single[field] = field == 'address'
          ? 'unrelated-address'
          : "m/44'/60'/0'/0/7";
      final result = await manager.exportPrivateKeys(
        request: PrivateKeyExportRequest(assets: [usdt.id]),
      );
      expect(result.hasKeys, isFalse);
      expect(
        result.outcomes.single.failure,
        PrivateKeyExportFailure.metadataUnverified,
      );
      expect(
        client.requests.where(
          (request) => request['method'] == 'show_priv_key',
        ),
        hasLength(1),
      );
    });
  }
  test(
    'capabilities cannot cross managers with identical wallet and generation',
    () async {
      final session = await manager.captureExportSession();
      final separateAuth = _Auth();
      when(() => separateAuth.authGeneration).thenReturn(generation);
      when(() => separateAuth.isAuthTransitionInProgress).thenReturn(false);
      when(() => separateAuth.currentUser).thenAnswer((_) async => user);
      final other = SecurityManager(client, separateAuth, assets, activation);
      await expectLater(
        other.exportPrivateKeys(
          session: session,
          request: PrivateKeyExportRequest(assets: [btc.id]),
        ),
        throwsA(isA<PrivateKeyExportSessionChangedException>()),
      );
      verifyNever(() => separateAuth.currentUser);
      expect(client.requests, isEmpty);
    },
  );
}
