import 'package:komodo_defi_rpc_methods/src/rpc_methods/swaps/legacy/order_confirmation_settings.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base class for order match events
abstract class OrderMatchEvent {
  const OrderMatchEvent({
    required this.method,
    required this.senderPubkey,
    required this.destPubKey,
    required this.takerOrderUuid,
    required this.makerOrderUuid,
  });

  factory OrderMatchEvent.fromJson(Map<String, dynamic> json) {
    final method = json.value<String>('method');
    switch (method) {
      case 'request':
        return OrderMatchRequest.fromJson(json);
      case 'reserved':
        return OrderMatchReserved.fromJson(json);
      case 'connect':
        return OrderMatchConnect.fromJson(json);
      case 'connected':
        return OrderMatchConnected.fromJson(json);
      default:
        throw ArgumentError('Unknown match event method: $method');
    }
  }

  final String method;
  final String senderPubkey;
  final String destPubKey;
  final String takerOrderUuid;
  final String makerOrderUuid;

  Map<String, dynamic> toJson();
}

/// Request match event for taker orders
class OrderMatchRequest extends OrderMatchEvent {
  const OrderMatchRequest({
    required super.method,
    required super.senderPubkey,
    required super.destPubKey,
    required super.takerOrderUuid,
    required super.makerOrderUuid,
    required this.action,
    required this.base,
    required this.rel,
    required this.baseAmount,
    required this.baseAmountRat,
    required this.relAmount,
    required this.relAmountRat,
    required this.uuid,
    required this.matchBy,
    required this.confSettings,
  });

  factory OrderMatchRequest.fromJson(Map<String, dynamic> json) {
    return OrderMatchRequest(
      method: json.value<String>('method'),
      senderPubkey: json.value<String>('sender_pubkey'),
      destPubKey: json.value<String>('dest_pub_key'),
      takerOrderUuid: json.value<String>('uuid'),
      makerOrderUuid: '', // Not present in request events
      action: json.value<String>('action'),
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
      baseAmount: json.value<String>('base_amount'),
      baseAmountRat: RationalValue.fromJson(
          json.value<List<dynamic>>('base_amount_rat')),
      relAmount: json.value<String>('rel_amount'),
      relAmountRat: RationalValue.fromJson(
          json.value<List<dynamic>>('rel_amount_rat')),
      uuid: json.value<String>('uuid'),
      matchBy: OrderMatchBy.fromJson(json.value<JsonMap>('match_by')),
      confSettings: OrderConfirmationSettings.fromJson(
          json.value<JsonMap>('conf_settings')),
    );
  }

  final String action;
  final String base;
  final String rel;
  final String baseAmount;
  final RationalValue baseAmountRat;
  final String relAmount;
  final RationalValue relAmountRat;
  final String uuid;
  final OrderMatchBy matchBy;
  final OrderConfirmationSettings confSettings;

  @override
  Map<String, dynamic> toJson() => {
    'method': method,
    'sender_pubkey': senderPubkey,
    'dest_pub_key': destPubKey,
    'action': action,
    'base': base,
    'rel': rel,
    'base_amount': baseAmount,
    'base_amount_rat': baseAmountRat.toJson(),
    'rel_amount': relAmount,
    'rel_amount_rat': relAmountRat.toJson(),
    'uuid': uuid,
    'match_by': matchBy.toJson(),
    'conf_settings': confSettings.toJson(),
  };
}

/// Reserved match event
class OrderMatchReserved extends OrderMatchEvent {
  const OrderMatchReserved({
    required super.method,
    required super.senderPubkey,
    required super.destPubKey,
    required super.takerOrderUuid,
    required super.makerOrderUuid,
    required this.base,
    required this.rel,
    required this.baseAmount,
    required this.baseAmountRat,
    required this.relAmount,
    required this.relAmountRat,
    required this.confSettings,
  });

  factory OrderMatchReserved.fromJson(Map<String, dynamic> json) {
    return OrderMatchReserved(
      method: json.value<String>('method'),
      senderPubkey: json.value<String>('sender_pubkey'),
      destPubKey: json.value<String>('dest_pub_key'),
      takerOrderUuid: json.value<String>('taker_order_uuid'),
      makerOrderUuid: json.value<String>('maker_order_uuid'),
      base: json.value<String>('base'),
      rel: json.value<String>('rel'),
      baseAmount: json.value<String>('base_amount'),
      baseAmountRat: RationalValue.fromJson(
          json.value<List<dynamic>>('base_amount_rat')),
      relAmount: json.value<String>('rel_amount'),
      relAmountRat: RationalValue.fromJson(
          json.value<List<dynamic>>('rel_amount_rat')),
      confSettings: OrderConfirmationSettings.fromJson(
          json.value<JsonMap>('conf_settings')),
    );
  }

