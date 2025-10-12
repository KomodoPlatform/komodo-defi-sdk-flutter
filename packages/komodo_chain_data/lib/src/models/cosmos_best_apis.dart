import 'package:freezed_annotation/freezed_annotation.dart';

import 'cosmos_api_endpoint.dart';

part 'cosmos_best_apis.freezed.dart';
part 'cosmos_best_apis.g.dart';

/// Represents the best APIs section from the Cosmos chain directory.
@freezed
abstract class CosmosBestApis with _$CosmosBestApis {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosBestApis({
    required List<CosmosApiEndpoint> rest,
    required List<CosmosApiEndpoint> rpc,
  }) = _CosmosBestApis;

  const CosmosBestApis._();

  factory CosmosBestApis.fromJson(Map<String, dynamic> json) =>
      _$CosmosBestApisFromJson(json);

  /// Returns the primary RPC endpoint if available.
  String? get primaryRpcEndpoint {
    return rpc.isNotEmpty ? rpc.first.address : null;
  }

  /// Returns the primary REST endpoint if available.
  String? get primaryRestEndpoint {
    return rest.isNotEmpty ? rest.first.address : null;
  }
}
