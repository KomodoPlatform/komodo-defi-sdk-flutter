import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/transaction_history/strategies/etherscan_transaction_history_strategy.dart';
import 'package:komodo_defi_sdk/src/transaction_history/strategies/zhtlc_transaction_strategy.dart';
import 'package:komodo_defi_sdk/src/transaction_history/transaction_history_strategies.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockPubkeyManager extends Mock implements PubkeyManager {}

class _MockLocalAuth extends Mock implements KomodoDefiLocalAuth {}

Asset _createZhtlcAsset() {
  final protocol = ZhtlcProtocol.fromJson({
    'type': 'ZHTLC',
    'electrum_servers': [
      {'url': 'lightwalletd.pirate.black', 'port': 9067, 'protocol': 'SSL'},
    ],
  });

  return Asset(
    id: AssetId(
      id: 'ARRR',
      name: 'Pirate Chain',
      symbol: AssetSymbol(assetConfigId: 'ARRR'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.zhtlc,
    ),
    protocol: protocol,
    isWalletOnly: false,
    signMessagePrefix: null,
  );
}

void main() {
  late PubkeyManager pubkeyManager;
  late KomodoDefiLocalAuth auth;

  setUp(() {
    pubkeyManager = _MockPubkeyManager();
    auth = _MockLocalAuth();
  });

  group('TransactionHistoryStrategyFactory', () {
    test('selects ZHTLC strategy for ZHTLC asset', () {
      final factory = TransactionHistoryStrategyFactory(pubkeyManager, auth);
      final asset = _createZhtlcAsset();

      final strategy = factory.forAsset(asset);

      expect(strategy, isA<ZhtlcTransactionStrategy>());
    });

    test('ZHTLC strategy wins regardless of registration order', () {
      final asset = _createZhtlcAsset();
      final factory = TransactionHistoryStrategyFactory(
        pubkeyManager,
        auth,
        strategies: [
          const LegacyTransactionStrategy(),
          V2TransactionStrategy(auth),
          EtherscanTransactionStrategy(pubkeyManager: pubkeyManager),
          const ZhtlcTransactionStrategy(),
        ],
      );

      final strategy = factory.forAsset(asset);

      expect(strategy, isA<ZhtlcTransactionStrategy>());
    });
  });
}
