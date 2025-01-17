import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ScanForNewAddressesStatusRequest
    extends BaseRequest<ScanForNewAddressesStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ScanForNewAddressesStatusRequest({
    required super.rpcPass,
    required this.taskId,
    this.forgetIfFinished = true,
  }) : super(method: 'task::scan_for_new_addresses::status');

  final int taskId;
  final bool forgetIfFinished;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'task_id': taskId,
        'forget_if_finished': forgetIfFinished,
      },
    };
  }

  @override
  ScanForNewAddressesStatusResponse parse(Map<String, dynamic> json) =>
      ScanForNewAddressesStatusResponse.parse(json);
}

class ScanForNewAddressesStatusResponse extends BaseResponse {
  ScanForNewAddressesStatusResponse({
    required super.mmrpc,
    required this.status,
    this.details,
  });

  @override
  factory ScanForNewAddressesStatusResponse.parse(Map<String, dynamic> json) {
    return ScanForNewAddressesStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: json.value<String>('result', 'status'),
      details:
          json.valueOrNull<Map<String, dynamic>>('result', 'details') != null
              ? ScanAddressesInfo.fromJson(
                  json.value<Map<String, dynamic>>('result', 'details'),
                )
              : null,
    );
  }

  final String status;
  final ScanAddressesInfo? details;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {
        'status': status,
        if (details != null) 'details': details!.toJson(),
      },
    };
  }
}
