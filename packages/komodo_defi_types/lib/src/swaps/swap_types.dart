import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Information about a token returned from the 1inch API.
class OneInchTokenInfo extends Equatable {
  const OneInchTokenInfo({
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.eip2612,
    required this.isFoT,
    required this.logoURI,
    required this.tags,
  });

  factory OneInchTokenInfo.fromJson(JsonMap json) {
    return OneInchTokenInfo(
      address: json.value<String>('address'),
      symbol: json.value<String>('symbol'),
      name: json.value<String>('name'),
      decimals: json.value<int>('decimals'),
      eip2612: json.value<bool>('eip2612'),
      isFoT: json.value<bool>('isFoT'),
      logoURI: json.value<String>('logoURI'),
      tags: List<String>.from(json.value<List>('tags')),
    );
  }

  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final bool eip2612;
  final bool isFoT;
  final String logoURI;
  final List<String> tags;

  JsonMap toJson() => {
        'address': address,
        'symbol': symbol,
        'name': name,
        'decimals': decimals,
        'eip2612': eip2612,
        'isFoT': isFoT,
        'logoURI': logoURI,
        'tags': tags,
      };

  @override
  List<Object?> get props => [
        address,
        symbol,
        name,
        decimals,
        eip2612,
        isFoT,
        logoURI,
        tags,
      ];
}

/// Information about a liquidity protocol used in a 1inch swap route.
class OneInchProtocolInfo extends Equatable {
  const OneInchProtocolInfo({
    required this.name,
    required this.part,
    required this.fromTokenAddress,
    required this.toTokenAddress,
  });

  factory OneInchProtocolInfo.fromJson(JsonMap json) => OneInchProtocolInfo(
        name: json.value<String>('name'),
        part: json.value<int>('part'),
        fromTokenAddress: json.value<String>('fromTokenAddress'),
        toTokenAddress: json.value<String>('toTokenAddress'),
      );

  final String name;
  final int part;
  final String fromTokenAddress;
  final String toTokenAddress;

  JsonMap toJson() => {
        'name': name,
        'part': part,
        'fromTokenAddress': fromTokenAddress,
        'toTokenAddress': toTokenAddress,
      };

  @override
  List<Object?> get props => [name, part, fromTokenAddress, toTokenAddress];
}

/// Transaction fields returned from 1inch swap create.
class OneInchTxFields extends Equatable {
  const OneInchTxFields({
    required this.from,
    required this.to,
    required this.data,
    required this.value,
    required this.gasPrice,
    required this.gas,
  });

  factory OneInchTxFields.fromJson(JsonMap json) => OneInchTxFields(
        from: json.value<String>('from'),
        to: json.value<String>('to'),
        data: json.value<String>('data'),
        value: json.value<String>('value'),
        gasPrice: json.value<num>('gas_price'),
        gas: json.value<num>('gas'),
      );

  final String from;
  final String to;
  final String data;
  final String value;
  final num gasPrice;
  final num gas;

  JsonMap toJson() => {
        'from': from,
        'to': to,
        'data': data,
        'value': value,
        'gas_price': gasPrice,
        'gas': gas,
      };

  @override
  List<Object?> get props => [from, to, data, value, gasPrice, gas];
}

/// Response model for 1inch classic swap quote.
class OneInchClassicSwapQuote extends Equatable {
  const OneInchClassicSwapQuote({
    required this.dstAmount,
    required this.srcToken,
    required this.dstToken,
    required this.protocols,
    this.gas,
  });

  factory OneInchClassicSwapQuote.fromJson(JsonMap json) =>
      OneInchClassicSwapQuote(
        dstAmount: json.value<num>('dst_amount'),
        srcToken: OneInchTokenInfo.fromJson(json.value<JsonMap>('src_token')),
        dstToken: OneInchTokenInfo.fromJson(json.value<JsonMap>('dst_token')),
        protocols: (json.value<List>('protocols') as List)
            .expand((e) => (e as List))
            .map((p) => OneInchProtocolInfo.fromJson(p))
            .toList(),
        gas: json.valueOrNull<num>('gas'),
      );

  final num dstAmount;
  final OneInchTokenInfo srcToken;
  final OneInchTokenInfo dstToken;
  final List<OneInchProtocolInfo> protocols;
  final num? gas;

  JsonMap toJson() => {
        'dst_amount': dstAmount,
        'src_token': srcToken.toJson(),
        'dst_token': dstToken.toJson(),
        'protocols': protocols.map((e) => e.toJson()).toList(),
        if (gas != null) 'gas': gas,
      };

  @override
  List<Object?> get props => [dstAmount, srcToken, dstToken, protocols, gas];
}

/// Response model for 1inch classic swap create.
class OneInchClassicSwapCreate extends Equatable {
  const OneInchClassicSwapCreate({
    required this.dstAmount,
    required this.srcToken,
    required this.dstToken,
    required this.protocols,
    required this.tx,
  });

