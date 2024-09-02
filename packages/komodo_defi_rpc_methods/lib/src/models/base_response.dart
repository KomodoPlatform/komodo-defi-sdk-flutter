/// Base class for all API responses
abstract class BaseResponse {
  /// Creates a new instance of [BaseResponse].
  BaseResponse({required this.mmrpc, this.id});

  /// Parses JSON response as per the API specification:
  /// https://komodoplatform.com/en/docs/komodo-defi-framework/api/
  // ignore: avoid_unused_constructor_parameters
  BaseResponse parse(Map<String, dynamic> json) => throw UnimplementedError();

  final String mmrpc;

  final String? id;

  /// Converts the response to a JSON map.
  Map<String, dynamic> toJson();
}
