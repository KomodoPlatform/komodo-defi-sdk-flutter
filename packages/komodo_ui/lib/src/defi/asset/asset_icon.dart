import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// A widget that displays an icon for a given [AssetId].
///
/// The icon is extracted from a sprite map bundled with the app. If the
/// sprite map doesn't contain the icon, a generic placeholder is shown.
class AssetIcon extends StatelessWidget {
  /// Creates an [AssetIcon] widget that displays an icon for the given [AssetId].
  /// This is the preferred constructor as it provides type safety and additional
  /// metadata about the asset.
  const AssetIcon(
    this.assetId, {
    this.size = 20,
    this.suspended = false,
    super.key,
  }) : _legacyTicker = null;

  /// Legacy constructor that accepts a ticker/abbreviation string.
  /// Provided for backwards compatibility with [CoinIcon].
  ///
  /// Consider migrating to the default constructor with [AssetId] for better
  /// type safety and asset metadata support.
  ///
  /// NB! This will likely be deprecated in the future.
  AssetIcon.ofTicker(
    String ticker, {
    this.size = 20,
    this.suspended = false,
    super.key,
  }) : _legacyTicker = ticker.toLowerCase(),
       assetId = null;

  final AssetId? assetId;
  final String? _legacyTicker;
  final double size;
  final bool suspended;

  String get _effectiveId => assetId?.id ?? _legacyTicker!;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: suspended ? 0.4 : 1,
      child: SizedBox.square(
        dimension: size,
        child: _AssetIconResolver(
          key: ValueKey(_effectiveId),
          assetId: _effectiveId,
          size: size,
        ),
      ),
    );
  }

  /// Clears all caches used by [AssetIcon]
  static void clearCaches() {
    _AssetIconResolver.clearCaches();
  }

  /// Registers a custom icon for a given coin abbreviation.
  ///
  /// The [imageProvider] will be used instead of the default asset or CDN images
  /// when displaying the icon for the specified [assetId].
  ///
  /// Example:
  /// ```dart
  /// // Register a custom icon from an asset
  /// CoinIcon.registerCustomIcon(
  ///   'MYCOIN',
  ///   AssetImage('assets/my_custom_coin.png'),
  /// );
  ///
  /// // Register a custom icon from memory
  /// CoinIcon.registerCustomIcon(
  ///   'MYCOIN',
  ///   MemoryImage(customIconBytes),
  /// );
  /// ```
  static void registerCustomIcon(AssetId assetId, ImageProvider imageProvider) {
    _AssetIconResolver.registerCustomIcon(assetId, imageProvider);
  }

  /// Pre-loads the asset icon image into the cache.
  ///
  /// This is useful when you know you'll need an icon soon and want to avoid
  /// a loading delay.
  ///
  /// Set [throwExceptions] to true if you want to handle caching errors.
  static Future<void> precacheAssetIcon(
    BuildContext context,
    AssetId asset, {
    bool throwExceptions = false,
  }) {
    return _AssetIconResolver.precacheAssetIcon(
      context,
      asset,
      throwExceptions: throwExceptions,
    );
  }
}

class _AssetIconResolver extends StatelessWidget {
  const _AssetIconResolver({
    required this.assetId,
    required this.size,
    super.key,
  });

  final String assetId;
  final double size;

  static const _spriteImageAsset =
      'packages/komodo_defi_framework/assets/coin_icons/spritemap.png';
  static const _spriteJsonAsset =
      'packages/komodo_defi_framework/assets/coin_icons/spritemap.json';

  static final Map<String, ImageProvider> _customIconsCache = {};
  static SpriteMap? _spriteMap;
  static Future<SpriteMap> _loadSpriteMap() async {
    return _spriteMap ??= await SpriteMap.fromAssets(
      imageAsset: _spriteImageAsset,
      jsonAsset: _spriteJsonAsset,
    );
  }

  static void registerCustomIcon(AssetId assetId, ImageProvider imageProvider) {
    _customIconsCache[assetId.symbol.configSymbol] = imageProvider;
  }

  static void clearCaches() {
    _customIconsCache.clear();
    _spriteMap = null;
  }

  String get _sanitizedId =>
      AssetSymbol.symbolFromConfigId(assetId).toLowerCase();

  static Future<void> precacheAssetIcon(
    BuildContext context,
    AssetId asset, {
    bool throwExceptions = false,
  }) async {
    final sanitizedId = AssetSymbol.symbolFromConfigId(asset.id).toLowerCase();
    try {
      if (_customIconsCache.containsKey(asset.symbol.configSymbol)) {
        if (context.mounted) {
          await precacheImage(
            _customIconsCache[asset.symbol.configSymbol]!,
            context,
            onError: (e, stackTrace) {
              if (throwExceptions) {
                throw Exception(
                  'Failed to pre-cache custom image for coin $asset: $e',
                );
              }
            },
          );
        }
        return;
      }

      final map = await _loadSpriteMap();
      final rect = map.rectFor(sanitizedId);
      if (rect != null && context.mounted) {
        await precacheImage(
          AssetImage(_spriteImageAsset),
          context,
          onError: (_, __) {},
        );
      }
    } catch (e) {
      debugPrint('Error in precacheAssetIcon for ${asset.id}: $e');
      if (throwExceptions) rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_customIconsCache.containsKey(_sanitizedId)) {
      return Image(
        image: _customIconsCache[_sanitizedId]!,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading custom icon for $assetId: $error');
          return Icon(Icons.monetization_on_outlined, size: size);
        },
      );
    }

    return FutureBuilder<SpriteMap>(
      future: _loadSpriteMap(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Icon(Icons.monetization_on_outlined, size: size);
        }
        final map = snapshot.data!;
        final rect = map.rectFor(_sanitizedId);
        if (rect == null) {
          return Icon(Icons.monetization_on_outlined, size: size);
        }
        return CustomPaint(
          size: Size.square(size),
          painter: _SpritePainter(map.image, rect, size),
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.image, this.source, this.size);

  final ui.Image image;
  final ui.Rect source;
  final double size;

  @override
  void paint(Canvas canvas, Size s) {
    final dst = ui.Rect.fromLTWH(0, 0, size, size);
    canvas.drawImageRect(image, source, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.source != source ||
        oldDelegate.size != size;
  }
}
