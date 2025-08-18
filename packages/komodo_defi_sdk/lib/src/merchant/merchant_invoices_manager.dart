import 'dart:async';

import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/transaction_history/transaction_history_manager.dart';
import 'package:komodo_defi_sdk/src/utils/payment_uri_builder.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

import 'invoice_events.dart';
import 'invoice_status.dart';
import 'invoice_storage.dart';
import 'merchant_invoice.dart';

class MerchantInvoicesManager {
  static final Logger _logger = Logger('MerchantInvoicesManager');
  MerchantInvoicesManager({
    required MarketDataManager marketData,
    required PubkeyManager pubkeys,
    required TransactionHistoryManager transactions,
    required SharedActivationCoordinator activation,
    required IAssetProvider assetProvider,
    InvoiceStorage? storage,
  })  : _marketData = marketData,
        _pubkeys = pubkeys,
        _transactions = transactions,
        _activation = activation,
        _assetProvider = assetProvider,
        _storage = storage ?? InMemoryInvoiceStorage();

  final MarketDataManager _marketData;
  final PubkeyManager _pubkeys;
  final TransactionHistoryManager _transactions;
  final SharedActivationCoordinator _activation;
  final IAssetProvider _assetProvider;
  final InvoiceStorage _storage;

  final Map<String, StreamController<InvoiceUpdate>> _controllers = {};
  final Map<String, Timer> _expiryTimers = {};

  Future<void> init() async {}

  Future<MerchantInvoice> createInvoice({
    required Asset asset,
    required Decimal fiatAmount,
    required QuoteCurrency fiat,
    Duration? expiresIn,
    int minConfirmations = 1,
    String? label,
    String? message,
  }) async {
    final activationResult = await _activation.activateAsset(asset);
    if (activationResult.isFailure) {
      throw StateError('Failed to activate asset ${asset.id.name}: ${activationResult.errorMessage}');
    }
    final pubkey = await _pubkeys.createNewPubkey(asset);

    final price = await _marketData.fiatPrice(asset.id, quoteCurrency: fiat);
    if (price <= Decimal.zero) {
      throw StateError('Invalid price for ${asset.id.symbol.ticker}: $price');
    }
    final coinAmount = (fiatAmount / price);

    final uri = PaymentUriBuilder.forAsset(
      asset: asset,
      address: pubkey.address,
      amount: coinAmount,
      label: label,
      message: message,
    );

    final now = DateTime.now();
    final invoice = MerchantInvoice(
      id: _generateInvoiceId(asset),
      asset: asset,
      address: pubkey.address,
      coinAmount: coinAmount,
      fiatAmount: fiatAmount,
      fiat: fiat,
      createdAt: now,
      expiresAt: expiresIn == null ? null : now.add(expiresIn),
      paymentUri: uri,
      minConfirmations: minConfirmations,
      status: const InvoiceStatus.pending(),
    );

    await _storage.upsert(invoice);
    _ensureStream(invoice.id);
    _controllers[invoice.id]!.add(
      InvoiceUpdate(invoiceId: invoice.id, status: invoice.status, seenAt: now),
    );

    // Start monitoring in background
    _monitorInvoice(invoice);
    _scheduleExpiry(invoice);
    return invoice;
  }

  Stream<InvoiceUpdate> watchInvoice(String invoiceId) {
    _ensureStream(invoiceId);
    return _controllers[invoiceId]!.stream;
  }

  Future<void> cancelInvoice(String invoiceId) async {
    final existing = await _storage.getById(invoiceId);
    if (existing == null) return;
    final updated = existing.copyWith(status: const InvoiceStatus.cancelled());
    await _storage.upsert(updated);
    _controllers[invoiceId]?.add(
      InvoiceUpdate(
        invoiceId: invoiceId,
        status: updated.status,
        seenAt: DateTime.now(),
      ),
    );
    await _controllers[invoiceId]?.close();
    _controllers.remove(invoiceId);
    _expiryTimers.remove(invoiceId)?.cancel();
  }

