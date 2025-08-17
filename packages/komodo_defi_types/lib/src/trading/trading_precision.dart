import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/src/trading/swap_types.dart';

extension OrderInfoPrecision on OrderInfo {
  Decimal get priceDecimal => Decimal.parse(price);
  Decimal get maxVolumeDecimal => Decimal.parse(maxVolume);
  Decimal get minVolumeDecimal => Decimal.parse(minVolume);

  Decimal baseAmountDecimal({required String base, required String rel}) {
    if (coin == base) {
      return maxVolumeDecimal;
    }
    if (coin == rel) {
      return maxVolumeDecimal / priceDecimal;
    }
    return maxVolumeDecimal;
  }

  Decimal relAmountDecimal({required String base, required String rel}) {
    if (coin == base) {
      return maxVolumeDecimal * priceDecimal;
    }
    if (coin == rel) {
      return maxVolumeDecimal;
    }
    return maxVolumeDecimal * priceDecimal;
  }

  BestOrder toBestOrder() {
    return BestOrder(
      uuid: uuid,
      price: priceDecimal,
      maxVolume: maxVolumeDecimal,
      coin: coin,
      pubkey: pubkey,
      age: Duration(seconds: age),
      address: address,
    );
  }
}

extension MyOrderInfoPrecision on MyOrderInfo {
  Decimal get priceDecimal => Decimal.parse(price);
  Decimal get volumeDecimal => Decimal.parse(volume);
}

extension SwapInfoPrecision on SwapInfo {
  Decimal get makerAmountDecimal => Decimal.parse(makerAmount);
  Decimal get takerAmountDecimal => Decimal.parse(takerAmount);

  SwapSummary toSummary() {
    return SwapSummary(
      uuid: uuid,
      makerCoin: makerCoin,
      takerCoin: takerCoin,
      makerAmount: makerAmountDecimal,
      takerAmount: takerAmountDecimal,
      isMaker: type.toLowerCase() == 'maker',
      successEvents: successEvents,
      errorEvents: errorEvents,
      startedAt: startedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(startedAt! * 1000)
          : null,
      finishedAt: finishedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(finishedAt! * 1000)
          : null,
    );
  }
}

extension PreimageCoinFeePrecision on PreimageCoinFee {
  Decimal get amountDecimal => Decimal.parse(amount);
}

extension PreimageTotalFeePrecision on PreimageTotalFee {
  Decimal get amountDecimal => Decimal.parse(amount);
  Decimal get requiredBalanceDecimal => Decimal.parse(requiredBalance);
}

extension OrderbookResponsePrecision on OrderbookResponse {
  OrderbookSnapshot toSnapshot() {
    final asksEntries = asks
        .map(
          (o) => OrderbookEntry(
            price: o.priceDecimal,
            baseAmount: o.baseAmountDecimal(base: base, rel: rel),
            relAmount: o.relAmountDecimal(base: base, rel: rel),
            uuid: o.uuid,
            pubkey: o.pubkey,
            age: Duration(seconds: o.age),
          ),
        )
        .toList();

    final bidsEntries = bids
        .map(
          (o) => OrderbookEntry(
            price: o.priceDecimal,
            baseAmount: o.baseAmountDecimal(base: base, rel: rel),
            relAmount: o.relAmountDecimal(base: base, rel: rel),
            uuid: o.uuid,
            pubkey: o.pubkey,
            age: Duration(seconds: o.age),
          ),
        )
        .toList();

    return OrderbookSnapshot(
      base: base,
      rel: rel,
      asks: asksEntries,
      bids: bidsEntries,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }
}

extension OrderbookDepthResponsePrecision on OrderbookDepthResponse {
  Map<String, OrderbookSnapshot> toSnapshots() {
    return depth.map((pair, resp) => MapEntry(pair, resp.toSnapshot()));
  }
}

extension BestOrdersResponsePrecision on BestOrdersResponse {
  BestOrdersResult toBestOrdersResult() {
    return BestOrdersResult(orders: orders.map((o) => o.toBestOrder()).toList());
  }
}

extension TradePreimageResponseMapping on TradePreimageResponse {
  TradePreimageQuote toQuote() {
    CoinAmount? _coinAmountFrom(PreimageCoinFee? fee) {
      if (fee == null) return null;
      return CoinAmount(coin: fee.coin, amount: Decimal.parse(fee.amount));
    }

    return TradePreimageQuote(
      baseCoinFee: _coinAmountFrom(baseCoinFee),
      relCoinFee: _coinAmountFrom(relCoinFee),
      takerFee: _coinAmountFrom(takerFee),
      feeToSendTakerFee: _coinAmountFrom(feeToSendTakerFee),
      totalFees: totalFees
          .map(
            (t) => TotalFeeEntry(
              coin: t.coin,
              amount: Decimal.parse(t.amount),
              requiredBalance: Decimal.parse(t.requiredBalance),
            ),
          )
          .toList(),
    );
  }
}

extension MinTradingVolumePrecision on MinTradingVolumeResponse {
  Decimal get amountDecimal => Decimal.parse(amount);
}

extension MaxTakerVolumePrecision on MaxTakerVolumeResponse {
  Decimal get amountDecimal => Decimal.parse(amount);
}

extension RecentSwapsResponsePrecision on RecentSwapsResponse {
  List<SwapSummary> toSummaries() => swaps.map((s) => s.toSummary()).toList();
}