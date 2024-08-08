/// Base class for all API responses
abstract class BaseResponse {
  BaseResponse({required this.mmrpc});

  /// Parses JSON response as per the API specification:
  /// https://komodoplatform.com/en/docs/komodo-defi-framework/api/
  // ignore: avoid_unused_constructor_parameters
  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  final String mmrpc;

  Map<String, dynamic> toJson();
}
