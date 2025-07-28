import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Determines how pubkeys should be unbanned
enum UnbanType {
  all,
  few;

  @override
  String toString() => switch (this) {
    UnbanType.all => 'All',
    UnbanType.few => 'Few',
  };

  static UnbanType parse(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue == 'all') {
      return UnbanType.all;
    } else if (lowerValue == 'few') {
      return UnbanType.few;
    } else {
      throw ArgumentError(
        'Invalid UnbanType value: $value. Expected "all" or "few".',
      );
    }
  }
}

/// Parameter for [UnbanPubkeysRequest]
class UnbanBy extends Equatable {
  const UnbanBy.all() : type = UnbanType.all, data = null;
  const UnbanBy.few(this.data) : type = UnbanType.few;

  final UnbanType type;
  final List<String>? data;

  JsonMap toJson() => {'type': type.toString(), if (data != null) 'data': data};

  @override
  List<Object?> get props => [type, data];
}

class UnbanPubkeysRequest
    extends BaseRequest<UnbanPubkeysResponse, GeneralErrorResponse> {
  UnbanPubkeysRequest({required String rpcPass, required this.unbanBy})
    : super(method: 'unban_pubkeys', rpcPass: rpcPass, mmrpc: null);

  final UnbanBy unbanBy;

  @override
  JsonMap toJson() => {...super.toJson(), 'unban_by': unbanBy.toJson()};

  @override
  UnbanPubkeysResponse parse(JsonMap json) => UnbanPubkeysResponse.parse(json);
}

class UnbanPubkeysResponse extends BaseResponse {
  UnbanPubkeysResponse({required super.mmrpc, required this.result});

  factory UnbanPubkeysResponse.parse(JsonMap json) => UnbanPubkeysResponse(
    mmrpc: json.valueOrNull<String>('mmrpc'),
    result: UnbanPubkeysResult.fromJson(json.value<JsonMap>('result')),
  );

  final UnbanPubkeysResult result;

  @override
  JsonMap toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}

class UnbanPubkeysResult extends Equatable {
  const UnbanPubkeysResult({
    required this.stillBanned,
    required this.unbanned,
    required this.wereNotBanned,
  });

  factory UnbanPubkeysResult.fromJson(JsonMap json) {
    final still = json.valueOrNull<JsonMap>('still_banned') ?? {};
    final unbanned = json.valueOrNull<JsonMap>('unbanned') ?? {};
    return UnbanPubkeysResult(
      stillBanned: still.map(
        (k, v) => MapEntry(k, BannedPubkeyInfo.fromJson(v as JsonMap)),
      ),
      unbanned: unbanned.map(
        (k, v) => MapEntry(k, BannedPubkeyInfo.fromJson(v as JsonMap)),
      ),
      wereNotBanned:
          (json.valueOrNull<List<dynamic>>('were_not_banned') ?? [])
              .cast<String>(),
    );
  }

  final Map<String, BannedPubkeyInfo> stillBanned;
  final Map<String, BannedPubkeyInfo> unbanned;
  final List<String> wereNotBanned;

  JsonMap toJson() => {
    'still_banned': stillBanned.map((k, v) => MapEntry(k, v.toJson())),
    'unbanned': unbanned.map((k, v) => MapEntry(k, v.toJson())),
    'were_not_banned': wereNotBanned,
  };

  @override
  List<Object?> get props => [stillBanned, unbanned, wereNotBanned];
}

class BannedPubkeyInfo extends Equatable {
  const BannedPubkeyInfo({required this.type, required this.reason});

  factory BannedPubkeyInfo.fromJson(JsonMap json) => BannedPubkeyInfo(
    type: json.value<String>('type'),
    reason: json.value<String>('reason'),
  );

  final String type;
  final String reason;

  JsonMap toJson() => {'type': type, 'reason': reason};

  @override
  List<Object?> get props => [type, reason];
}
