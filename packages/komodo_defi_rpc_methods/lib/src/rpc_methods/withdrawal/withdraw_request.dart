import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request for standard withdrawal (non-task API)
///
/// After the bug with the task-based withdrawal API was fixed, this request
/// will be deprecated in favor of the new task-based withdrawal API.
// @Deprecated('Use the new task-based withdrawal API')
class WithdrawRequest
    extends BaseRequest<WithdrawStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  // @Deprecated('Use the new task-based withdrawal API')
  WithdrawRequest({
    required super.rpcPass,
    required this.coin,
    required this.to,
    required this.amount,
    this.fee,
    this.from,
    this.memo,
    this.max = false,
    this.ibcSourceChannel,
  }) : assert(
         amount != null || max,
         'Amount cannot be specified if sending the maximum amount',
       ),
       assert(
         amount == null || !max,
         'Amount must be specified if not sending the maximum amount',
       ),
       super(method: 'withdraw', mmrpc: RpcVersion.v2_0);

  final String coin;
  final String to;
  final Decimal? amount;
  final FeeInfo? fee;
  final WithdrawalSource? from;
  final String? memo;
  final bool max;
  // TODO: update to `int?` when the KDF changes in v2.5.0-beta
  final String? ibcSourceChannel;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'coin': coin,
      'to': to,
      if (max) 'max': max,
      if (!max && amount != null) 'amount': amount?.toString(),
      if (fee != null) 'fee': fee!.toJson(),
      if (from != null) 'from': from!.toRpcParams(),
      if (memo != null) 'memo': memo,
      //TODO! Migrate breaking changes when the ibc_source_channel is
      // changed to a numeric type in KDF.
      // https://github.com/KomodoPlatform/komodo-defi-framework/pull/2298#discussion_r2034825504
      if (ibcSourceChannel != null) 'ibc_source_channel': ibcSourceChannel,
    },
  };

  @override
  WithdrawStatusResponse parse(Map<String, dynamic> json) {
    // TODO: Remove work-around when legacy withdrawal is deprecated or
    // refactor to avoid shared parsing logic
    final hasDetails = json.hasNestedKey('result', 'details');
    final hasStatus = json.hasNestedKey('result', 'status');
    return WithdrawStatusResponse.parse(
      json.deepMerge(
        {
          if (!hasStatus) 'result': {'status': 'Ok'},
        }.deepMerge({
          if (!hasDetails) 'result': {'details': json['result']},
        }),
      ),
    );
  }
}

/// Request to initialize withdrawal task
class WithdrawInitRequest
    extends BaseRequest<WithdrawInitResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  WithdrawInitRequest({
    required super.rpcPass,
    required WithdrawParameters params,
  }) : coin = params.asset,
       to = params.toAddress,
       amount = params.amount?.toString(),
       fee = params.fee,
       from = params.from,
       memo = params.memo,
       max = params.isMax ?? false,
       assert(
         params.amount != null || (params.isMax ?? false),
         'Amount must be non-null if isMax is false and '
         'must be null if isMax is true',
       ),
       super(method: 'task::withdraw::init', mmrpc: RpcVersion.v2_0);

  final String coin;
  final String to;
  final String? amount;
  final FeeInfo? fee;
  final WithdrawalSource? from;
  final String? memo;
  final bool max;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'coin': coin,
      'to': to,
      if (amount != null) 'amount': amount,
      if (fee != null) 'fee': fee!.toJson(),
      if (from != null) 'from': from!.toRpcParams(),
      if (memo != null) 'memo': memo,
      if (max) 'max': max,
    },
  };

  @override
  WithdrawInitResponse parse(Map<String, dynamic> json) =>
      WithdrawInitResponse.parse(json);
}

typedef WithdrawInitResponse = NewTaskResponse;

/// Request to check withdrawal task status
class WithdrawStatusRequest
    extends BaseRequest<WithdrawStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  WithdrawStatusRequest({
    required super.rpcPass,
    required this.taskId,
    this.forgetIfFinished = true,
  }) : super(method: 'task::withdraw::status', mmrpc: '2.0');

  final int taskId;
  final bool forgetIfFinished;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId, 'forget_if_finished': forgetIfFinished},
  };

  @override
  WithdrawStatusResponse parse(Map<String, dynamic> json) =>
      WithdrawStatusResponse.parse(json);
}

class WithdrawStatusResponse extends BaseResponse {
  WithdrawStatusResponse({
    required super.mmrpc,
    required this.status,
    required this.details,
  });

  factory WithdrawStatusResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    final status = result.value<String>('status');

    return WithdrawStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: status,
      details:
          status == 'Ok'
              ? WithdrawResult.fromJson(result.value<JsonMap>('details'))
              : result.value<String>('details'),
    );
  }

  final String status;

  /// String for in-progress/error states, WithdrawResult for completed state
  // TODO: Refactor this class to avoid dynamic
  final dynamic details;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'status': status,
      'details':
          (details is WithdrawResult)
              ? (details as WithdrawResult).toJson()
              : details,
    },
  };

  @override
  String toString() => toJson().toJsonString();
}

/// Request to cancel withdrawal task
class WithdrawCancelRequest
    extends BaseRequest<WithdrawCancelResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  WithdrawCancelRequest({required super.rpcPass, required this.taskId})
    : super(method: 'task::withdraw::cancel', mmrpc: '2.0');

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId},
  };

  @override
  WithdrawCancelResponse parse(Map<String, dynamic> json) =>
      WithdrawCancelResponse.parse(json);
}

class WithdrawCancelResponse extends BaseResponse {
  WithdrawCancelResponse({required super.mmrpc, required this.result});

  factory WithdrawCancelResponse.parse(Map<String, dynamic> json) {
    return WithdrawCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result};
}
