import Foundation
import Flutter
import UIKit

/// Handles automatic app restart on iOS when KDF encounters fatal errors or shutdown signals.
/// 
/// Since iOS doesn't allow true programmatic restarts, this implementation:
/// 1. Gracefully exits the app via exit(0)
/// 2. User manually reopens the app
///
/// This is a simple approach that doesn't require notification permissions.
@objc public class KdfRestartHandler: NSObject, FlutterPlugin {
    private static let channelName = "com.komodoplatform.kdf/restart"
    private static var channel: FlutterMethodChannel?
    
    /// Registers the plugin with the Flutter engine
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = KdfRestartHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
        KdfRestartHandler.channel = channel
    }
    
    /// Handles method calls from Dart
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestAppRestart":
            guard let args = call.arguments as? [String: Any],
                  let reason = args["reason"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Missing reason argument",
                    details: nil
                ))
                return
            }
            
            requestAppRestart(reason: reason, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Initiates the app restart process by gracefully exiting
    ///
    /// - Parameters:
    ///   - reason: The reason for the restart (e.g., "broken_pipe", "shutdown_signal")
    ///   - result: Flutter result callback
    private func requestAppRestart(
        reason: String,
        result: @escaping FlutterResult
    ) {
        NSLog("[KDF] App restart requested due to: \(reason)")
        NSLog("[KDF] Exiting app - user will need to manually reopen")
        
        result(true)
        
        // Give a brief moment for Flutter to receive the result before exiting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSLog("[KDF] Exiting app for restart...")
            // exit(0) is discouraged by Apple but necessary here for error recovery
            exit(0)
        }
    }
}
