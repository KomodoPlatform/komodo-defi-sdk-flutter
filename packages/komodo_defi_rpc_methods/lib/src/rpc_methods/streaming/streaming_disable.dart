import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

import 'streaming_common.dart';

/// stream::disable
class StreamDisableRequest
    extends BaseRequest<StreamDisableResponse, GeneralErrorResponse> {
  StreamDisableRequest({
    required String rpcPass,
    required this.clientId,
    required this.streamerId,
  }) : super(
         method: 'stream::disable',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final int clientId;
  final String streamerId;

  @override
  JsonMap toJson() => super.toJson().deepMerge({
    'params': {'client_id': clientId, 'streamer_id': streamerId},
  });

  @override
  StreamDisableResponse parse(JsonMap json) =>
      StreamDisableResponse.parse(json);
}


