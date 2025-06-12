// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwapPreview _$SwapPreviewFromJson(Map<String, dynamic> json) => _SwapPreview(
      baseCoinFee:
          TradingFee.fromJson(json['baseCoinFee'] as Map<String, dynamic>),
      relCoinFee:
          TradingFee.fromJson(json['relCoinFee'] as Map<String, dynamic>),
      totalFees: (json['totalFees'] as List<dynamic>)
          .map((e) => TradingFee.fromJson(e as Map<String, dynamic>))
          .toList(),
      volume: const DecimalConverter().fromJson(json['volume']),
      takerFee: json['takerFee'] == null
          ? null
          : TradingFee.fromJson(json['takerFee'] as Map<String, dynamic>),
      feeToSendTakerFee: json['feeToSendTakerFee'] == null
          ? null
          : TradingFee.fromJson(
              json['feeToSendTakerFee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SwapPreviewToJson(_SwapPreview instance) =>
    <String, dynamic>{
      'baseCoinFee': instance.baseCoinFee,
      'relCoinFee': instance.relCoinFee,
      'totalFees': instance.totalFees,
      'volume': const DecimalConverter().toJson(instance.volume),
      'takerFee': instance.takerFee,
      'feeToSendTakerFee': instance.feeToSendTakerFee,
    };
