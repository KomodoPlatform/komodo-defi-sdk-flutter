import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

import 'streaming_common.dart';

/// stream::order_status::enable
class StreamOrderStatusEnableRequest extends BaseRequest<
    StreamEnableResponse<OrderStatusEvent>, GeneralErrorResponse> {
  StreamOrderStatusEnableRequest({required String rpcPass, this.clientId})
    : super(
        method: 'stream::order_status::enable',
        rpcPass: rpcPass,
        mmrpc: RpcVersion.v2_0,
      );

  final int? clientId;

  @override
  JsonMap toJson() => super.toJson().deepMerge({
    'params': {if (clientId != null) 'client_id': clientId},
  });

  @override
  StreamEnableResponse<OrderStatusEvent> parse(JsonMap json) =>
      StreamEnableResponse<OrderStatusEvent>.parse(json);
}


