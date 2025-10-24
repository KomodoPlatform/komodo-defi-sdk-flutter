// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_ohlc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinGeckoOhlc _$CoinGeckoOhlcFromJson(Map<String, dynamic> json) =>
    CoinGeckoOhlc(
      timestamp: (json['timestamp'] as num).toInt(),
      open: Decimal.fromJson(json['open'] as String),
      high: Decimal.fromJson(json['high'] as String),
      low: Decimal.fromJson(json['low'] as String),
      close: Decimal.fromJson(json['close'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CoinGeckoOhlcToJson(CoinGeckoOhlc instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'runtimeType': instance.$type,
    };

BinanceOhlc _$BinanceOhlcFromJson(Map<String, dynamic> json) => BinanceOhlc(
  openTime: (json['open_time'] as num).toInt(),
  open: Decimal.fromJson(json['open'] as String),
  high: Decimal.fromJson(json['high'] as String),
  low: Decimal.fromJson(json['low'] as String),
  close: Decimal.fromJson(json['close'] as String),
  closeTime: (json['close_time'] as num).toInt(),
  volume: const DecimalConverter().fromJson(json['volume']),
  quoteAssetVolume: const DecimalConverter().fromJson(
    json['quote_asset_volume'],
  ),
  numberOfTrades: (json['number_of_trades'] as num?)?.toInt(),
  takerBuyBaseAssetVolume: const DecimalConverter().fromJson(
    json['taker_buy_base_asset_volume'],
  ),
  takerBuyQuoteAssetVolume: const DecimalConverter().fromJson(
    json['taker_buy_quote_asset_volume'],
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$BinanceOhlcToJson(BinanceOhlc instance) =>
    <String, dynamic>{
      'open_time': instance.openTime,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'close_time': instance.closeTime,
      'volume': const DecimalConverter().toJson(instance.volume),
      'quote_asset_volume': const DecimalConverter().toJson(
        instance.quoteAssetVolume,
      ),
      'number_of_trades': instance.numberOfTrades,
      'taker_buy_base_asset_volume': const DecimalConverter().toJson(
        instance.takerBuyBaseAssetVolume,
      ),
      'taker_buy_quote_asset_volume': const DecimalConverter().toJson(
        instance.takerBuyQuoteAssetVolume,
      ),
      'runtimeType': instance.$type,
    };

CoinPaprikaOhlc _$CoinPaprikaOhlcFromJson(Map<String, dynamic> json) =>
    CoinPaprikaOhlc(
      timeOpen: (json['time_open'] as num).toInt(),
      timeClose: (json['time_close'] as num).toInt(),
      open: Decimal.fromJson(json['open'] as String),
      high: Decimal.fromJson(json['high'] as String),
      low: Decimal.fromJson(json['low'] as String),
      close: Decimal.fromJson(json['close'] as String),
      volume: const DecimalConverter().fromJson(json['volume']),
      marketCap: const DecimalConverter().fromJson(json['market_cap']),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CoinPaprikaOhlcToJson(CoinPaprikaOhlc instance) =>
    <String, dynamic>{
      'time_open': instance.timeOpen,
      'time_close': instance.timeClose,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': const DecimalConverter().toJson(instance.volume),
      'market_cap': const DecimalConverter().toJson(instance.marketCap),
      'runtimeType': instance.$type,
    };
