import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Common swap information structure
class SwapInfo {
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

  final String uuid;
  final String myOrderUuid;
  final String takerAmount;
  final String takerCoin;
  final String makerAmount;
  final String makerCoin;
  final String type;
  final String? gui;
  final String? mmVersion;
  final List<String> successEvents;
  final List<String> errorEvents;
  final int? startedAt;
  final int? finishedAt;

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
}