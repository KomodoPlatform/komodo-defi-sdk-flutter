import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

/// Holds sprite sheet image and icon coordinates.
class SpriteMap {
  SpriteMap({
    required this.image,
    required this.coordinates,
    required this.iconSize,
  });

  /// Loaded sprite map image.
  final ui.Image image;

  /// Coordinate map for icons.
  final Map<String, ui.Rect> coordinates;

  /// Icon size as defined in metadata.
  final int iconSize;

  /// Loads a [SpriteMap] from asset paths.
  static Future<SpriteMap> fromAssets({
    required String imageAsset,
    required String jsonAsset,
  }) async {
    final imageData = await rootBundle.load(imageAsset);
    final codec = await ui.instantiateImageCodec(
      imageData.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final jsonString = await rootBundle.loadString(jsonAsset);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    final meta = map['metadata'] as Map<String, dynamic>;
    final coordsRaw = map['coordinates'] as Map<String, dynamic>;

    final coords = <String, ui.Rect>{};
    for (final entry in coordsRaw.entries) {
      final value = entry.value as Map<String, dynamic>;
      coords[entry.key] = ui.Rect.fromLTWH(
        (value['x'] as num).toDouble(),
        (value['y'] as num).toDouble(),
        (value['width'] as num).toDouble(),
        (value['height'] as num).toDouble(),
      );
    }

    return SpriteMap(
      image: image,
      coordinates: coords,
      iconSize: meta['icon_size'] as int,
    );
  }

  /// Returns the source rectangle for [id] or null if not found.
  ui.Rect? rectFor(String id) => coordinates[id];
}
