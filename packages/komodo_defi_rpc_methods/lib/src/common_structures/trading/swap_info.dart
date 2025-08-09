import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Comprehensive information about an atomic swap.
/// 
/// This class represents the complete state and history of an atomic swap,
/// including the involved coins, amounts, timeline, and event log. It's used
/// across various RPC responses to provide detailed swap information.
/// 
/// ## Swap Lifecycle:
/// 
/// 1. **Initiation**: Swap is created with initial parameters
/// 2. **Negotiation**: Peers exchange required information
/// 3. **Payment**: Maker and taker send their payments
/// 4. **Claiming**: Recipients claim their payments
/// 5. **Completion**: Swap completes successfully or fails
/// 
/// ## Event Tracking:
/// 
/// The swap tracks two types of events:
/// - **Success Events**: Milestones achieved during normal execution
/// - **Error Events**: Problems encountered during the swap
class SwapInfo {
  /// Creates a new [SwapInfo] instance.
  /// 
  /// All parameters except [startedAt] and [finishedAt] are required.
  /// 
  /// - [uuid]: Unique identifier for the swap
  /// - [myOrderUuid]: UUID of the order that initiated this swap
  /// - [takerAmount]: Amount of taker coin in the swap
  /// - [takerCoin]: Ticker of the taker coin
  /// - [makerAmount]: Amount of maker coin in the swap
  /// - [makerCoin]: Ticker of the maker coin
  /// - [type]: The swap type (Maker or Taker)
  /// - [gui]: Optional GUI identifier that initiated the swap
  /// - [mmVersion]: Market maker version information
  /// - [successEvents]: List of successfully completed swap events
  /// - [errorEvents]: List of error events encountered
  /// - [startedAt]: Unix timestamp when the swap started
  /// - [finishedAt]: Unix timestamp when the swap finished
  SwapInfo({
    required this.uuid,
    required this.myOrderUuid,
    required this.takerAmount,
    required this.takerCoin,
    required this.makerAmount,
    required this.makerCoin,
    required this.type,
    required this.gui,
    required this.mmVersion,
    required this.successEvents,
    required this.errorEvents,
    this.startedAt,
    this.finishedAt,
  });

  /// Creates a [SwapInfo] instance from a JSON map.
  /// 
  /// Parses the swap information from the API response format.
  factory SwapInfo.fromJson(JsonMap json) {
    return SwapInfo(
      uuid: json.value<String>('uuid'),
      myOrderUuid: json.value<String>('my_order_uuid'),
      takerAmount: json.value<String>('taker_amount'),
      takerCoin: json.value<String>('taker_coin'),
      makerAmount: json.value<String>('maker_amount'),
      makerCoin: json.value<String>('maker_coin'),
      type: json.value<String>('type'),
      gui: json.valueOrNull<String?>('gui'),
      mmVersion: json.valueOrNull<String?>('mm_version'),
      successEvents: (json.value<List<dynamic>>('success_events'))
          .map((e) => e as String)
          .toList(),
      errorEvents: (json.value<List<dynamic>>('error_events'))
          .map((e) => e as String)
          .toList(),
      startedAt: json.valueOrNull<int?>('started_at'),
      finishedAt: json.valueOrNull<int?>('finished_at'),
    );
  }

  /// Unique identifier for this swap.
  /// 
  /// This UUID is used to track and reference the swap throughout its lifecycle.
  final String uuid;

  /// UUID of the order that initiated this swap.
  /// 
  /// Links this swap to the original maker order that was matched.
  final String myOrderUuid;

  /// Amount of the taker coin involved in the swap.
  /// 
  /// Expressed as a string to maintain precision. This is the amount
  /// the taker is sending in the swap.
  final String takerAmount;

  /// Ticker of the taker coin.
  /// 
  /// Identifies which coin the taker is sending in the swap.
  final String takerCoin;

  /// Amount of the maker coin involved in the swap.
  /// 
  /// Expressed as a string to maintain precision. This is the amount
  /// the maker is sending in the swap.
  final String makerAmount;

  /// Ticker of the maker coin.
  /// 
  /// Identifies which coin the maker is sending in the swap.
  final String makerCoin;

  /// The type of swap from the user's perspective.
  /// 
  /// Either "Maker" if the user created the initial order, or "Taker"
  /// if the user is taking an existing order.
  final String type;

  /// Optional identifier of the GUI that initiated the swap.
  /// 
  /// Used for tracking which interface or bot created the swap.
  final String? gui;

  /// Version information of the market maker software.
  /// 
  /// Helps with debugging and compatibility tracking.
  final String? mmVersion;

  /// List of successfully completed swap events.
  /// 
  /// Events are added as the swap progresses through its lifecycle.
  /// Examples include:
  /// - "Started"
  /// - "Negotiated"
  /// - "TakerPaymentSent"
  /// - "MakerPaymentReceived"
  /// - "MakerPaymentSpent"
  /// - "Finished"
  final List<String> successEvents;

  /// List of error events encountered during the swap.
  /// 
  /// If the swap fails, this list contains information about what went wrong.
  /// Examples include:
  /// - "NegotiationFailed"
  /// - "TakerPaymentTimeout"
  /// - "MakerPaymentNotReceived"
  final List<String> errorEvents;

  /// Unix timestamp of when the swap started.
  /// 
  /// Recorded when the swap is first initiated.
  final int? startedAt;

  /// Unix timestamp of when the swap finished.
  /// 
  /// Recorded when the swap completes (successfully or with failure).
  final int? finishedAt;

  /// Converts this [SwapInfo] instance to a JSON map.
  /// 
  /// The resulting map can be serialized to JSON and follows the
  /// expected API format.
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'my_order_uuid': myOrderUuid,
    'taker_amount': takerAmount,
    'taker_coin': takerCoin,
    'maker_amount': makerAmount,
    'maker_coin': makerCoin,
    'type': type,
    if (gui != null) 'gui': gui,
    if (mmVersion != null) 'mm_version': mmVersion,
    'success_events': successEvents,
    'error_events': errorEvents,
    if (startedAt != null) 'started_at': startedAt,
    if (finishedAt != null) 'finished_at': finishedAt,
  };

  /// Whether this swap has completed (successfully or with failure).
  /// 
  /// A swap is considered complete if it has a [finishedAt] timestamp.
  bool get isComplete => finishedAt != null;

  /// Whether this swap completed successfully.
  /// 
  /// A swap is successful if it's complete and has no error events.
  bool get isSuccessful => isComplete && errorEvents.isEmpty;

  /// Duration of the swap in seconds.
  /// 
  /// Returns `null` if the swap hasn't started or finished yet.
  int? get durationSeconds {
    if (startedAt == null || finishedAt == null) return null;
    return finishedAt! - startedAt!;
  }
}