import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';

class KomodoCoinUpdater {
  /// Initializes the Hive adapters for the Komodo Coin Updates package.
  ///
  /// This method is used to initialize the Hive adapters for the Komodo Coin
  /// Updates package.
  ///
  /// The [appFolder] is the path to the app folder.
  static Future<void> ensureInitialized(String appFolder) async {
    await Hive.initFlutter(appFolder);
    Hive.registerAdapters();
  }

  /// Initializes the Hive adapters for the Komodo Coin Updates package in an
  /// isolate.
  ///
  /// This method is used to initialize the Hive adapters for the Komodo Coin
  /// Updates package in an isolate.
  ///
  /// The [fullAppFolderPath] is the path to the full app folder.
  static void ensureInitializedIsolate(String fullAppFolderPath) {
    Hive.init(fullAppFolderPath);
    Hive.registerAdapters();
  }

  /// Initializes the Hive adapters for the Komodo Coin Updates package.
  ///
  /// This method registers the adapters for the various Hive types used in the
  /// Komodo Coin Updates package.
  ///
  /// The adapters are used to convert between the Hive types and the Dart
  /// objects.
  static void initializeAdapters() {}
}
