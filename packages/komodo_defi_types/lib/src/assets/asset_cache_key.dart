import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_cache_key.freezed.dart';
part 'asset_cache_key.g.dart';

@freezed
abstract class AssetCacheKey with _$AssetCacheKey {
  const factory AssetCacheKey({
    required String assetConfigId,
    required String chainId,
    required String subClass,
    required String protocolKey,
    @Default(<String, Object?>{}) Map<String, Object?> customFields,
  }) = _AssetCacheKey;

  factory AssetCacheKey.fromJson(Map<String, dynamic> json) =>
      _$AssetCacheKeyFromJson(json);
}

/// Builds a canonical suffix for custom fields in the form `{"k=v|k2=v2"}`
/// with keys sorted alphabetically to ensure stable equality.
String canonicalCustomFieldsSuffix(Map<String, Object?> customFields) {
  if (customFields.isEmpty) {
    return '{}';
  }
  final keys = customFields.keys.toList()..sort();
  final parts = <String>[];
  for (final key in keys) {
    parts.add('$key=${customFields[key]}');
  }
  return '{${parts.join('|')}}';
}

/// Builds a canonical string key from the individual parts.
String canonicalCacheKeyFromParts({
  required String assetConfigId,
  required String chainId,
  required String subClass,
  required String protocolKey,
  Map<String, Object?> customFields = const <String, Object?>{},
}) {
  return '${assetConfigId}_${chainId}_${subClass}_${protocolKey}_'
      '${canonicalCustomFieldsSuffix(customFields)}';
}

/// Builds a canonical string key given a precomputed base prefix
/// `<assetConfigId>_<chainId>_<subClass>_<protocolKey>`.
String canonicalCacheKeyFromBasePrefix(
  String basePrefix,
  Map<String, Object?> customFields,
) {
  return '${basePrefix}_${canonicalCustomFieldsSuffix(customFields)}';
}

extension AssetCacheKeyCanonical on AssetCacheKey {
  /// Returns the canonical string representation of this key.
  String toCanonicalString() => canonicalCacheKeyFromParts(
    assetConfigId: assetConfigId,
    chainId: chainId,
    subClass: subClass,
    protocolKey: protocolKey,
    customFields: customFields,
  );
}
