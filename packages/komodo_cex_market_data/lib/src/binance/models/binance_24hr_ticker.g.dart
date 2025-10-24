// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binance_24hr_ticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Binance24hrTicker _$Binance24hrTickerFromJson(Map<String, dynamic> json) =>
    _Binance24hrTicker(
      symbol: json['symbol'] as String,
      priceChange: Decimal.fromJson(json['priceChange'] as String),
      priceChangePercent: Decimal.fromJson(
        json['priceChangePercent'] as String,
      ),
      weightedAvgPrice: Decimal.fromJson(json['weightedAvgPrice'] as String),
      prevClosePrice: Decimal.fromJson(json['prevClosePrice'] as String),
      lastPrice: Decimal.fromJson(json['lastPrice'] as String),
      lastQty: Decimal.fromJson(json['lastQty'] as String),
      bidPrice: Decimal.fromJson(json['bidPrice'] as String),
      bidQty: Decimal.fromJson(json['bidQty'] as String),
      askPrice: Decimal.fromJson(json['askPrice'] as String),
      askQty: Decimal.fromJson(json['askQty'] as String),
      openPrice: Decimal.fromJson(json['openPrice'] as String),
      highPrice: Decimal.fromJson(json['highPrice'] as String),
      lowPrice: Decimal.fromJson(json['lowPrice'] as String),
      volume: Decimal.fromJson(json['volume'] as String),
      quoteVolume: Decimal.fromJson(json['quoteVolume'] as String),
      openTime: (json['openTime'] as num).toInt(),
      closeTime: (json['closeTime'] as num).toInt(),
      firstId: (json['firstId'] as num).toInt(),
      lastId: (json['lastId'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$Binance24hrTickerToJson(_Binance24hrTicker instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'priceChange': instance.priceChange,
      'priceChangePercent': instance.priceChangePercent,
      'weightedAvgPrice': instance.weightedAvgPrice,
      'prevClosePrice': instance.prevClosePrice,
      'lastPrice': instance.lastPrice,
      'lastQty': instance.lastQty,
      'bidPrice': instance.bidPrice,
      'bidQty': instance.bidQty,
      'askPrice': instance.askPrice,
      'askQty': instance.askQty,
      'openPrice': instance.openPrice,
      'highPrice': instance.highPrice,
      'lowPrice': instance.lowPrice,
      'volume': instance.volume,
      'quoteVolume': instance.quoteVolume,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'firstId': instance.firstId,
      'lastId': instance.lastId,
      'count': instance.count,
    };