  factory OneInchClassicSwapCreate.fromJson(JsonMap json) =>
      OneInchClassicSwapCreate(
        dstAmount: json.value<num>('dst_amount'),
        srcToken: OneInchTokenInfo.fromJson(json.value<JsonMap>('src_token')),
        dstToken: OneInchTokenInfo.fromJson(json.value<JsonMap>('dst_token')),
        protocols: (json.value<List>('protocols') as List)
            .expand((e) => (e as List))
            .map((p) => OneInchProtocolInfo.fromJson(p))
            .toList(),
        tx: OneInchTxFields.fromJson(json.value<JsonMap>('tx')),
      );

  final num dstAmount;
  final OneInchTokenInfo srcToken;
  final OneInchTokenInfo dstToken;
  final List<OneInchProtocolInfo> protocols;
  final OneInchTxFields tx;

  JsonMap toJson() => {
        'dst_amount': dstAmount,
        'src_token': srcToken.toJson(),
        'dst_token': dstToken.toJson(),
        'protocols': protocols.map((e) => e.toJson()).toList(),
        'tx': tx.toJson(),
      };

  @override
  List<Object?> get props => [dstAmount, srcToken, dstToken, protocols, tx];
}

/// Liquidity source image information.
class OneInchProtocolImage extends Equatable {
  const OneInchProtocolImage({
    required this.id,
    required this.title,
    required this.img,
    required this.imgColor,
  });

  factory OneInchProtocolImage.fromJson(JsonMap json) => OneInchProtocolImage(
        id: json.value<String>('id'),
        title: json.value<String>('title'),
        img: json.value<String>('img'),
        imgColor: json.value<String>('img_color'),
      );

  final String id;
  final String title;
  final String img;
  final String imgColor;

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'img': img,
        'img_color': imgColor,
      };

  @override
  List<Object?> get props => [id, title, img, imgColor];
}

/// Response model for liquidity sources.
class OneInchClassicLiquiditySources extends Equatable {
  const OneInchClassicLiquiditySources({required this.protocols});

  factory OneInchClassicLiquiditySources.fromJson(JsonMap json) =>
      OneInchClassicLiquiditySources(
        protocols: (json.value<List>('protocols') as List)
            .map((e) => OneInchProtocolImage.fromJson(e))
            .toList(),
      );

  final List<OneInchProtocolImage> protocols;

  JsonMap toJson() => {
        'protocols': protocols.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [protocols];
}

/// Response model for swap tokens list.
class OneInchClassicSwapTokens extends Equatable {
  const OneInchClassicSwapTokens({required this.tokens});

  factory OneInchClassicSwapTokens.fromJson(JsonMap json) =>
      OneInchClassicSwapTokens(
        tokens: (json.value<JsonMap>('tokens')).map(
          (key, value) => MapEntry(
            key.toString(),
            OneInchTokenInfo.fromJson(value as JsonMap),
          ),
        ),
      );

  final Map<String, OneInchTokenInfo> tokens;

  JsonMap toJson() => {
        'tokens': tokens.map((k, v) => MapEntry(k, v.toJson())),
      };

  @override
  List<Object?> get props => [tokens];
}

/// Event that occurs during a legacy atomic swap.
class SwapEvent extends Equatable {
  const SwapEvent({
    required this.type,
    required this.data,
  });

  factory SwapEvent.fromJson(JsonMap json) => SwapEvent(
        type: json.value<String>('type'),
        data: json.valueOrNull<JsonMap>('data'),
      );

  final String type;
  final JsonMap? data;

  JsonMap toJson() => {
        'type': type,
        if (data != null) 'data': data,
      };

  @override
  List<Object?> get props => [type, data];
}

/// Detailed information about a swap and its events.
class SwapStatus extends Equatable {
  const SwapStatus({
    required this.uuid,
    required this.makerCoin,
    required this.takerCoin,
    required this.events,
    this.success,
  });

  factory SwapStatus.fromJson(JsonMap json) => SwapStatus(
        uuid: json.value<String>('uuid'),
        makerCoin: json.value<String>('maker_coin'),
        takerCoin: json.value<String>('taker_coin'),
        events: (json.value<List>('events') as List)
            .map((e) => SwapEvent.fromJson(e as JsonMap))
            .toList(),
        success: json.valueOrNull<bool>('success'),
      );

  final String uuid;
  final String makerCoin;
  final String takerCoin;
  final List<SwapEvent> events;
  final bool? success;

  bool get isFinished => success != null;

  JsonMap toJson() => {
        'uuid': uuid,
        'maker_coin': makerCoin,
        'taker_coin': takerCoin,
        'events': events.map((e) => e.toJson()).toList(),
        if (success != null) 'success': success,
      };

  @override
  List<Object?> get props => [uuid, makerCoin, takerCoin, events, success];
}

/// Result returned from initiating a buy or sell swap.
class BuySellResult extends Equatable {
  const BuySellResult({required this.uuid});

  factory BuySellResult.fromJson(JsonMap json) =>
      BuySellResult(uuid: json.value<String>('uuid'));

  final String uuid;

  JsonMap toJson() => {'uuid': uuid};

  @override
  List<Object?> get props => [uuid];
}
