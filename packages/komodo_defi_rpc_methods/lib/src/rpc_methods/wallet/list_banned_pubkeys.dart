import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ListBannedPubkeysRequest
    extends BaseRequest<ListBannedPubkeysResponse, GeneralErrorResponse> {
  ListBannedPubkeysRequest({required String rpcPass})
    : super(method: 'list_banned_pubkeys', rpcPass: rpcPass, mmrpc: null);

  @override
  JsonMap toJson() => super.toJson();

  @override
  ListBannedPubkeysResponse parse(JsonMap json) =>
      ListBannedPubkeysResponse.parse(json);
}

class ListBannedPubkeysResponse extends BaseResponse {
  ListBannedPubkeysResponse({required super.mmrpc, required this.result});

  factory ListBannedPubkeysResponse.parse(JsonMap json) =>
      ListBannedPubkeysResponse(
        mmrpc: json.valueOrNull<String>('mmrpc'),
        result: json
            .value<JsonMap>('result')
            .map(
              (k, v) => MapEntry(k, BannedPubkeyDetails.fromJson(v as JsonMap)),
            ),
      );

  final Map<String, BannedPubkeyDetails> result;

  @override
  JsonMap toJson() => {
    'mmrpc': mmrpc,
    'result': result.map((k, v) => MapEntry(k, v.toJson())),
  };
}

class BannedPubkeyDetails extends Equatable {
  const BannedPubkeyDetails({
    required this.type,
    this.reason,
    this.causedByEvent,
    this.causedBySwap,
  });

  factory BannedPubkeyDetails.fromJson(JsonMap json) => BannedPubkeyDetails(
    type: json.value<String>('type'),
    reason: json.valueOrNull<String>('reason'),
    causedByEvent: json.valueOrNull<JsonMap>('caused_by_event'),
    causedBySwap: json.valueOrNull<String>('caused_by_swap'),
  );

  final String type;
  final String? reason;
  final JsonMap? causedByEvent;
  final String? causedBySwap;

  JsonMap toJson() => {
    'type': type,
    if (reason != null) 'reason': reason,
    if (causedByEvent != null) 'caused_by_event': causedByEvent,
    if (causedBySwap != null) 'caused_by_swap': causedBySwap,
  };

  @override
  List<Object?> get props => [type, reason, causedByEvent, causedBySwap];
}
