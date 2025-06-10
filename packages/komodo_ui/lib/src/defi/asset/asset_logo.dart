import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'package:komodo_ui/src/defi/asset/asset_icon.dart';

/// A widget that displays an [AssetIcon] with its protocol icon overlaid.
///
/// Similar to the legacy [CoinLogo], but built on top of the new [Asset]
/// and [AssetIcon] APIs.
class AssetLogo extends StatelessWidget {
  const AssetLogo(
    this.asset, {
    this.size = 20,
    this.suspended = false,
    super.key,
  });

  /// Asset to display the logo for.
  final Asset asset;

  /// Size of the main asset icon.
  final double size;

  /// Whether the asset is suspended. Suspended icons are displayed
  /// with reduced opacity.
  final bool suspended;

  @override
  Widget build(BuildContext context) {
    final protocolTicker = asset.protocol.subClass.iconTicker;
    final protocolIconSize = size / 2;

    final protocolIcon =
        protocolTicker.isEmpty
            ? null
            : AssetIcon.ofTicker(protocolTicker, size: protocolIconSize);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AssetIcon(asset.id, size: size, suspended: suspended),
          if (protocolIcon != null)
            Positioned(right: 0, bottom: 0, child: protocolIcon),
        ],
      ),
    );
  }
}
