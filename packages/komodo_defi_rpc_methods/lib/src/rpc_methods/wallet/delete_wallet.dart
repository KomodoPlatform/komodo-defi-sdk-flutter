import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class DeleteWalletRequest
    extends BaseRequest<DeleteWalletResponse, DeleteWalletErrorResponse> {
  DeleteWalletRequest({
    required this.walletName,
    required this.password,
    super.rpcPass,
  }) : super(method: 'delete_wallet', mmrpc: RpcVersion.v2_0);

  final String walletName;
  final String password;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'wallet_name': walletName, 'password': password},
  };

  @override
  DeleteWalletErrorResponse? parseCustomErrorResponse(JsonMap json) {
    final type = json.valueOrNull<String>('error_type');
    switch (type) {
      case 'InvalidRequest':
        return DeleteWalletInvalidRequestErrorResponse.parse(json);
      case 'WalletNotFound':
        return DeleteWalletWalletNotFoundErrorResponse.parse(json);
      case 'InvalidPassword':
        return DeleteWalletInvalidPasswordErrorResponse.parse(json);
      case 'CannotDeleteActiveWallet':
        return DeleteWalletCannotDeleteActiveWalletErrorResponse.parse(json);
      case 'WalletsStorageError':
        return DeleteWalletWalletsStorageErrorResponse.parse(json);
      case 'InternalError':
        return DeleteWalletInternalErrorResponse.parse(json);
    }
    return null;
  }

  @override
  DeleteWalletResponse parse(Map<String, dynamic> json) =>
      DeleteWalletResponse.parse(json);
}

class DeleteWalletResponse extends BaseResponse {
  DeleteWalletResponse({required super.mmrpc});

  factory DeleteWalletResponse.parse(Map<String, dynamic> json) {
    return DeleteWalletResponse(mmrpc: json.value<String>('mmrpc'));
  }

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': null};
}

abstract class DeleteWalletErrorResponse extends GeneralErrorResponse {
  DeleteWalletErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletErrorResponse.parse(Map<String, dynamic> json) {
    return DeleteWalletInvalidRequestErrorResponse.parse(json);
  }
}

class DeleteWalletInvalidRequestErrorResponse
    extends DeleteWalletErrorResponse {
  DeleteWalletInvalidRequestErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletInvalidRequestErrorResponse.parse(JsonMap json) {
    return DeleteWalletInvalidRequestErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }
}

class DeleteWalletWalletNotFoundErrorResponse
    extends DeleteWalletErrorResponse {
  DeleteWalletWalletNotFoundErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletWalletNotFoundErrorResponse.parse(JsonMap json) {
    return DeleteWalletWalletNotFoundErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }
}

class DeleteWalletInvalidPasswordErrorResponse
    extends DeleteWalletErrorResponse {
  DeleteWalletInvalidPasswordErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletInvalidPasswordErrorResponse.parse(JsonMap json) {
    return DeleteWalletInvalidPasswordErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }
}

class DeleteWalletCannotDeleteActiveWalletErrorResponse
    extends DeleteWalletErrorResponse {
  DeleteWalletCannotDeleteActiveWalletErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletCannotDeleteActiveWalletErrorResponse.parse(
    JsonMap json,
  ) {
    return DeleteWalletCannotDeleteActiveWalletErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }
}

class DeleteWalletWalletsStorageErrorResponse
    extends DeleteWalletErrorResponse {
  DeleteWalletWalletsStorageErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletWalletsStorageErrorResponse.parse(JsonMap json) {
    return DeleteWalletWalletsStorageErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }
}

class DeleteWalletInternalErrorResponse extends DeleteWalletErrorResponse {
  DeleteWalletInternalErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  factory DeleteWalletInternalErrorResponse.parse(JsonMap json) {
    return DeleteWalletInternalErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }
}
