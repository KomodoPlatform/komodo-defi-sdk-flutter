import Flutter
import UIKit

/// Main plugin class for the Komodo DeFi Framework iOS platform integration
public class KomodoDefiFrameworkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Register the restart handler
        KdfRestartHandler.register(with: registrar)
    }
}

