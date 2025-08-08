// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:fake_async/fake_async.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockAuth extends Mock implements KomodoDefiLocalAuth {}

class _MockActivationCoordinator extends Mock
    implements SharedActivationCoordinator {}

void main() {
  group('User stories and edge cases for PubkeyManager', () {
    late _MockApiClient client;
    late _MockAuth auth;
    late _MockActivationCoordinator activation;
    late StreamController<KdfUser?> authChanges;
    late PubkeyManager manager;

    // Common test asset: single-address protocol (Tendermint)
    late Asset tendermintAsset;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      client = _MockApiClient();
      auth = _MockAuth();
      activation = _MockActivationCoordinator();
      authChanges = StreamController<KdfUser?>.broadcast();

      when(() => auth.authStateChanges).thenAnswer((_) => authChanges.stream);

      manager = PubkeyManager(client, auth, activation);

      // Minimal Tendermint asset (single-address)
      final assetId = AssetId(
        id: 'ATOM',
        name: 'Cosmos',
        symbol: AssetSymbol(assetConfigId: 'ATOM'),
        chainId: AssetChainId(chainId: 118, decimalsValue: 6),
        derivationPath: null,
        subClass: CoinSubClass.tendermint,
      );
      final protocol = TendermintProtocol.fromJson({
        'type': 'Tendermint',
        'rpc_urls': [
          {'url': 'http://localhost:26657'},
        ],
      });
      tendermintAsset = Asset(
        id: assetId,
        protocol: protocol,
        isWalletOnly: false,
        signMessagePrefix: null,
      );
    });

    tearDown(() async {
      await manager.dispose();
      await authChanges.close();
    });

    KdfUser nonHdUser() => KdfUser(
      walletId: WalletId(
        name: 'test-wallet',
        authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
      ),
      isBip39Seed: false,
    );

    Future<void> stubActivationAlwaysActive(Asset asset) async {
      when(
        () => activation.isAssetActive(asset.id),
      ).thenAnswer((_) async => true);
      when(
        () => activation.activateAsset(asset),
      ).thenAnswer((_) async => ActivationResult.success(asset.id));
    }

    void stubWalletMyBalance({
      required String address,
      required String coin,
      Decimal? total,
      Decimal? unspendable,
    }) {
      when(() => client.executeRpc(any())).thenAnswer((invocation) async {
        final req =
            invocation.positionalArguments.first as Map<String, dynamic>;
        final method = req['method'] as String?;
        if (method == 'my_balance') {
          return {
            'address': address,
            'balance': (total ?? Decimal.zero).toString(),
            'unspendable_balance': (unspendable ?? Decimal.zero).toString(),
            'coin': coin,
          };
        }
        if (method == 'unban_pubkeys') {
          return <String, dynamic>{
            'result': <String, dynamic>{
              'still_banned': <String, dynamic>{},
              'unbanned': <String, dynamic>{},
              'were_not_banned': <String>[],
            },
          };
        }
        // Default minimal success for other RPCs that might appear
        return <String, dynamic>{'result': <String, dynamic>{}};
      });
    }

    test(
      'getPubkeys returns single address for single-address protocol',
      () async {
        final user = nonHdUser();
        when(() => auth.currentUser).thenAnswer((_) async => user);
        await stubActivationAlwaysActive(tendermintAsset);

        stubWalletMyBalance(address: 'cosmos1abc', coin: tendermintAsset.id.id);

        final result = await manager.getPubkeys(tendermintAsset);
        expect(result.assetId, tendermintAsset.id);
        expect(result.keys, hasLength(1));
        expect(result.keys.first.address, 'cosmos1abc');
      },
    );

    test(
      'createNewPubkey throws UnsupportedError for single-address assets',
      () async {
        final user = nonHdUser();
        when(() => auth.currentUser).thenAnswer((_) async => user);
        await stubActivationAlwaysActive(tendermintAsset);

        stubWalletMyBalance(address: 'cosmos1abc', coin: tendermintAsset.id.id);

        expect(
          () => manager.createNewPubkey(tendermintAsset),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );

    test(
      'createNewPubkeyStream yields error for single-address assets',
      () async {
        final user = nonHdUser();
        when(() => auth.currentUser).thenAnswer((_) async => user);
        await stubActivationAlwaysActive(tendermintAsset);

        stubWalletMyBalance(address: 'cosmos1abc', coin: tendermintAsset.id.id);

        final states =
            await manager
                .createNewPubkeyStream(tendermintAsset)
                .take(1)
                .toList();
        expect(states.single.status, NewAddressStatus.error);
      },
    );

    test('unbanPubkeys delegates to RPC and returns result', () async {
      // auth not required here
      stubWalletMyBalance(address: 'cosmos1abc', coin: tendermintAsset.id.id);

      final res = await manager.unbanPubkeys(const UnbanBy.all());
      expect(res.isEmpty, isTrue);
    });

    test(
      'watchPubkeys emits last known immediately, then refreshed value',
      () async {
        final user = nonHdUser();
        when(() => auth.currentUser).thenAnswer((_) async => user);
        await stubActivationAlwaysActive(tendermintAsset);

        // First response used for preCache
        stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
        await manager.preCachePubkeys(tendermintAsset);

        // Update the stub to simulate a new address on refresh
        stubWalletMyBalance(address: 'cosmos1new', coin: tendermintAsset.id.id);

        final stream = manager.watchPubkeys(tendermintAsset);

        // First emit is the immediate lastKnown, second emit is the same from controller,
        // third emit is the refreshed value after getPubkeys()
        final firstThree = await stream.take(3).toList();
        expect(firstThree[0].keys.first.address, 'cosmos1pre');
        expect(firstThree[2].keys.first.address, 'cosmos1new');
      },
    );

    test('watchPubkeys respects polling interval (~30s)', () async {
      final user = nonHdUser();
      when(() => auth.currentUser).thenAnswer((_) async => user);
      await stubActivationAlwaysActive(tendermintAsset);

      // Initial cache
      stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
      await manager.preCachePubkeys(tendermintAsset);

      fakeAsync((FakeAsync async) {
        // After start, we set a different address for the immediate refresh
        stubWalletMyBalance(
          address: 'cosmos1poll1',
          coin: tendermintAsset.id.id,
        );

        final emitted = <String>[];
        final sub = manager.watchPubkeys(tendermintAsset).listen((e) {
          emitted.add(e.keys.first.address);
        });

        // Allow the immediate refresh to occur
        async.flushMicrotasks();
        expect(emitted.contains('cosmos1poll1'), isTrue);

        // Prepare next poll result and ensure it's not emitted before 30s
        stubWalletMyBalance(
          address: 'cosmos1poll2',
          coin: tendermintAsset.id.id,
        );
        async
          ..elapse(Duration(seconds: 29))
          ..flushMicrotasks();
        expect(emitted.contains('cosmos1poll2'), isFalse);

        // Hitting 30s should emit the next poll
        async
          ..elapse(Duration(seconds: 1))
          ..flushMicrotasks();
        expect(emitted.contains('cosmos1poll2'), isTrue);

        unawaited(sub.cancel());
      });
    });

    test('watchPubkeys stops and new watches throw after dispose', () async {
      final user = nonHdUser();
      when(() => auth.currentUser).thenAnswer((_) async => user);
      await stubActivationAlwaysActive(tendermintAsset);

      stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
      await manager.preCachePubkeys(tendermintAsset);

      final received = <String>[];
      final sub = manager.watchPubkeys(tendermintAsset).listen((e) {
        received.add(e.keys.first.address);
      });

      // Cancel current subscription before disposing
      await sub.cancel();
      await manager.dispose();

      // After dispose, starting a new watch should throw on listen
      expect(
        () => manager.watchPubkeys(tendermintAsset).first,
        throwsA(isA<StateError>()),
      );
    });

    test('watchPubkeys updates lastKnown after emission', () async {
      final user = nonHdUser();
      when(() => auth.currentUser).thenAnswer((_) async => user);
      await stubActivationAlwaysActive(tendermintAsset);

      stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
      await manager.preCachePubkeys(tendermintAsset);

      // Change to a new address which should update via immediate get in start
      stubWalletMyBalance(address: 'cosmos1start', coin: tendermintAsset.id.id);

      final first = await manager.watchPubkeys(tendermintAsset).first;
      expect(first.keys.first.address, isNotEmpty);

      // lastKnown should be updated to latest emitted value
      final cached = manager.lastKnown(tendermintAsset.id);
      expect(cached, isNotNull);
      expect(cached!.keys.first.address, first.keys.first.address);
    });

    test(
      'watchPubkeys with activateIfNeeded=false only emits last known if inactive',
      () async {
        final user = nonHdUser();
        when(() => auth.currentUser).thenAnswer((_) async => user);

        // Pre-cache with initial address
        when(
          () => activation.activateAsset(tendermintAsset),
        ).thenAnswer((_) async => ActivationResult.success(tendermintAsset.id));
        when(
          () => activation.isAssetActive(tendermintAsset.id),
        ).thenAnswer((_) async => true);
        stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
        await manager.preCachePubkeys(tendermintAsset);

        // Now simulate inactive asset and disable activation on watch
        when(
          () => activation.isAssetActive(tendermintAsset.id),
        ).thenAnswer((_) async => false);
        // If it were to fetch, it would get this new address, but it should not
        stubWalletMyBalance(address: 'cosmos1new', coin: tendermintAsset.id.id);

        final stream = manager.watchPubkeys(
          tendermintAsset,
          activateIfNeeded: false,
        );

        // Give stream a brief moment to potentially emit more; should only emit one
        final received =
            await stream.timeout(Duration(milliseconds: 200)).take(1).toList();
        expect(received.single.keys.first.address, 'cosmos1pre');
      },
    );

    test(
      'lastKnown returns null when no cache; updates after preCache',
      () async {
        final user = nonHdUser();
        when(() => auth.currentUser).thenAnswer((_) async => user);
        when(
          () => activation.isAssetActive(tendermintAsset.id),
        ).thenAnswer((_) async => true);
        when(
          () => activation.activateAsset(tendermintAsset),
        ).thenAnswer((_) async => ActivationResult.success(tendermintAsset.id));

        expect(manager.lastKnown(tendermintAsset.id), isNull);

        stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
        await manager.preCachePubkeys(tendermintAsset);

        final cached = manager.lastKnown(tendermintAsset.id);
        expect(cached, isNotNull);
        expect(cached!.keys.first.address, 'cosmos1pre');
      },
    );

    test('auth wallet change resets state and clears cache', () async {
      final user = nonHdUser();
      when(() => auth.currentUser).thenAnswer((_) async => user);
      when(
        () => activation.isAssetActive(tendermintAsset.id),
      ).thenAnswer((_) async => true);
      when(
        () => activation.activateAsset(tendermintAsset),
      ).thenAnswer((_) async => ActivationResult.success(tendermintAsset.id));

      stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
      await manager.preCachePubkeys(tendermintAsset);
      expect(manager.lastKnown(tendermintAsset.id), isNotNull);

      // Emit new user with different wallet ID
      final newUser = KdfUser(
        walletId: WalletId(
          name: 'other',
          authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
        ),
        isBip39Seed: false,
      );
      authChanges.add(newUser);
      await Future<void>.delayed(Duration(milliseconds: 50));

      expect(manager.lastKnown(tendermintAsset.id), isNull);
    });

    test(
      'auth wallet change emits error and restarts watching on same subscription',
      () async {
        // Arrange: setup auth to return a mutable current user
        final user1 = nonHdUser();
        KdfUser current = user1;
        when(() => auth.currentUser).thenAnswer((_) async => current);
        await stubActivationAlwaysActive(tendermintAsset);

        // Prime cache and first fetches
        stubWalletMyBalance(address: 'cosmos1pre', coin: tendermintAsset.id.id);
        await manager.preCachePubkeys(tendermintAsset);
        stubWalletMyBalance(
          address: 'cosmos1first',
          coin: tendermintAsset.id.id,
        );

        final emitted = <String>[];
        final errors = <Object>[];
        final sub = manager
            .watchPubkeys(tendermintAsset)
            .listen(
              (pubkeys) => emitted.add(pubkeys.keys.first.address),
              onError: errors.add,
            );

        // Allow immediate refresh
        await Future<void>.delayed(Duration(milliseconds: 10));

        // Act: change wallet and ensure new value is fetched on the same subscription
        stubWalletMyBalance(
          address: 'cosmos1afterChange',
          coin: tendermintAsset.id.id,
        );
        final user2 = KdfUser(
          walletId: WalletId(
            name: 'other',
            authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
          ),
          isBip39Seed: false,
        );
        current = user2; // update what auth.currentUser returns
        authChanges.add(user2);

        // Assert: receive an error and then a new emission without re-subscribing
        await Future<void>.delayed(Duration(milliseconds: 80));
        expect(errors.whereType<StateError>(), isNotEmpty);
        // The controller remains open and should emit after restart
        expect(emitted.contains('cosmos1afterChange'), isTrue);

        await sub.cancel();
      },
    );

    test('dispose prevents further access', () async {
      await manager.dispose();
      expect(
        () => manager.lastKnown(tendermintAsset.id),
        throwsA(isA<StateError>()),
      );
    });
  });
}
