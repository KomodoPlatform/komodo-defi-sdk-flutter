import 'dart:convert';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Init Request
class AccountBalanceInitRequest
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  AccountBalanceInitRequest({
    required super.rpcPass,
    required this.coin,
    required this.accountIndex,
  }) : super(method: 'task::account_balance::init');

  final String coin;
  final int accountIndex;

  @override
  JsonMap toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'coin': coin,
        'account_index': accountIndex,
      },
    };
  }

  @override
  NewTaskResponse parse(JsonMap json) => NewTaskResponse.parse(json);
}

// Status Request
class AccountBalanceStatusRequest
    extends BaseRequest<AccountBalanceStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  AccountBalanceStatusRequest({
    required super.rpcPass,
    required this.taskId,
    this.forgetIfFinished = true,
  }) : super(method: 'task::account_balance::status');

  final int taskId;
  final bool forgetIfFinished;

  @override
  JsonMap toJson() {
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
  AccountBalanceStatusResponse parse(JsonMap json) =>
      AccountBalanceStatusResponse.parse(json);
}

// TODO: Make re-usable
class ResponseDetails<T, R extends GeneralErrorResponse> {
  ResponseDetails({
    required this.data,
    required this.error,
    this.description,
  }) : assert(
          [data, error, description].where((e) => e != null).length == 1,
          'Of the three fields, exactly one must be non-null',
        );

  final T? data;
  final R? error;

  // Usually only non-null for in-progress tasks (TODO! Confirm)
  final String? description;

  void get throwIfError {
    if (error != null) {
      throw error!;
    }
  }

  // Result get result => data != null ? Result.success : Result.error;

  // T get dataOrThrow {
  //   if (data == null) {
  //     throw error!;
  //   }
  //   return data!;
  // }

  T? get dataOrNull => data;

  JsonMap toJson() {
    return {
      if (data != null) 'data': jsonEncode(data),
      if (error != null) 'error': jsonEncode(error),
      if (description != null) 'description': description,
    };
  }
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
class AccountBalanceStatusResponse extends BaseResponse {
  AccountBalanceStatusResponse({
    required super.mmrpc,
    required this.status,
    required this.details,
  });

  // TODO: Move this logic to be re-usable
  factory AccountBalanceStatusResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    final status = _statusFromTaskStatus(result.value<String>('status'));

    return AccountBalanceStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: status!,
      // details: status == 'Ok' ? AccountBalanceInfo.fromJson(details) : details,
      details: ResponseDetails<AccountBalanceInfo, GeneralErrorResponse>(
        data: status == SyncStatusEnum.success
            ? AccountBalanceInfo.fromJson(result.value<JsonMap>('details'))
            : null,
        error: status == SyncStatusEnum.error
            ? GeneralErrorResponse.parse(result.value<JsonMap>('details'))
            : null,
        description: status == SyncStatusEnum.inProgress
            ? result.value<String>('details')
            : null,
      ),
    );
  }

  final SyncStatusEnum status;
  final ResponseDetails<AccountBalanceInfo, GeneralErrorResponse> details;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {
        'status': status,
        // 'details': details is AccountBalanceInfo ? details.toJson() : details,
        'details': details.toJson(),
      },
    };
  }
}

// Cancel Request
class AccountBalanceCancelRequest
    extends BaseRequest<AccountBalanceCancelResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  AccountBalanceCancelRequest({
    required super.rpcPass,
    required this.taskId,
  }) : super(method: 'task::account_balance::cancel');

  final int taskId;

  @override
  JsonMap toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'task_id': taskId,
      },
    };
  }

  @override
  AccountBalanceCancelResponse parse(JsonMap json) =>
      AccountBalanceCancelResponse.parse(json);
}

// Cancel Response
class AccountBalanceCancelResponse extends BaseResponse {
  AccountBalanceCancelResponse({
    required super.mmrpc,
    required this.result,
  });

  factory AccountBalanceCancelResponse.parse(JsonMap json) {
    return AccountBalanceCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': result,
    };
  }
}
