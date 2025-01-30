import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

Future<AssetId?> showCoinSearch(
  BuildContext context, {
  required List<AssetId> coins,
  SelectItem<AssetId> Function(AssetId coinId)? customCoinItemBuilder,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  final items = coins.map((assetId) {
    return customCoinItemBuilder?.call(assetId) ??
        SelectItem<AssetId>(
          id: assetId.id,
          title: assetId.name,
          value: assetId,
          leading: AssetIcon(assetId),
        );
  }).toList();

  return showSearchableSelect(
    context,
    items: items,
    searchHint: 'Search coins', //TODO: Localize
    convertResult: (item) => item?.value,
    isMobile: isMobile,
  );
}
