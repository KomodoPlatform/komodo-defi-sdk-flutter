import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to initiate a new atomic swap.
///
/// This RPC method starts a new swap operation based on the provided
/// swap parameters. The swap can be initiated as either a maker (set_price)
/// or a taker (buy/sell) operation.
class StartSwapRequest
    extends BaseRequest<StartSwapResponse, GeneralErrorResponse> {
  /// Creates a new [StartSwapRequest].
  ///
  /// - [rpcPass]: RPC password for authentication
  /// - [swapRequest]: The swap parameters defining the trade details
  StartSwapRequest({required String rpcPass, required this.swapRequest})
    : super(method: 'start_swap', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// The swap request parameters.
  ///
  /// Contains all the details needed to initiate the swap, including
  /// the coins involved, amounts, and swap method.
  final SwapRequest swapRequest;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({'params': swapRequest.toJson()});
  }

  @override
  StartSwapResponse parse(Map<String, dynamic> json) =>
      StartSwapResponse.parse(json);
}

/// Swap request parameters for initiating a new swap.
///
/// This class encapsulates all the necessary information to start
/// an atomic swap, including the trading pair, amounts, and optional
/// parameters for advanced swap configurations.
class SwapRequest {
  /// Creates a new [SwapRequest].
  ///
  /// - [base]: The base coin ticker
  /// - [rel]: The rel/quote coin ticker
  /// - [baseCoinAmount]: Amount of base coin to trade
  /// - [relCoinAmount]: Amount of rel coin to trade
  /// - [method]: The swap method (setPrice, buy, or sell)
  /// - [senderPubkey]: Optional sender public key for P2P communication
  /// - [destPubkey]: Optional destination public key for targeted swaps
  SwapRequest({
    required this.base,
    required this.rel,
    required this.baseCoinAmount,
    required this.relCoinAmount,
    required this.method,
    this.senderPubkey,
    this.destPubkey,
    this.matchBy,
  });

  /// The base coin ticker.
  ///
  /// This is the coin being bought or sold in the swap.
  final String base;

  /// The rel/quote coin ticker.
  ///
  /// This is the coin used as payment or received in the swap.
  final String rel;

  /// Amount of base coin involved in the swap.
  ///
  /// Expressed as a string to maintain precision. The exact interpretation
  /// depends on the swap method.
  final String baseCoinAmount;

  /// Amount of rel coin involved in the swap.
  ///
  /// Expressed as a string to maintain precision. The exact interpretation
  /// depends on the swap method.
  final String relCoinAmount;

  /// The method used to initiate the swap.
  ///
  /// Determines whether this is a maker order (setPrice) or a taker
  /// order (buy/sell).
  final SwapMethod method;

  /// Optional sender public key.
  ///
  /// Used for P2P communication during the swap negotiation.
  final String? senderPubkey;

  /// Optional destination public key.
  ///
  /// Can be used to target a specific counterparty for the swap.
  final String? destPubkey;

  /// Optional match-by constraint to limit counterparties or orders.
  ///
  /// When provided, the node will attempt to match only against the given
  /// counterparties (pubkeys) or order UUIDs depending on the type.
  final MatchBy? matchBy;

  /// Converts this [SwapRequest] to a JSON map.
  Map<String, dynamic> toJson() => {
    'base': base,
    'rel': rel,
    'base_coin_amount': baseCoinAmount,
    'rel_coin_amount': relCoinAmount,
    'method': method.toJson(),
    if (senderPubkey != null) 'sender_pubkey': senderPubkey,
    if (destPubkey != null) 'dest_pubkey': destPubkey,
    if (matchBy != null) 'match_by': matchBy!.toJson(),
  };
}

/// Response from starting a swap operation.
///
/// Contains the initial status and metadata about the newly created swap.
class StartSwapResponse extends BaseResponse {
  /// Creates a new [StartSwapResponse].
  ///
  /// - [mmrpc]: The RPC version
  /// - [uuid]: Unique identifier for the swap
  /// - [status]: Current status of the swap
  /// - [swapType]: The type of swap (maker or taker)
  StartSwapResponse({
    required super.mmrpc,
    required this.uuid,
    required this.status,
    required this.swapType,
  });

  /// Parses a [StartSwapResponse] from a JSON map.
  factory StartSwapResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return StartSwapResponse(
      mmrpc: json.value<String>('mmrpc'),
      uuid: result.value<String>('uuid'),
      status: result.value<String>('status'),
      swapType: result.value<String>('swap_type'),
    );
  }

  /// Unique identifier for this swap.
  ///
  /// This UUID should be used to track the swap status and perform
  /// any subsequent operations on the swap.
  final String uuid;

  /// Current status of the swap.
  ///
  /// Indicates the initial state of the swap after creation.
  final String status;

  /// The type of swap that was created.
  ///
  /// Typically "Maker" or "Taker" depending on the swap method used.
  final String swapType;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'uuid': uuid, 'status': status, 'swap_type': swapType},
  };
}