  final String base;
  final String rel;
  final String baseAmount;
  final RationalValue baseAmountRat;
  final String relAmount;
  final RationalValue relAmountRat;
  final OrderConfirmationSettings confSettings;

  @override
  Map<String, dynamic> toJson() => {
    'method': method,
    'sender_pubkey': senderPubkey,
    'dest_pub_key': destPubKey,
    'taker_order_uuid': takerOrderUuid,
    'maker_order_uuid': makerOrderUuid,
    'base': base,
    'rel': rel,
    'base_amount': baseAmount,
    'base_amount_rat': baseAmountRat.toJson(),
    'rel_amount': relAmount,
    'rel_amount_rat': relAmountRat.toJson(),
    'conf_settings': confSettings.toJson(),
  };
}

/// Connect match event
class OrderMatchConnect extends OrderMatchEvent {
  const OrderMatchConnect({
    required super.method,
    required super.senderPubkey,
    required super.destPubKey,
    required super.takerOrderUuid,
    required super.makerOrderUuid,
  });

  factory OrderMatchConnect.fromJson(Map<String, dynamic> json) {
    return OrderMatchConnect(
      method: json.value<String>('method'),
      senderPubkey: json.value<String>('sender_pubkey'),
      destPubKey: json.value<String>('dest_pub_key'),
      takerOrderUuid: json.value<String>('taker_order_uuid'),
      makerOrderUuid: json.value<String>('maker_order_uuid'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'method': method,
    'sender_pubkey': senderPubkey,
    'dest_pub_key': destPubKey,
    'taker_order_uuid': takerOrderUuid,
    'maker_order_uuid': makerOrderUuid,
  };
}

/// Connected match event
class OrderMatchConnected extends OrderMatchEvent {
  const OrderMatchConnected({
    required super.method,
    required super.senderPubkey,
    required super.destPubKey,
    required super.takerOrderUuid,
    required super.makerOrderUuid,
  });

  factory OrderMatchConnected.fromJson(Map<String, dynamic> json) {
    return OrderMatchConnected(
      method: json.value<String>('method'),
      senderPubkey: json.value<String>('sender_pubkey'),
      destPubKey: json.value<String>('dest_pub_key'),
      takerOrderUuid: json.value<String>('taker_order_uuid'),
      makerOrderUuid: json.value<String>('maker_order_uuid'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'method': method,
    'sender_pubkey': senderPubkey,
    'dest_pub_key': destPubKey,
    'taker_order_uuid': takerOrderUuid,
    'maker_order_uuid': makerOrderUuid,
  };
}

/// Match by criteria for orders
class OrderMatchBy {
  const OrderMatchBy({required this.type});

  factory OrderMatchBy.fromJson(Map<String, dynamic> json) {
    return OrderMatchBy(type: json.value<String>('type'));
  }

  final String type;

  Map<String, dynamic> toJson() => {'type': type};
}

/// Complete match data including events and metadata
class OrderMatch {
  const OrderMatch({
    required this.lastUpdated,
    this.request,
    this.reserved,
    this.connect,
    this.connected,
  });

  factory OrderMatch.fromJson(Map<String, dynamic> json) {
    return OrderMatch(
      request: json.valueOrNull<JsonMap>('request') != null
          ? OrderMatchRequest.fromJson(json.value<JsonMap>('request'))
          : null,
      reserved: json.valueOrNull<JsonMap>('reserved') != null
          ? OrderMatchReserved.fromJson(json.value<JsonMap>('reserved'))
          : null,
      connect: json.valueOrNull<JsonMap>('connect') != null
          ? OrderMatchConnect.fromJson(json.value<JsonMap>('connect'))
          : null,
      connected: json.valueOrNull<JsonMap>('connected') != null
          ? OrderMatchConnected.fromJson(json.value<JsonMap>('connected'))
          : null,
      lastUpdated: json.value<int>('last_updated'),
    );
  }

  final OrderMatchRequest? request;
  final OrderMatchReserved? reserved;
  final OrderMatchConnect? connect;
  final OrderMatchConnected? connected;
  final int lastUpdated;

  Map<String, dynamic> toJson() => {
    if (request != null) 'request': request!.toJson(),
    if (reserved != null) 'reserved': reserved!.toJson(),
    if (connect != null) 'connect': connect!.toJson(),
    if (connected != null) 'connected': connected!.toJson(),
    'last_updated': lastUpdated,
  };
}