  Future<MerchantInvoice?> getInvoice(String invoiceId) => _storage.getById(invoiceId);

  Future<List<MerchantInvoice>> listInvoices({bool includeClosed = false}) =>
      _storage.list(includeClosed: includeClosed);

  void _ensureStream(String invoiceId) {
    _controllers.putIfAbsent(
      invoiceId,
      () => StreamController<InvoiceUpdate>.broadcast(),
    );
  }

  void _monitorInvoice(MerchantInvoice invoice) async {
    final controller = _controllers[invoice.id];
    if (controller == null) return;

    final asset = invoice.asset;
    final stream = _transactions.watchTransactions(asset);
    Decimal received = Decimal.zero;
    int lastConfs = 0;

    late final StreamSubscription sub;
    sub = stream.listen((tx) async {
      // Stop if the controller is closed
      if (controller.isClosed) {
        await sub.cancel();
        return;
      }

      if (!tx.isIncoming) return;
      if (!tx.to.contains(invoice.address)) return;

      // Accumulate amounts for this invoice address
      received += tx.balanceChanges.receivedByMe;
      lastConfs = tx.confirmations;

      final isExpired = invoice.expiresAt != null && DateTime.now().isAfter(invoice.expiresAt!);
      final status = _deriveStatus(
        requested: invoice.coinAmount,
        received: received,
        confirmations: lastConfs,
        minConfirmations: invoice.minConfirmations,
        isExpired: isExpired,
      );

      final updated = invoice.copyWith(
        status: status,
        matchedTxIds: {...invoice.matchedTxIds, tx.id},
      );
      await _storage.upsert(updated);

      controller.add(
        InvoiceUpdate(
          invoiceId: invoice.id,
          status: status,
          seenAt: DateTime.now(),
          txId: tx.id,
          confirmations: lastConfs,
        ),
      );

      if (status.isPaid || status.isOverpaid || status.isUnderpaid || status.isExpired) {
        await sub.cancel();
        _expiryTimers.remove(invoice.id)?.cancel();
      }
    });
    sub.onError((error, stack) {
      _logger.warning('Error monitoring invoice ${invoice.id}', error, stack);
    });
  }

  void _scheduleExpiry(MerchantInvoice invoice) {
    if (invoice.expiresAt == null) return;
    final remaining = invoice.expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) {
      _controllers[invoice.id]?.add(
        InvoiceUpdate(
          invoiceId: invoice.id,
          status: const InvoiceStatus.expired(),
          seenAt: DateTime.now(),
        ),
      );
      return;
    }
    _expiryTimers[invoice.id]?.cancel();
    _expiryTimers[invoice.id] = Timer(remaining, () async {
      final current = await _storage.getById(invoice.id);
      if (current == null) return;
      final updated = current.copyWith(status: const InvoiceStatus.expired());
      await _storage.upsert(updated);
      _controllers[invoice.id]?.add(
        InvoiceUpdate(
          invoiceId: invoice.id,
          status: updated.status,
          seenAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    for (final timer in _expiryTimers.values) {
      timer.cancel();
    }
    _expiryTimers.clear();
  }

  InvoiceStatus _deriveStatus({
    required Decimal requested,
    required Decimal received,
    required int confirmations,
    required int minConfirmations,
    required bool isExpired,
  }) {
    if (received == Decimal.zero) {
      return isExpired ? const InvoiceStatus.expired() : const InvoiceStatus.pending();
    }

    if (confirmations < minConfirmations) {
      return InvoiceStatus.confirming(confirmations);
    }

    if (received == requested) return const InvoiceStatus.paid();
    if (received > requested) return const InvoiceStatus.overpaid();
    // received < requested
    return isExpired ? const InvoiceStatus.underpaid() : InvoiceStatus.confirming(confirmations);
  }

  String _generateInvoiceId(Asset asset) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'inv_${asset.id.symbol.ticker}_$ts';
  }
}

