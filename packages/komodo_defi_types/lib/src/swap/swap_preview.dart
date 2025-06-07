import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/src/swap/trading_fee.dart';

/// Preview information for a swap operation
class SwapPreview extends Equatable {
  const SwapPreview({
    required this.baseCoinFee,
    required this.relCoinFee,
    required this.totalFees,
    required this.volume,
    this.takerFee,
    this.feeToSendTakerFee,
  });

  /// Fee for the base coin
  final TradingFee baseCoinFee;

  /// Fee for the rel coin
  final TradingFee relCoinFee;

  /// Total fees for the swap
  final List<TradingFee> totalFees;

  /// Volume of the trade
  final Decimal volume;

  /// Taker fee information
  final TradingFee? takerFee;

  /// Fee to send the taker fee
  final TradingFee? feeToSendTakerFee;

  @override
  List<Object?> get props => [
        baseCoinFee,
        relCoinFee,
        totalFees,
        volume,
        takerFee,
        feeToSendTakerFee,
      ];
}
