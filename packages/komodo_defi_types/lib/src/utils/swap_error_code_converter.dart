import 'package:json_annotation/json_annotation.dart';
import 'package:komodo_defi_types/src/swap/swap_error_code.dart';

/// Converts [SwapErrorCode] enum values to and from JSON.
///
/// This converter handles the serialization of SwapErrorCode enum values
/// using their string representation for JSON compatibility.
/// It supports both the current format and legacy format for backwards
/// compatibility.
class SwapErrorCodeConverter implements JsonConverter<SwapErrorCode, String> {
  const SwapErrorCodeConverter();

  @override
  SwapErrorCode fromJson(String json) {
    // First try to match by the toString() format
    for (final errorCode in SwapErrorCode.values) {
      if (errorCode.toString() == json) {
        return errorCode;
      }
    }

    // Fall back to legacy format: SwapErrorCode.enumName
    try {
      return SwapErrorCode.values.firstWhere(
        (errorCode) => errorCode.toString() == 'SwapErrorCode.$json',
      );
    } catch (e) {
      // Last resort: try to match by enum name
      switch (json) {
        case 'insufficient_funds':
          return SwapErrorCode.insufficientFunds;
        case 'invalid_trading_pair':
          return SwapErrorCode.invalidTradingPair;
        case 'network_error':
          return SwapErrorCode.networkError;
        case 'order_matching_failed':
          return SwapErrorCode.orderMatchingFailed;
        case 'price_slippage':
          return SwapErrorCode.priceSlippage;
        case 'user_cancelled':
          return SwapErrorCode.userCancelled;
        case 'asset_not_activated':
          return SwapErrorCode.assetNotActivated;
        case 'unknown_error':
          return SwapErrorCode.unknownError;
        default:
          throw ArgumentError('Unknown SwapErrorCode: $json');
      }
    }
  }

  @override
  String toJson(SwapErrorCode object) => object.toString();
}
