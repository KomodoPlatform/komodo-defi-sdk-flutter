import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

@Deprecated('Use the new task-based withdrawal API')

/// Request for standard withdrawal (legacy API)
class WithdrawLegacyRequest
    extends BaseRequest<WithdrawStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  @Deprecated('Use the new task-based withdrawal API')
  WithdrawLegacyRequest({
    required super.rpcPass,
    required this.coin,
    required this.to,
    required this.amount,
    this.fee,
    this.from,
    this.memo,
    this.max = false,
    this.ibcSourceChannel,
  }) : super(
          method: 'withdraw',
          mmrpc: '2.0',
        );

  final String coin;
  final String to;
  final Decimal amount;
  final FeeInfo? fee;
  final WithdrawalSource? from;
  final String? memo;
  final bool max;
  final String? ibcSourceChannel;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'params': {
          'coin': coin,
          'to': to,
          if (!max) 'amount': amount.toString(),
          'max': max,
          if (fee != null) 'fee': fee!.toJson(),
          if (from != null) 'from': from!.toJson(),
          if (memo != null) 'memo': memo,
          if (ibcSourceChannel != null) 'ibc_source_channel': ibcSourceChannel,
        },
      };

  @override
  WithdrawStatusResponse parse(Map<String, dynamic> json) =>
      WithdrawStatusResponse.parse(json);
}

/// Request to initialize withdrawal task
class WithdrawInitRequest
    extends BaseRequest<WithdrawInitResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  WithdrawInitRequest({
    required super.rpcPass,
    required WithdrawParameters params,
    // required this.coin,
    // required this.to,
    // this.amount,
    // this.fee,
    // this.from,
    // this.memo,
    // this.max = false,
  })  : coin = params.asset,
        to = params.toAddress,
        amount = params.amount.toString(),
        fee = params.fee,
        from = params.from,
        memo = params.memo,
        max = params.isMax ?? false,
        super(
          method: 'task::withdraw::init',
          mmrpc: '2.0',
        );

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
          if (from != null) 'from': from!.toJson(),
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
  }) : super(
          method: 'task::withdraw::status',
          mmrpc: '2.0',
        );

  final int taskId;
  final bool forgetIfFinished;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'params': {
          'task_id': taskId,
          'forget_if_finished': forgetIfFinished,
        },
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
      details: status == 'Ok'
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
          'details': details is WithdrawResult ? details.toJson() : details,
        },
      };

  @override
  String toString() => toJson().toJsonString();
}

/// Request to cancel withdrawal task
class WithdrawCancelRequest
    extends BaseRequest<WithdrawCancelResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  WithdrawCancelRequest({
    required super.rpcPass,
    required this.taskId,
  }) : super(
          method: 'task::withdraw::cancel',
          mmrpc: '2.0',
        );

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'params': {
          'task_id': taskId,
        },
      };

  @override
  WithdrawCancelResponse parse(Map<String, dynamic> json) =>
      WithdrawCancelResponse.parse(json);
}

class WithdrawCancelResponse extends BaseResponse {
  WithdrawCancelResponse({
    required super.mmrpc,
    required this.result,
  });

  factory WithdrawCancelResponse.parse(Map<String, dynamic> json) {
    return WithdrawCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': result,
      };
}

// class WithdrawalSource {
//   WithdrawalSource._({
//     this.derivationPath,
//     this.accountId,
//     this.chain,
//     this.addressId,
//   }) : assert(
//           (derivationPath != null) !=
//               (accountId != null && chain != null && addressId != null),
//           'Must provide either derivationPath OR (accountId, chain, addressId)',
//         );

//   factory WithdrawalSource.derivationPath(String path) =>
//       WithdrawalSource._(derivationPath: path);

//   factory WithdrawalSource.components({
//     required int accountId,
//     required String chain,
//     required int addressId,
//   }) =>
//       WithdrawalSource._(
//         accountId: accountId,
//         chain: chain,
//         addressId: addressId,
//       );

//   final String? derivationPath;
//   final int? accountId;
//   final String? chain;
//   final int? addressId;

//   Map<String, dynamic> toJson() {
//     if (derivationPath != null) {
//       return {'derivation_path': derivationPath};
//     }
//     return {
//       'account_id': accountId,
//       'chain': chain,
//       'address_id': addressId,
//     };
//   }
// }
