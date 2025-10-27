import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

import 'streaming_common.dart';

/// stream::orderbook::enable
class StreamOrderbookEnableRequest
    extends BaseRequest<StreamEnableResponse, GeneralErrorResponse> {
  StreamOrderbookEnableRequest({
    required String rpcPass,
    required this.base,
    required this.rel,
    this.clientId,
  }) : super(
         method: 'stream::orderbook::enable',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String base;
  final String rel;
  final int? clientId;

  @override
  JsonMap toJson() => super.toJson().deepMerge({
    'params': {
      'base': base,
      'rel': rel,
      if (clientId != null) 'client_id': clientId,
    },
  });

  @override
  StreamEnableResponse parse(JsonMap json) => StreamEnableResponse.parse(json);
}


