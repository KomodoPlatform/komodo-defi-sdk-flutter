import 'package:komodo_defi_rpc_methods/src/models/models.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Error response class
class GeneralErrorResponse extends BaseResponse implements Exception {
  GeneralErrorResponse({
    required super.mmrpc,
    required this.error,
    required this.errorPath,
    required this.errorTrace,
    required this.errorType,
    required this.errorData,
  });

  @override
  factory GeneralErrorResponse.parse(Map<String, dynamic> json) {
    final error = json.valueOrNull<JsonMap>('result', 'details') ??
        json.valueOrNull<JsonMap>('message');
    return GeneralErrorResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '',
      error: error?.valueOrNull<String>('message') ??
          error?.valueOrNull<String>('error'),
      errorPath: error?.valueOrNull<String>('error_path'),
      errorTrace: error?.valueOrNull<String>('error_trace'),
      errorType: error?.valueOrNull<String>('error_type'),
      errorData: error?.valueOrNull<dynamic>('error_data'),
    );
  }

  final String? error;
  final String? errorPath;
  final String? errorTrace;
  final String? errorType;
  final dynamic errorData;

  static bool isErrorResponse(Map<String, dynamic> json) {
    return json.hasNestedKey('result', 'details', 'error') ||
        json.hasNestedKey('error') ||
        json.valueOrNull<String>('result', 'status') == 'Error';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'error': error,
      'error_path': errorPath,
      'error_type': errorType,
      'error_data': errorData,
      'error_trace': errorTrace,
    };
  }

  @override
  String toString() {
    return 'GeneralErrorResponse: ${toJson().toJsonString()}';
  }
}
