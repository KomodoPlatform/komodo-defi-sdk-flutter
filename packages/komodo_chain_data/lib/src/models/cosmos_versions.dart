import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmos_versions.freezed.dart';
part 'cosmos_versions.g.dart';

/// Represents the version information from the Cosmos chain directory.
@freezed
abstract class CosmosVersions with _$CosmosVersions {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosVersions({
    String? applicationVersion,
    String? cosmosSdkVersion,
    String? tendermintVersion,
  }) = _CosmosVersions;

  const CosmosVersions._();

  factory CosmosVersions.fromJson(Map<String, dynamic> json) =>
      _$CosmosVersionsFromJson(json);
}
