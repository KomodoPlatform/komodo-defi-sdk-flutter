/// Base class for all API responses
abstract class BaseResponse {
  /// Creates a new instance of [BaseResponse].
  BaseResponse({required this.mmrpc, this.id});

  /// Parses JSON response as per the API specification:
  /// https://komodoplatform.com/en/docs/komodo-defi-framework/api/
  // ignore: avoid_unused_constructor_parameters
  BaseResponse parse(Map<String, dynamic> json) => throw UnimplementedError();

  // Null/empty signifies a legacy response. Non-legacy responses will have a
  // value of '2.0', but there may be other values in the future.
  final String? mmrpc;

  final String? id;

  /// Converts the response to a JSON map.
  Map<String, dynamic> toJson();
}
