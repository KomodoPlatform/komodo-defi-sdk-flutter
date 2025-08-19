import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAuth extends Mock implements KomodoDefiLocalAuth {}

class _MockActivationCoordinator extends Mock
    implements SharedActivationCoordinator {}

class _MockPubkeyManager extends Mock implements PubkeyManager {}

class _MockAssetLookup extends Mock implements IAssetLookup {}

void main() {
  group('Dispose behavior for BalanceManager', () {
    late _MockAuth auth;
    late _MockActivationCoordinator activation;
    late _MockPubkeyManager pubkeyManager;
    late _MockAssetLookup assetLookup;

    setUp(() {
      registerFallbackValue(
        AssetId(
          id: 'ATOM',
          name: 'Cosmos',
          symbol: AssetSymbol(assetConfigId: 'ATOM'),
          chainId: AssetChainId(chainId: 118, decimalsValue: 6),
          derivationPath: null,
          subClass: CoinSubClass.tendermint,
        ),
      );
      auth = _MockAuth();
      activation = _MockActivationCoordinator();
      pubkeyManager = _MockPubkeyManager();
      assetLookup = _MockAssetLookup();
    });

    test('dispose swallows cancel/close errors and is idempotent', () async {
      // Arrange auth stream with throwing-cancel subscription
      when(
        () => auth.authStateChanges,
      ).thenAnswer((_) => _StreamWithThrowingCancel<KdfUser?>());

      final manager = BalanceManager(
        assetLookup: assetLookup,
        auth: auth,
        pubkeyManager: pubkeyManager,
        activationCoordinator: activation,
      );

      await manager.dispose();
      await manager.dispose();
    });

    test('dispose during active watch stops further emissions', () async {
      // Normal auth stream
      final authChanges = StreamController<KdfUser?>.broadcast();
      when(() => auth.authStateChanges).thenAnswer((_) => authChanges.stream);
      when(() => auth.currentUser).thenAnswer(
        (_) async => const KdfUser(
          walletId: WalletId(
            name: 'w',
            authOptions: AuthOptions(derivationMethod: DerivationMethod.iguana),
          ),
          isBip39Seed: false,
        ),
      );

      // Asset and lookup
      final assetId = AssetId(
        id: 'ATOM',
        name: 'Cosmos',
        symbol: AssetSymbol(assetConfigId: 'ATOM'),
        chainId: AssetChainId(chainId: 118, decimalsValue: 6),
        derivationPath: null,
        subClass: CoinSubClass.tendermint,
      );
      final asset = Asset(
        id: assetId,
        protocol: TendermintProtocol.fromJson({
          'type': 'Tendermint',
          'rpc_urls': [
            {'url': 'http://localhost:26657'},
          ],
        }),
        isWalletOnly: false,
        signMessagePrefix: null,
      );
      when(() => assetLookup.fromId(assetId)).thenReturn(asset);

      // Activation
      when(
        () => activation.isAssetActive(assetId),
      ).thenAnswer((_) async => true);

      // Pubkey manager returns balance
      when(() => pubkeyManager.getPubkeys(asset)).thenAnswer(
        (_) async => AssetPubkeys(
          assetId: assetId,
          keys: [
            PubkeyInfo(
              address: 'cosmos1pre',
              derivationPath: null,
              chain: null,
              balance: BalanceInfo(
                total: Decimal.zero,
                spendable: Decimal.zero,
                unspendable: Decimal.zero,
              ),
              coinTicker: assetId.id,
            ),
          ],
          availableAddressesCount: 1,
          syncStatus: SyncStatusEnum.success,
        ),
      );

      final manager = BalanceManager(
        assetLookup: assetLookup,
        auth: auth,
        pubkeyManager: pubkeyManager,
        activationCoordinator: activation,
      );

      addTearDown(() async {
        await manager.dispose();
        await authChanges.close();
      });

      final events = <BalanceInfo>[];
      final sub = manager.watchBalance(assetId).listen(events.add);

      // Let initial microtasks run
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await manager.dispose();

      // Change underlying return; should not emit anymore
      when(() => pubkeyManager.getPubkeys(asset)).thenAnswer(
        (_) async => AssetPubkeys(
          assetId: assetId,
          keys: [
            PubkeyInfo(
              address: 'cosmos1new',
              derivationPath: null,
              chain: null,
              balance: BalanceInfo(
                total: Decimal.zero,
                spendable: Decimal.zero,
                unspendable: Decimal.zero,
              ),
              coinTicker: assetId.id,
            ),
          ],
          availableAddressesCount: 1,
          syncStatus: SyncStatusEnum.success,
        ),
      );

      await Future<void>.delayed(const Duration(seconds: 1));

      expect(events, isNotEmpty);
      await sub.cancel();
    });
  });
}

class _ThrowingCancelSubscription<T> implements StreamSubscription<T> {
  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;

  @override
  Future<void> cancel() => Future<void>.error(Exception('cancel failed'));

  @override
  bool get isPaused => false;

  @override
  void onData(void Function(T data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}
}

class _StreamWithThrowingCancel<T> extends Stream<T> {
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _ThrowingCancelSubscription<T>();
  }
}
