import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmos_api_endpoint.freezed.dart';
part 'cosmos_api_endpoint.g.dart';

/// Represents an API endpoint (RPC or REST) from the Cosmos chain directory.
@freezed
abstract class CosmosApiEndpoint with _$CosmosApiEndpoint {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosApiEndpoint({required String address, String? provider}) =
      _CosmosApiEndpoint;

  const CosmosApiEndpoint._();

  factory CosmosApiEndpoint.fromJson(Map<String, dynamic> json) =>
      _$CosmosApiEndpointFromJson(json);
}
