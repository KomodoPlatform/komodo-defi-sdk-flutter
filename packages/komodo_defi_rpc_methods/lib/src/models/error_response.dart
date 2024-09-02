import 'package:komodo_defi_rpc_methods/src/models/models.dart';

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
    return GeneralErrorResponse(
      mmrpc: json['mmrpc'] as String,
      error: json['error'] as String,
      errorPath: json['error_path'] as String,
      errorTrace: json['error_trace'] as String,
      errorType: json['error_type'] as String,
      errorData: json['error_data'] as dynamic,
    );
  }

  final String error;
  final String errorPath;
  final String errorTrace;
  final String errorType;
  final dynamic errorData;

  static bool isErrorResponse(Map<String, dynamic> json) {
    return json.containsKey('error');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'error': error,
      'error_path': errorPath,
      'error_trace': errorTrace,
      'error_type': errorType,
      'error_data': errorData,
    };
  }
}
