import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

import 'streaming_common.dart';

/// stream::network::enable
class StreamNetworkEnableRequest extends BaseRequest<
    StreamEnableResponse<NetworkEvent>, GeneralErrorResponse> {
  StreamNetworkEnableRequest({
    required String rpcPass,
    this.clientId,
    this.config,
    this.alwaysSend,
  }) : super(
         method: 'stream::network::enable',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final int? clientId;
  final StreamConfig? config;
  final bool? alwaysSend;

  @override
  JsonMap toJson() => super.toJson().deepMerge({
    'params': {
      if (clientId != null) 'client_id': clientId,
      if (config != null) 'config': config!.toRpcParams(),
      if (alwaysSend != null) 'always_send': alwaysSend,
    },
  });

  @override
  StreamEnableResponse<NetworkEvent> parse(JsonMap json) =>
      StreamEnableResponse<NetworkEvent>.parse(json);
}


