import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Init Request
class GetNewAddressTaskInitRequest
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetNewAddressTaskInitRequest({
    required super.rpcPass,
    required this.coin,
    this.accountId,
    this.chain,
    this.gapLimit,
  }) : super(method: 'task::get_new_address::init');

  final String coin;
  final int? accountId;
  final String? chain;
  final int? gapLimit;

  @override
  JsonMap toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'coin': coin,
        if (accountId != null) 'account_id': accountId,
        if (chain != null) 'chain': chain,
        if (gapLimit != null) 'gap_limit': gapLimit,
      },
    };
  }

  @override
  NewTaskResponse parse(JsonMap json) => NewTaskResponse.parse(json);
}

// Status Request
class GetNewAddressTaskStatusRequest
    extends BaseRequest<GetNewAddressTaskStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetNewAddressTaskStatusRequest({
    required super.rpcPass,
    required this.taskId,
    this.forgetIfFinished = true,
  }) : super(method: 'task::get_new_address::status');

  final int taskId;
  final bool forgetIfFinished;

  @override
  JsonMap toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {'task_id': taskId, 'forget_if_finished': forgetIfFinished},
    };
  }

  @override
  GetNewAddressTaskStatusResponse parse(JsonMap json) =>
      GetNewAddressTaskStatusResponse.parse(json);
}

SyncStatusEnum? _statusFromTaskStatus(String status) {
  switch (status) {
    case 'Ok':
      return SyncStatusEnum.success;
    case 'InProgress':
      return SyncStatusEnum.inProgress;
    case 'Error':
      return SyncStatusEnum.error;
    default:
      return null;
  }
}

// Status Response
class GetNewAddressTaskStatusResponse extends BaseResponse {
  GetNewAddressTaskStatusResponse({
    required super.mmrpc,
    required this.status,
    required this.details,
  });

  factory GetNewAddressTaskStatusResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    final status = _statusFromTaskStatus(result.value<String>('status'));

    return GetNewAddressTaskStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: status!,
      details: ResponseDetails<NewAddressInfo, GeneralErrorResponse>(
        data:
            status == SyncStatusEnum.success
                ? NewAddressInfo.fromJson(result.value<JsonMap>('details'))
                : null,
        error:
            status == SyncStatusEnum.error
                ? GeneralErrorResponse.parse(result.value<JsonMap>('details'))
                : null,
        description:
            status == SyncStatusEnum.inProgress
                ? result.value<String>('details')
                : null,
      ),
    );
  }

  final SyncStatusEnum status;
  final ResponseDetails<NewAddressInfo, GeneralErrorResponse> details;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'status': status, 'details': details.toJson()},
    };
  }
}

// Cancel Request
class GetNewAddressTaskCancelRequest
    extends BaseRequest<GetNewAddressTaskCancelResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetNewAddressTaskCancelRequest({required super.rpcPass, required this.taskId})
    : super(method: 'task::get_new_address::cancel');

  final int taskId;

  @override
  JsonMap toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {'task_id': taskId},
    };
  }

  @override
  GetNewAddressTaskCancelResponse parse(JsonMap json) =>
      GetNewAddressTaskCancelResponse.parse(json);
}

// Cancel Response
class GetNewAddressTaskCancelResponse extends BaseResponse {
  GetNewAddressTaskCancelResponse({required super.mmrpc, required this.result});

  factory GetNewAddressTaskCancelResponse.parse(JsonMap json) {
    return GetNewAddressTaskCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() {
    return {'mmrpc': mmrpc, 'result': result};
  }
}
