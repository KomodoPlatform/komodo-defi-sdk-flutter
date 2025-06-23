import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'seed_node.freezed.dart';
part 'seed_node.g.dart';

/// Represents a seed node configuration with contact information.
@freezed
class SeedNode with _$SeedNode {
  const factory SeedNode({
    required String name,
    required String host,
    required List<SeedNodeContact> contact,
  }) = _SeedNode;

  factory SeedNode.fromJson(JsonMap json) => _$SeedNodeFromJson(json);

  /// Creates a list of [SeedNode]s from a JSON list.
  static List<SeedNode> fromJsonList(JsonList jsonList) =>
      jsonList.map(SeedNode.fromJson).toList();
}

/// Represents contact information for a seed node.
@freezed
class SeedNodeContact with _$SeedNodeContact {
  const factory SeedNodeContact({
    required String email,
  }) = _SeedNodeContact;

  factory SeedNodeContact.fromJson(JsonMap json) =>
      _$SeedNodeContactFromJson(json);
}
