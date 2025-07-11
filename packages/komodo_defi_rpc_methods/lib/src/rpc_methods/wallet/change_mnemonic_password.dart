// lib/src/rpc_methods/wallet/change_mnemonic_password.dart

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ChangeMnemonicPasswordRequest
    extends
        BaseRequest<
          ChangeMnemonicPasswordResponse,
          ChangeMnemonicIncorrectPasswordErrorResponse
        > {
  ChangeMnemonicPasswordRequest({
    required super.rpcPass,
    required this.currentPassword,
    required this.newPassword,
  }) : super(method: 'change_mnemonic_password', mmrpc: '2.0');

  final String currentPassword;
  final String newPassword;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {
      'current_password': currentPassword,
      'new_password': newPassword,
    },
  };

  @override
  ChangeMnemonicIncorrectPasswordErrorResponse? parseCustomErrorResponse(
    JsonMap json,
  ) {
    if (ChangeMnemonicIncorrectPasswordErrorResponse.isWrongPasswordError(
      json,
    )) {
      return ChangeMnemonicIncorrectPasswordErrorResponse.parse(json);
    }

    return null; // Let the base implementation handle other types of errors
  }

  @override
  ChangeMnemonicPasswordResponse parse(Map<String, dynamic> json) =>
      ChangeMnemonicPasswordResponse.parse(json);
}

/// Specific error response for wrong password in change_mnemonic_password
class ChangeMnemonicIncorrectPasswordErrorResponse
    extends GeneralErrorResponse {
  ChangeMnemonicIncorrectPasswordErrorResponse({
    required super.mmrpc,
    required super.error,
    required super.errorPath,
    required super.errorTrace,
    required super.errorType,
    required super.errorData,
    required super.object,
  });

  /// Parse error response from JSON
  factory ChangeMnemonicIncorrectPasswordErrorResponse.parse(
    Map<String, dynamic> json,
  ) {
    return ChangeMnemonicIncorrectPasswordErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      error: json.valueOrNull<String>('error'),
      errorPath: json.valueOrNull<String>('error_path'),
      errorTrace: json.valueOrNull<String>('error_trace'),
      errorType: json.valueOrNull<String>('error_type'),
      errorData: json.valueOrNull<dynamic>('error_data'),
      object: json,
    );
  }

  /// Check if the error response is a wrong password error
  static bool isWrongPasswordError(Map<String, dynamic> json) {
    final errorMessage = json.valueOrNull<String>('error') ?? '';
    final didFindWrongPasswordError = AuthException.findExceptionsInLog(
      errorMessage,
    ).any((e) => e.type == AuthExceptionType.incorrectPassword);

    return didFindWrongPasswordError;
  }
}

class ChangeMnemonicPasswordResponse extends BaseResponse {
  ChangeMnemonicPasswordResponse({required super.mmrpc});

  @override
  factory ChangeMnemonicPasswordResponse.parse(Map<String, dynamic> json) {
    return ChangeMnemonicPasswordResponse(mmrpc: json.value<String>('mmrpc'));
  }

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': null};
}
