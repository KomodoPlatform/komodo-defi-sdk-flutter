// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_fee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TradingFee _$TradingFeeFromJson(Map<String, dynamic> json) => _TradingFee(
      coin: json['coin'] as String,
      amount: const DecimalConverter().fromJson(json['amount']),
    );

Map<String, dynamic> _$TradingFeeToJson(_TradingFee instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'amount': const DecimalConverter().toJson(instance.amount),
    };
