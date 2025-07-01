// ignore_for_file: prefer_const_constructors

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_sdk/src/transaction_history/transaction_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryTransactionStorage storage;
  late AssetId asset;
  late WalletId walletA;
  late WalletId walletB;

  setUp(() {
    storage = InMemoryTransactionStorage();
    asset = AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'btc'),
      chainId: AssetChainId(chainId: 0, decimalsValue: 8),
      derivationPath: 'm/0',
      subClass: CoinSubClass.utxo,
    );
    final authOpts = const AuthOptions(derivationMethod: DerivationMethod.hdWallet);
    walletA = WalletId.fromName('walletA', authOpts);
    walletB = WalletId.fromName('walletB', authOpts);
  });

  Transaction createTx(String id, {DateTime? timestamp}) {
    return Transaction(
      id: id,
      internalId: id,
      assetId: asset,
      balanceChanges: BalanceChanges(
        netChange: Decimal.one,
        receivedByMe: Decimal.one,
        spentByMe: Decimal.zero,
        totalAmount: Decimal.one,
      ),
      timestamp: timestamp ?? DateTime.parse('2024-01-01T00:00:00Z'),
      confirmations: 1,
      blockHeight: 1,
      from: const ['a'],
      to: const ['b'],
      txHash: id,
    );
  }

  test('transactions are isolated per wallet', () async {
    final txA = createTx('a1');
    final txB = createTx('b1');

    await storage.storeTransaction(txA, walletA);
    await storage.storeTransaction(txB, walletB);

    final pageA = await storage.getTransactions(asset, walletA);
    final pageB = await storage.getTransactions(asset, walletB);

    expect(pageA.transactions, equals([txA]));
    expect(pageB.transactions, equals([txB]));
  });

  test('switching wallets with no history returns empty list', () async {
    final txA = createTx('a2');
    await storage.storeTransaction(txA, walletA);

    final pageB = await storage.getTransactions(asset, walletB);

    expect(pageB.transactions, isEmpty);
    expect(pageB.total, equals(0));
  });

  test('clearing one wallet does not remove other wallet history', () async {
    final txA = createTx('a3');
    final txB = createTx('b3');

    await storage.storeTransaction(txA, walletA);
    await storage.storeTransaction(txB, walletB);

    await storage.clearTransactions(asset, walletA);

    final pageA = await storage.getTransactions(asset, walletA);
    final pageB = await storage.getTransactions(asset, walletB);

    expect(pageA.transactions, isEmpty);
    expect(pageB.transactions, equals([txB]));
  });

  test('using fromId from another wallet throws', () async {
    final txA = createTx('a4');
    final txB = createTx('b4');

    await storage.storeTransaction(txA, walletA);
    await storage.storeTransaction(txB, walletB);

    expect(
      () => storage.getTransactions(asset, walletB, fromId: txA.internalId),
      throwsA(isA<TransactionStorageException>()),
    );
  });

  test('latest transaction id is wallet specific', () async {
    final txA1 = createTx('a5', timestamp: DateTime.parse('2024-01-02T00:00:00Z'));
    final txA2 = createTx('a6', timestamp: DateTime.parse('2024-01-03T00:00:00Z'));
    final txB = createTx('b5', timestamp: DateTime.parse('2024-01-01T00:00:00Z'));

    await storage.storeTransactions([txA1, txA2], walletA);
    await storage.storeTransaction(txB, walletB);

    final latestA = await storage.getLatestTransactionId(asset, walletA);
    final latestB = await storage.getLatestTransactionId(asset, walletB);

    expect(latestA, equals(txA2.internalId));
    expect(latestB, equals(txB.internalId));
  });
}
