import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'fee_info.freezed.dart';
// We are doing manual fromJson/toJson, so no need for part 'fee_info.g.dart';

/// A union representing six possible fee types:
/// - UtxoFixed
/// - UtxoPerKbyte
/// - EthGas
/// - Qrc20Gas
/// - CosmosGas
/// - Tendermint
@Freezed()
sealed class FeeInfo with _$FeeInfo {
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
        final totalGasFee = json['total_fee'] != null
            ? Decimal.parse(json['total_fee'].toString())
            : null;
        return FeeInfo.ethGas(
          coin: json['coin'] as String? ?? '',
          // If JSON provides e.g. "0.000000003", parse to Decimal => 3e-9
          gasPrice: Decimal.parse(json['gas_price'].toString()),
          gas: json['gas'] as int,
          totalGasFee: totalGasFee,
        );
      case 'Qrc20Gas':
        final totalGasFee = json['total_gas_fee'] != null
            ? Decimal.parse(json['total_gas_fee'].toString())
            : null;
        return FeeInfo.qrc20Gas(
          coin: json['coin'] as String? ?? '',
          gasPrice: Decimal.parse(json['gas_price'].toString()),
          gasLimit: json['gas_limit'] as int,
          totalGasFee: totalGasFee,
        );
      case 'Tendermint':
        return FeeInfo.tendermint(
          coin: json['coin'] as String? ?? '',
          amount: Decimal.parse(json['amount'].toString()),
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
  ///   "gas": 21000,
  ///   "total_fee": "0.000021"
  /// }
  /// ```
  /// Interpreted as: 3 Gwei -> total fee = 0.000000003 ETH * 21000 = 0.000063 ETH.
  /// If `totalGasFee` is provided, it will be used directly instead of calculating from gasPrice * gas.
  const factory FeeInfo.ethGas({
    required String coin,

    /// Gas price in ETH. e.g. "0.000000003" => 3 Gwei
    required Decimal gasPrice,

    /// Gas limit (number of gas units)
    required int gas,

    /// Optional total fee override. If provided, this value will be used directly
    /// instead of calculating from gasPrice * gas.
    Decimal? totalGasFee,
  }) = FeeInfoEthGas;

  /// 4) Qtum/QRC20-like gas, specifying `gasPrice` (in coin units) and `gasLimit`.
  const factory FeeInfo.qrc20Gas({
    required String coin,

    /// Gas price in coin units. e.g. "0.000000004"
    required Decimal gasPrice,

    /// Gas limit
    required int gasLimit,

    /// Optional total gas fee in coin units. If not provided, it will be calculated
    /// as `gasPrice * gasLimit`.
    Decimal? totalGasFee,
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

  /// 6) Tendermint fee, with fixed `amount` and `gasLimit`.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "type": "Tendermint",
  ///   "coin": "IRIS",
  ///   "amount": "0.038553",
  ///   "gas_limit": 100000
  /// }
  /// ```
  /// Total fee is just the amount (not calculated from gas * price)
  const factory FeeInfo.tendermint({
    required String coin,

    /// The fee amount in coin units
    required Decimal amount,

    /// Gas limit
    required int gasLimit,
  }) = FeeInfoTendermint;

  /// A convenience getter returning the *total fee* in the coin's main units.
  Decimal get totalFee => switch (this) {
        FeeInfoUtxoFixed(:final amount) => amount,
        FeeInfoUtxoPerKbyte(:final amount) => amount,
        FeeInfoEthGas(:final gasPrice, :final gas, :final totalGasFee) =>
          totalGasFee ?? (gasPrice * Decimal.fromInt(gas)),
        FeeInfoQrc20Gas(:final gasPrice, :final gasLimit, :final totalGasFee) =>
          totalGasFee ?? (gasPrice * Decimal.fromInt(gasLimit)),
        FeeInfoCosmosGas(:final gasPrice, :final gasLimit) =>
          gasPrice * Decimal.fromInt(gasLimit),
        FeeInfoTendermint(:final amount) => amount,
      };

  /// Convert this [FeeInfo] to a JSON object matching the mmRPC 2.0 docs.
  JsonMap toJson() => switch (this) {
        FeeInfoUtxoFixed(:final coin, :final amount) => {
            'type': 'UtxoFixed',
            'coin': coin,
            'amount': amount.toString(),
          },
        FeeInfoUtxoPerKbyte(:final coin, :final amount) => {
            'type': 'UtxoPerKbyte',
            'coin': coin,
            'amount': amount.toString(),
          },
        FeeInfoEthGas(
          :final coin,
          :final gasPrice,
          :final gas,
          :final totalGasFee
        ) =>
          {
            'type': 'Eth',
            'coin': coin,
            'gas_price': gasPrice.toString(),
            'gas': gas,
            if (totalGasFee != null) 'total_fee': totalGasFee.toString(),
          },
        FeeInfoQrc20Gas(
          :final coin,
          :final gasPrice,
          :final gasLimit,
          :final totalGasFee
        ) =>
          {
            'type': 'Qrc20Gas',
            'coin': coin,
            'gas_price': gasPrice.toDouble(),
            'gas_limit': gasLimit,
            if (totalGasFee != null) 'total_gas_fee': totalGasFee.toString(),
          },
        FeeInfoCosmosGas(:final coin, :final gasPrice, :final gasLimit) => {
            'type': 'CosmosGas',
            'coin': coin,
            'gas_price': gasPrice.toDouble(),
            'gas_limit': gasLimit,
          },
        // TODO: update to Tendermint for KDF v2.5.0-beta
        FeeInfoTendermint(:final coin, :final amount, :final gasLimit) => {
            'type': 'CosmosGas',
            'coin': coin,
            'gas_price': gasLimit > 0
                ? (amount / Decimal.fromInt(gasLimit)).toDouble()
                : 0.0,
            'gas_limit': gasLimit,
          },
      };
}

/// Extension methods providing Freezed-like functionality
extension FeeInfoMaybeMap on FeeInfo {
  /// Equivalent to Freezed's maybeMap functionality using Dart's pattern matching
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    required TResult Function() orElse,
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    TResult Function(FeeInfoTendermint value)? tendermint,
  }) =>
      switch (this) {
        final FeeInfoUtxoFixed fee when utxoFixed != null => utxoFixed(fee),
        final FeeInfoUtxoPerKbyte fee when utxoPerKbyte != null =>
          utxoPerKbyte(fee),
        final FeeInfoEthGas fee when ethGas != null => ethGas(fee),
        final FeeInfoQrc20Gas fee when qrc20Gas != null => qrc20Gas(fee),
        final FeeInfoCosmosGas fee when cosmosGas != null => cosmosGas(fee),
        final FeeInfoTendermint fee when tendermint != null => tendermint(fee),
        _ => orElse(),
      };
}
