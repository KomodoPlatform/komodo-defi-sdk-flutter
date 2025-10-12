import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmos_proxy_status.freezed.dart';
part 'cosmos_proxy_status.g.dart';

/// Represents the proxy status from the Cosmos chain directory.
@freezed
abstract class CosmosProxyStatus with _$CosmosProxyStatus {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosProxyStatus({required bool rest, required bool rpc}) =
      _CosmosProxyStatus;

  const CosmosProxyStatus._();

  factory CosmosProxyStatus.fromJson(Map<String, dynamic> json) =>
      _$CosmosProxyStatusFromJson(json);
}
