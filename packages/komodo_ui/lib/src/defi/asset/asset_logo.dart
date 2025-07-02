import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'package:komodo_ui/src/defi/asset/asset_icon.dart';

/// A widget that displays an [AssetIcon] with its protocol icon overlaid.
///
/// Similar to the legacy CoinLogo, but built on top of the new [Asset]
/// and [AssetIcon] APIs.
class AssetLogo extends StatelessWidget {
  /// Creates a new [AssetLogo] widget from an [Asset] instance.
  ///
  /// Example usage:
  /// ```dart
  /// AssetLogo(asset)
  /// ```
  const AssetLogo(
    this.asset, {
    this.size = 41,
    this.isDisabled = false,
    super.key,
  }) : assetId = null,
       _legacyTicker = null;

  /// Creates a logo directly from an [AssetId].
  const AssetLogo.fromId(
    this.assetId, {
    this.size = 41,
    this.isDisabled = false,
    super.key,
  }) : asset = null,
       _legacyTicker = null;

  /// Legacy constructor that accepts a raw ticker string.
  ///
  /// This mirrors [AssetIcon.ofTicker] and should only be used when an
  /// [Asset] or [AssetId] instance isn't available.
  const AssetLogo.fromTicker(
    String ticker, {
    this.size = 41,
    this.isDisabled = false,
    super.key,
  }) : _legacyTicker = ticker,
       asset = null,
       assetId = null;

  /// Asset to display the logo for.
  final Asset? asset;
  final AssetId? assetId;
  final String? _legacyTicker;

  /// Size of the main asset icon.
  final double size;

  /// Whether the asset is disabled. Disabled icons are displayed
  /// with reduced opacity.
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final resolvedId = asset?.id ?? assetId;
    final resolvedTicker = _legacyTicker;
    final resolvedSubClass = asset?.protocol.subClass ?? assetId?.subClass;

    final isChildAsset = resolvedId?.isChildAsset ?? false;

    // Use the parent coin ticker for child assets so that token logos display
    // the network they belong to (e.g. ETH for ERC20 tokens).
    final protocolTicker = isChildAsset ? resolvedId?.parentId?.id : null;
    final shouldShowProtocolIcon = isChildAsset && protocolTicker != null;

    final mainIcon =
        resolvedId != null
            ? AssetIcon(resolvedId, size: size, suspended: isDisabled)
            : AssetIcon.ofTicker(
              resolvedTicker!,
              size: size,
              suspended: isDisabled,
            );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        mainIcon,
        if (shouldShowProtocolIcon && protocolTicker != null)
          AssetProtocolIcon(protocolTicker: protocolTicker, logoSize: size),
      ],
    );
  }
}

/// A widget that displays a protocol icon with a circular border and shadow,
/// positioned absolutely within its parent widget.
///
/// This widget is typically used to overlay a protocol icon on top of an asset
/// logo to indicate the blockchain protocol or network the asset belongs to.
class AssetProtocolIcon extends StatelessWidget {
  /// Creates an [AssetProtocolIcon] widget.
  ///
  /// The [protocolTicker] and [logoSize] parameters are required.
  ///
  /// Optional parameters with their default behaviors:
  /// - [protocolSizeWithBorder]: Defaults to `logoSize * 0.45`
  /// - [protocolBorder]: Defaults to `protocolSizeWithBorder * 0.1`
  /// - [protocolLeftPosition]: Defaults to `logoSize * 0.55`
  /// - [protocolTopPosition]: Defaults to `logoSize * 0.55`
  const AssetProtocolIcon({
    required this.protocolTicker,
    required this.logoSize,
    this.protocolSizeWithBorder,
    this.protocolBorder,
    this.protocolLeftPosition,
    this.protocolTopPosition,
    super.key,
  });

  /// The ticker symbol of the protocol to display as an icon.
  final String protocolTicker;

  /// The size of the main logo that this protocol icon will be
  /// positioned relative to.
  final double logoSize;

  /// The total size of the protocol icon including its border.
  /// If null, defaults to `logoSize * 0.45`.
  final double? protocolSizeWithBorder;

  /// The thickness of the border around the protocol icon.
  /// If null, defaults to `protocolSizeWithBorder * 0.1`.
  final double? protocolBorder;

  /// The left position offset for the protocol icon.
  /// If null, defaults to `logoSize * 0.55`.
  final double? protocolLeftPosition;

  /// The top position offset for the protocol icon.
  /// If null, defaults to `logoSize * 0.55`.
  final double? protocolTopPosition;

  // Pre-computed values to avoid recalculation in build()
  double get _sizeWithBorder => protocolSizeWithBorder ?? logoSize * 0.45;
  double get _border => protocolBorder ?? _sizeWithBorder * 0.1;
  double get _leftPosition => protocolLeftPosition ?? logoSize * 0.55;
  double get _topPosition => protocolTopPosition ?? logoSize * 0.55;
  double get _iconSize => _sizeWithBorder - _border;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _leftPosition,
      top: _topPosition,
      width: _sizeWithBorder,
      height: _sizeWithBorder,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 2,
            ),
          ],
        ),
        child: Container(
          width: _iconSize,
          height: _iconSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: AssetIcon.ofTicker(protocolTicker, size: _iconSize),
        ),
      ),
    );
  }
}
