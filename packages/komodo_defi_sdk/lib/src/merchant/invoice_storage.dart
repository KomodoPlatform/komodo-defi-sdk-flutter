import 'dart:async';

import 'package:collection/collection.dart';

import 'merchant_invoice.dart';

abstract interface class InvoiceStorage {
  Future<void> upsert(MerchantInvoice invoice);
  Future<MerchantInvoice?> getById(String id);
  Future<List<MerchantInvoice>> list({bool includeClosed = false});
}

/// In-memory implementation suitable for MVP/demo use. Not persisted.
class InMemoryInvoiceStorage implements InvoiceStorage {
  final Map<String, MerchantInvoice> _byId = {};

  @override
  Future<MerchantInvoice?> getById(String id) async => _byId[id];

  @override
  Future<List<MerchantInvoice>> list({bool includeClosed = false}) async {
    final items = _byId.values.toList()
      ..sortBy((i) => i.createdAt.millisecondsSinceEpoch);
    if (includeClosed) return items.reversed.toList();
    return items
        .where(
          (i) => !(i.status.isPaid || i.status.isCancelled || i.status.isExpired),
        )
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> upsert(MerchantInvoice invoice) async {
    _byId[invoice.id] = invoice;
  }
}

