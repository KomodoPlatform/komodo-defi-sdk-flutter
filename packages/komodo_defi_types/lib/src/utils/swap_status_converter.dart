import 'package:json_annotation/json_annotation.dart';
import 'package:komodo_defi_types/src/swap/swap_status.dart';

/// Converts [SwapStatus] enum values to and from JSON.
///
/// This converter handles the serialization of SwapStatus enum values
/// using their string representation for JSON compatibility.
/// It supports both the current format and legacy format for backwards
/// compatibility.
class SwapStatusConverter implements JsonConverter<SwapStatus, String> {
  const SwapStatusConverter();

  @override
  SwapStatus fromJson(String json) {
    // First try to match by the toString() format
    for (final status in SwapStatus.values) {
      if (status.toString() == json) {
        return status;
      }
    }

    // Fall back to legacy format: SwapStatus.enumName
    try {
      return SwapStatus.values.firstWhere(
        (status) => status.toString() == 'SwapStatus.$json',
      );
    } catch (e) {
      // Last resort: try to match by enum name
      switch (json) {
        case 'initializing':
          return SwapStatus.initializing;
        case 'searching_for_orders':
          return SwapStatus.searchingForOrders;
        case 'placing_maker_order':
          return SwapStatus.placingMakerOrder;
        case 'placing_taker_order':
          return SwapStatus.placingTakerOrder;
        case 'in_progress':
          return SwapStatus.inProgress;
        case 'complete':
          return SwapStatus.complete;
        case 'error':
          return SwapStatus.error;
        default:
          throw ArgumentError('Unknown SwapStatus: $json');
      }
    }
  }

  @override
  String toJson(SwapStatus object) => object.toString();
}
