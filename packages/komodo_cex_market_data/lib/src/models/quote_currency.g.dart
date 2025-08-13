// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FiatQuoteCurrency _$FiatQuoteCurrencyFromJson(Map<String, dynamic> json) =>
    FiatQuoteCurrency(
      symbol: json['symbol'] as String,
      displayName: json['displayName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$FiatQuoteCurrencyToJson(FiatQuoteCurrency instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'displayName': instance.displayName,
      'runtimeType': instance.$type,
    };

StablecoinQuoteCurrency _$StablecoinQuoteCurrencyFromJson(
  Map<String, dynamic> json,
) => StablecoinQuoteCurrency(
  symbol: json['symbol'] as String,
  displayName: json['displayName'] as String,
  underlyingFiat: FiatQuoteCurrency.fromJson(
    json['underlyingFiat'] as Map<String, dynamic>,
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$StablecoinQuoteCurrencyToJson(
  StablecoinQuoteCurrency instance,
) => <String, dynamic>{
  'symbol': instance.symbol,
  'displayName': instance.displayName,
  'underlyingFiat': instance.underlyingFiat,
  'runtimeType': instance.$type,
};

CryptocurrencyQuoteCurrency _$CryptocurrencyQuoteCurrencyFromJson(
  Map<String, dynamic> json,
) => CryptocurrencyQuoteCurrency(
  symbol: json['symbol'] as String,
  displayName: json['displayName'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CryptocurrencyQuoteCurrencyToJson(
  CryptocurrencyQuoteCurrency instance,
) => <String, dynamic>{
  'symbol': instance.symbol,
  'displayName': instance.displayName,
  'runtimeType': instance.$type,
};

CommodityQuoteCurrency _$CommodityQuoteCurrencyFromJson(
  Map<String, dynamic> json,
) => CommodityQuoteCurrency(
  symbol: json['symbol'] as String,
  displayName: json['displayName'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CommodityQuoteCurrencyToJson(
  CommodityQuoteCurrency instance,
) => <String, dynamic>{
  'symbol': instance.symbol,
  'displayName': instance.displayName,
  'runtimeType': instance.$type,
};
