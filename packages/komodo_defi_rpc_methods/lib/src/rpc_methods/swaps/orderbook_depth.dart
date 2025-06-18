import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'orderbook_depth.freezed.dart';
part 'orderbook_depth.g.dart';

/// Request to get the number of asks and bids for specified trading pairs
class OrderbookDepthRequest
    extends BaseRequest<OrderbookDepthResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OrderbookDepthRequest({required String rpcPass, required this.pairs})
    : super(method: 'orderbook_depth', rpcPass: rpcPass, mmrpc: null);

  /// Array of trading pairs, each pair is an array of 2 strings
  final List<List<String>> pairs;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({'pairs': pairs});
  }

  @override
  OrderbookDepthResponse parse(Map<String, dynamic> json) =>
      OrderbookDepthResponse.parse(json);
}

@freezed
abstract class OrderbookDepthResponse
    with _$OrderbookDepthResponse
    implements BaseResponse {
  const factory OrderbookDepthResponse({
    required List<PairDepth> result,
    String? mmrpc,
    String? id,
  }) = _OrderbookDepthResponse;
  const OrderbookDepthResponse._();

  factory OrderbookDepthResponse.fromJson(JsonMap json) =>
      _$OrderbookDepthResponseFromJson(json);

  factory OrderbookDepthResponse.parse(Map<String, dynamic> json) =>
      _$OrderbookDepthResponseFromJson(json);

  @override
  BaseResponse parse(Map<String, dynamic> json) =>
      OrderbookDepthResponse.parse(json);
}

/// Represents the depth information for a trading pair
@freezed
abstract class PairDepth with _$PairDepth {
  const factory PairDepth({
    required List<String> pair,
    required DepthInfo depth,
  }) = _PairDepth;
  const PairDepth._();

  factory PairDepth.fromJson(JsonMap json) => _$PairDepthFromJson(json);
}

/// Represents the depth information with asks and bids count
@freezed
abstract class DepthInfo with _$DepthInfo {
  const factory DepthInfo({required int asks, required int bids}) = _DepthInfo;
  const DepthInfo._();

  factory DepthInfo.fromJson(JsonMap json) => _$DepthInfoFromJson(json);
}
