import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request for checking Tendermint task activation status
class TaskEnableTendermintStatusRequest
    extends BaseRequest<TendermintTaskStatusResponse, GeneralErrorResponse> {
  TaskEnableTendermintStatusRequest({
    required super.rpcPass,
    required this.taskId,
    this.forgetIfFinished = false,
  }) : super(method: 'task::enable_tendermint::status', mmrpc: RpcVersion.v2_0);

  final int taskId;
  final bool forgetIfFinished;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId, 'forget_if_finished': forgetIfFinished},
  };

  @override
  TendermintTaskStatusResponse parse(Map<String, dynamic> json) =>
      TendermintTaskStatusResponse.parse(json);
}

/// Response for Tendermint task status
class TendermintTaskStatusResponse extends BaseResponse {
  TendermintTaskStatusResponse({
    required super.mmrpc,
    required this.status,
    required this.details,
  });

  factory TendermintTaskStatusResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    final statusString = result.value<String>('status');
    final status = SyncStatusEnum.tryParse(statusString);

    if (status == null) {
      throw FormatException(
        'Unrecognized task status: "$statusString". '
        'Expected one of: NotStarted, InProgress, Success, Error',
      );
    }

    // Handle details field based on status - can be string or object
    final detailsField = result['details'];
    TendermintTaskDetails details;

    if (status == SyncStatusEnum.success &&
        detailsField is Map<String, dynamic>) {
      // Success case: details is a JSON object with activation data
      details = TendermintTaskDetails.fromJson(detailsField);
    } else if (status == SyncStatusEnum.error && detailsField is String) {
      // Error case: details is a string with error message
      details = TendermintTaskDetails(error: detailsField);
    } else if (status == SyncStatusEnum.inProgress && detailsField is String) {
      // Progress case: details is a string with progress description
      details = TendermintTaskDetails(description: detailsField);
    } else if (status == SyncStatusEnum.notStarted) {
      // Not started case: empty details
      details = TendermintTaskDetails();
    } else if (detailsField is Map<String, dynamic>) {
      // Fallback: try to parse as JSON object
      details = TendermintTaskDetails.fromJson(detailsField);
    } else {
      // Fallback: treat as error string
      details = TendermintTaskDetails(error: detailsField?.toString());
    }

    return TendermintTaskStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: status,
      details: details,
    );
  }

  final SyncStatusEnum status;
  final TendermintTaskDetails details;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'status': _statusToString(status), 'details': details.toJson()},
  };

  String _statusToString(SyncStatusEnum status) {
    switch (status) {
      case SyncStatusEnum.notStarted:
        return 'NotStarted';
      case SyncStatusEnum.inProgress:
        return 'InProgress';
      case SyncStatusEnum.success:
        return 'Success';
      case SyncStatusEnum.error:
        return 'Error';
    }
  }
}

/// Details of Tendermint task progress
class TendermintTaskDetails {
  TendermintTaskDetails({this.data, this.error, this.description});

  factory TendermintTaskDetails.fromJson(JsonMap json) {
    return TendermintTaskDetails(
      data:
          json.valueOrNull<JsonMap>('data') != null
              ? TendermintActivationResult.fromJson(json.value<JsonMap>('data'))
              : null,
      error: json.valueOrNull<String>('error'),
      description: json.valueOrNull<String>('description'),
    );
  }

  final TendermintActivationResult? data;
  final String? error;
  final String? description;

  JsonMap toJson() => {
    if (data != null) 'data': data!.toJson(),
    if (error != null) 'error': error,
    if (description != null) 'description': description,
  };

  void throwIfError() {
    if (error != null) {
      throw Exception('Tendermint activation task failed: $error');
    }
  }
}

/// Result of successful Tendermint activation
class TendermintActivationResult {
  TendermintActivationResult({
    required this.ticker,
    required this.address,
    required this.currentBlock,
    this.balance,
    this.tokensBalances = const {},
    this.tokensTickers = const [],
  });

  factory TendermintActivationResult.fromJson(JsonMap json) {
    final hasBalances = json.containsKey('balance');
    return TendermintActivationResult(
      ticker: json.value<String>('ticker'),
      address: json.value<String>('address'),
      currentBlock: json.value<int>('current_block'),
      balance:
          hasBalances
              ? BalanceInfo.fromJson(json.value<JsonMap>('balance'))
              : null,
      tokensBalances:
          hasBalances
              ? Map.fromEntries(
                json
                    .value<JsonMap>('tokens_balances')
                    .entries
                    .map(
                      (e) => MapEntry(
                        e.key,
                        BalanceInfo.fromJson(e.value as JsonMap),
                      ),
                    ),
              )
              : {},
      tokensTickers:
          !hasBalances ? json.value<List<String>>('tokens_tickers') : [],
    );
  }

  final String ticker;
  final String address;
  final int currentBlock;
  final BalanceInfo? balance;
  final Map<String, BalanceInfo> tokensBalances;
  final List<String> tokensTickers;

  JsonMap toJson() => {
    'ticker': ticker,
    'address': address,
    'current_block': currentBlock,
    if (balance != null) 'balance': balance!.toJson(),
    if (tokensBalances.isNotEmpty)
      'tokens_balances': Map.fromEntries(
        tokensBalances.entries.map((e) => MapEntry(e.key, e.value.toJson())),
      ),
    if (tokensTickers.isNotEmpty) 'tokens_tickers': tokensTickers,
  };
}

/// Request for canceling Tendermint task activation
class TaskEnableTendermintCancelRequest
    extends BaseRequest<TendermintTaskCancelResponse, GeneralErrorResponse> {
  TaskEnableTendermintCancelRequest({
    required super.rpcPass,
    required this.taskId,
  }) : super(method: 'task::enable_tendermint::cancel', mmrpc: RpcVersion.v2_0);

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId},
  };

  @override
  TendermintTaskCancelResponse parse(Map<String, dynamic> json) =>
      TendermintTaskCancelResponse.parse(json);
}

/// Response for canceling Tendermint task
class TendermintTaskCancelResponse extends BaseResponse {
  TendermintTaskCancelResponse({required super.mmrpc, required this.result});

  factory TendermintTaskCancelResponse.parse(JsonMap json) {
    return TendermintTaskCancelResponse(
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
