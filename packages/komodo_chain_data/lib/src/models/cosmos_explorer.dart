import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmos_explorer.freezed.dart';
part 'cosmos_explorer.g.dart';

/// Represents an explorer from the Cosmos chain directory.
@freezed
abstract class CosmosExplorer with _$CosmosExplorer {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosExplorer({
    String? kind,
    required String url,
    String? txPage,
    String? accountPage,
    String? validatorPage,
    String? proposalPage,
    String? blockPage,
  }) = _CosmosExplorer;

  const CosmosExplorer._();

  factory CosmosExplorer.fromJson(Map<String, dynamic> json) =>
      _$CosmosExplorerFromJson(json);
}
