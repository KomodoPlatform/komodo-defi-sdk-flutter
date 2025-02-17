import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'fee_info.freezed.dart';
// We are doing manual fromJson/toJson, so no need for part 'fee_info.g.dart';

/// A union representing five possible fee types:
/// - UtxoFixed
/// - UtxoPerKbyte
/// - EthGas
/// - Qrc20Gas
/// - CosmosGas
@freezed
class FeeInfo with _$FeeInfo {
  //////////////////////////////////////////////////////////////////////////////
  //  Custom Manual JSON Parsing
  //
  //  The docs show that each variant includes a "type" field and possibly
  //  different fields like "amount", "gas_price", "gas", "gas_limit", etc.
  //////////////////////////////////////////////////////////////////////////////

  /// Parse a JSON object into one of the [FeeInfo] variants, based on `type`.
  factory FeeInfo.fromJson(JsonMap json) {
    final type = json['type'] as String? ?? '';
    switch (type) {
      case 'UtxoFixed' || 'Utxo':
        return FeeInfo.utxoFixed(
          coin: json['coin'] as String? ?? '',
          amount: Decimal.parse(json['amount'] as String),
        );
      case 'UtxoPerKbyte':
        return FeeInfo.utxoPerKbyte(
          coin: json['coin'] as String? ?? '',
          amount: Decimal.parse(json['amount'] as String),
        );
      case 'EthGas' || 'Eth':
        return FeeInfo.ethGas(
          coin: json['coin'] as String? ?? '',
          // If JSON provides e.g. "0.000000003", parse to Decimal => 3e-9
          gasPrice: Decimal.parse(json['gas_price'].toString()),
          gas: json['gas'] as int,
        );
      case 'Qrc20Gas':
        return FeeInfo.qrc20Gas(
          coin: json['coin'] as String? ?? '',
          gasPrice: Decimal.parse(json['gas_price'].toString()),
          gasLimit: json['gas_limit'] as int,
        );
      case 'CosmosGas':
        return FeeInfo.cosmosGas(
          coin: json['coin'] as String? ?? '',
          // The doc sometimes shows 0.05 as a number (double),
          // so we convert it to string, then parse:
          gasPrice: Decimal.parse(json['gas_price'].toString()),
          gasLimit: json['gas_limit'] as int,
        );
      default:
        throw ArgumentError('Unknown fee type: $type');
    }
  }
  // A private constructor so that we can add custom getters/methods.
  const FeeInfo._();

  /// 1) A *fixed* fee in coin units (e.g. "0.0001 BTC").
  const factory FeeInfo.utxoFixed({
    /// Which coin pays the fee
    required String coin,

    /// The fee amount in coin units
    required Decimal amount,
  }) = FeeInfoUtxoFixed;

  /// 2) A *per kilobyte* fee in coin units (e.g. "0.0001 BTC per KB").
  const factory FeeInfo.utxoPerKbyte({
    required String coin,
    required Decimal amount,
  }) = FeeInfoUtxoPerKbyte;

  /// 3) ETH-like gas: you specify *gasPrice* (in ETH) and *gas* (units).
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "type": "EthGas",
  ///   "coin": "ETH",
  ///   "gas_price": "0.000000003",
  ///   "gas": 21000
  /// }
  /// ```
  /// Interpreted as: 3 Gwei -> total fee = 0.000000003 ETH * 21000 = 0.000063 ETH.
  const factory FeeInfo.ethGas({
    required String coin,

    /// Gas price in ETH. e.g. "0.000000003" => 3 Gwei
    required Decimal gasPrice,

    /// Gas limit (number of gas units)
    required int gas,
  }) = FeeInfoEthGas;

  /// 4) Qtum/QRC20-like gas, specifying `gasPrice` (in coin units) and `gasLimit`.
  const factory FeeInfo.qrc20Gas({
    required String coin,

    /// Gas price in coin units. e.g. "0.000000004"
    required Decimal gasPrice,

    /// Gas limit
    required int gasLimit,
  }) = FeeInfoQrc20Gas;

  /// 5) Cosmos-like gas, specifying `gasPrice` (in coin units) and `gasLimit`.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "type": "CosmosGas",
  ///   "coin": "IRIS",
  ///   "gas_price": 0.05,
  ///   "gas_limit": 21000
  /// }
  /// ```
  const factory FeeInfo.cosmosGas({
    required String coin,

    /// Gas price in coin units. e.g. "0.05"
    required Decimal gasPrice,

    /// Gas limit
    required int gasLimit,
  }) = FeeInfoCosmosGas;

  /// A convenience getter returning the *total fee* in the coin's main units.
  ///
  /// - For ETH: `gasPrice * gas` => total in ETH
  /// - For Qrc20, Cosmos: `gasPrice * gasLimit` => total in coin units
  /// - For UTXO fees: simply `amount`
  Decimal get totalFee => map(
        utxoFixed: (fee) => fee.amount,
        utxoPerKbyte: (fee) => fee.amount,
        ethGas: (fee) => fee.gasPrice * Decimal.fromInt(fee.gas),
        qrc20Gas: (fee) => fee.gasPrice * Decimal.fromInt(fee.gasLimit),
        cosmosGas: (fee) => fee.gasPrice * Decimal.fromInt(fee.gasLimit),
      );

  /// Convert this [FeeInfo] to a JSON object matching the mmRPC 2.0 docs.
  JsonMap toJson() {
    return map(
      utxoFixed: (fee) => <String, dynamic>{
        'type': 'UtxoFixed',
        'coin': fee.coin,
        'amount': fee.amount.toString(),
      },
      utxoPerKbyte: (fee) => <String, dynamic>{
        'type': 'UtxoPerKbyte',
        'coin': fee.coin,
        'amount': fee.amount.toString(),
      },
      ethGas: (fee) => <String, dynamic>{
        'type': 'Eth',
        'coin': fee.coin,
        'gas_price': fee.gasPrice.toString(),
        'gas': fee.gas,
        // Optionally: "total_fee": totalFee.toString(),
      },
      qrc20Gas: (fee) => <String, dynamic>{
        'type': 'Qrc20Gas',
        'coin': fee.coin,
        'gas_price': fee.gasPrice.toString(),
        'gas_limit': fee.gasLimit,
      },
      cosmosGas: (fee) => <String, dynamic>{
        'type': 'CosmosGas',
        'coin': fee.coin,
        'gas_price': fee.gasPrice.toString(),
        'gas_limit': fee.gasLimit,
      },
    );
  }
}
