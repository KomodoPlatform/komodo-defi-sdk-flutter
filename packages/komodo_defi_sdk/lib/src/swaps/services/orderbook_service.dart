import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Handles orderbook snapshots, depth queries, and polling-based watching.
class OrderbookService {
  OrderbookService(this._client);

  final ApiClient _client;

  static const Duration _orderbookPollInterval = Duration(seconds: 5);

  final Map<String, StreamController<OrderbookSnapshot>> _controllers = {};
  final Map<String, StreamSubscription<dynamic>> _watchers = {};

  final Map<String, OrderbookSnapshot> _lastSnapshot = {};
  final Map<String, String> _lastSignature = {};

  String _pairKey(String base, String rel) =>
      '${base.toUpperCase()}__${rel.toUpperCase()}';

  Future<OrderbookSnapshot> getSnapshot({
    required AssetId base,
    required AssetId rel,
  }) async {
    final response = await _client.rpc.orderbook.orderbook(
      base: base.id.toUpperCase(),
      rel: rel.id.toUpperCase(),
    );
    return _mapOrderbookResponse(response);
  }

  Stream<OrderbookSnapshot> watch({
    required AssetId base,
    required AssetId rel,
  }) {
    final key = _pairKey(base.id, rel.id);
    final controller = _controllers.putIfAbsent(
      key,
      () => StreamController<OrderbookSnapshot>.broadcast(
        onListen: () => _startWatching(base, rel),
        onCancel: () => _stopWatching(key),
      ),
    );

    return Stream<OrderbookSnapshot>.multi((emitter) {
      final last = _lastSnapshot[key];
      if (last != null) emitter.add(last);
      final sub = controller.stream.listen(
        emitter.add,
        onError: emitter.addError,
        onDone: emitter.close,
        cancelOnError: false,
      );
      emitter.onCancel = () => sub.cancel();
    });
  }

  Future<Map<String, OrderbookSnapshot>> getDepth({
    required List<MapEntry<AssetId, AssetId>> pairs,
  }) async {
    final rpcPairs =
        pairs
            .map(
              (p) => OrderbookPair(
                base: p.key.id.toUpperCase(),
                rel: p.value.id.toUpperCase(),
              ),
            )
            .toList();
    final resp = await _client.rpc.orderbook.orderbookDepth(pairs: rpcPairs);
    return resp.depth.map((k, v) => MapEntry(k, _mapOrderbookResponse(v)));
  }

  Future<void> _startWatching(AssetId base, AssetId rel) async {
    final key = _pairKey(base.id, rel.id);
    final controller = _controllers[key];
    if (controller == null) return;

    await _watchers[key]?.cancel();

    // Initial snapshot
    try {
      final snapshot = await getSnapshot(base: base, rel: rel);
      final sig = _signatureForOrderbook(snapshot);
      _lastSnapshot[key] = snapshot;
      if (_lastSignature[key] != sig) {
        _lastSignature[key] = sig;
        if (!controller.isClosed) controller.add(snapshot);
      }
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }

    final periodic = Stream<void>.periodic(_orderbookPollInterval);
    _watchers[key] = periodic
        .asyncMap<OrderbookSnapshot?>((_) async {
          try {
            return await getSnapshot(base: base, rel: rel);
          } catch (_) {
            return null;
          }
        })
        .listen(
          (snapshot) {
            if (snapshot != null && !controller.isClosed) {
              final sig = _signatureForOrderbook(snapshot);
              if (_lastSignature[key] != sig) {
                _lastSignature[key] = sig;
                _lastSnapshot[key] = snapshot;
                controller.add(snapshot);
              } else {
                _lastSnapshot[key] = snapshot;
              }
            }
          },
          onError: (Object error, StackTrace st) {
            if (!controller.isClosed) controller.addError(error, st);
          },
          onDone: () => _stopWatching(key),
          cancelOnError: false,
        );
  }

  void _stopWatching(String key) {
    _watchers[key]?.cancel();
    _watchers.remove(key);
  }

  OrderbookSnapshot _mapOrderbookResponse(OrderbookResponse response) {
    OrderbookEntry mapOrderToEntry(
      OrderInfo o,
      String baseTicker,
      String relTicker,
    ) {
      final price = Decimal.parse(o.price);
      Decimal baseAmount;
      if (o.coin.toUpperCase() == baseTicker.toUpperCase()) {
        baseAmount = Decimal.parse(o.maxVolume);
      } else if (o.coin.toUpperCase() == relTicker.toUpperCase()) {
        final relVol = Decimal.parse(o.maxVolume);
        if (price == Decimal.zero) {
          baseAmount = Decimal.zero;
        } else {
          baseAmount = Decimal.parse((relVol / price).toString());
        }
      } else {
        baseAmount = Decimal.parse(o.maxVolume);
      }
      final relAmount = Decimal.parse((baseAmount * price).toString());
      return OrderbookEntry(
        price: price,
        baseAmount: baseAmount,
        relAmount: relAmount,
        uuid: o.uuid,
        pubkey: o.pubkey,
        age: Duration(seconds: o.age),
      );
    }

    final asks =
        response.asks
            .map((o) => mapOrderToEntry(o, response.base, response.rel))
            .toList();
    final bids =
        response.bids
            .map((o) => mapOrderToEntry(o, response.base, response.rel))
            .toList();
    final ts = DateTime.fromMillisecondsSinceEpoch(response.timestamp * 1000);
    return OrderbookSnapshot(
      base: response.base,
      rel: response.rel,
      asks: asks,
      bids: bids,
      timestamp: ts,
    );
  }

  String _signatureForOrderbook(OrderbookSnapshot snapshot) {
    final buf =
        StringBuffer()
          ..write(snapshot.base)
          ..write('|')
          ..write(snapshot.rel)
          ..write('|A:');
    for (final a in snapshot.asks) {
      buf
        ..write(a.price.toString())
        ..write('@')
        ..write(a.baseAmount.toString())
        ..write(':')
        ..write(a.relAmount.toString())
        ..write(';');
    }
    buf.write('|B:');
    for (final b in snapshot.bids) {
      buf
        ..write(b.price.toString())
        ..write('@')
        ..write(b.baseAmount.toString())
        ..write(':')
        ..write(b.relAmount.toString())
        ..write(';');
    }
    return buf.toString();
  }

  Future<void> dispose() async {
    for (final sub in _watchers.values) {
      await sub.cancel();
    }
    _watchers.clear();
    for (final c in _controllers.values) {
      await c.close();
    }
    _controllers.clear();
    _lastSnapshot.clear();
    _lastSignature.clear();
  }
}
