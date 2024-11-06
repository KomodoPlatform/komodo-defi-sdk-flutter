import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Core extension providing asset validation and compatibility checks
extension AssetValidation on Asset {
  /// Checks if this asset is valid for use.
  /// A valid asset has all required protocol fields and configuration.
  bool get isValid {
    try {
      // Check if we have all required fields
      if (id.derivationPath == null && protocol.derivationPath == null) {
        return false;
      }

      // Ensure required servers are available
      if (protocol.requiredServers?.isEmpty ?? true) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Checks if the asset is compatible with the current wallet mode.
  ///
  /// This performs a full compatibility check including:
  /// - Basic validity
  /// - HD wallet compatibility
  /// - Protocol requirements
  Future<bool> get isCompatible async {
    if (!isValid) return false;

    final authOptions =
        await KomodoDefiSdk.global.auth.currentUsersAuthOptions();
    if (authOptions == null) return false;

    return _checkWalletCompatibility(authOptions);
  }

  /// Checks compatibility with specific wallet options.
  /// Useful for pre-checking compatibility before wallet mode changes.
  bool isCompatibleWith(AuthOptions options) {
    if (!isValid) return false;
    return _checkWalletCompatibility(options);
  }

  /// Core compatibility logic checking if the asset works with given wallet mode
  bool _checkWalletCompatibility(AuthOptions options) {
    final isHdWallet = options.derivationMethod == DerivationMethod.hdWallet;

    // Check if protocol requires HD wallet
    if (protocol.requiresHdWallet && !isHdWallet) {
      return false;
    }

    // Check derivation path requirements for HD mode
    if (isHdWallet && protocol.supportsMultipleAddresses) {
      final path = id.derivationPath ?? protocol.derivationPath;
      if (path == null) return false;
    }

    return true;
  }

  /// Determines if the asset should be displayed in the current context
  Future<bool> get shouldDisplay async {
    // Always hide invalid assets
    if (!isValid) return false;

    // Hide incompatible assets by default
    if (!await isCompatible) return false;

    // Could add additional display filters here

    return true;
  }
}

/// Extension for protocol-specific requirements and capabilities
extension ProtocolRequirements on ProtocolClass {
  /// Whether this protocol requires HD wallet support
  bool get requiresHdWallet => switch (this) {
        // Currently there are no protocols that do not work in legacy mode
        _ => false,
      };

  /// Whether this protocol supports multiple addresses
  bool get supportsMultipleAddresses => switch (this) {
        UtxoProtocol() => true,
        QtumProtocol() => true,
        Erc20Protocol() => true,
        _ => false,
      };

  /// The required derivation path format for this protocol
  String? get requiredDerivationPath => switch (this) {
        // UtxoProtocol() => "m/44'/0'/0'",
        // Erc20Protocol() => "m/44'/60'/0'/0",
        // SlpProtocol() => "m/44'/145'/0'",
        // QtumProtocol() => "m/44'/2301'/0'",
        _ => null,
      };
}

/// Example usage:
/// ```dart
/// final asset = Asset(...);
///
/// // Basic validation
/// if (!asset.isValid) {
///   print('Asset is missing required configuration');
///   return;
/// }
///
/// // Compatibility check
/// if (await asset.isCompatible) {
///   // Asset can be used with current wallet
/// }
///
/// // Display filtering
/// if (await asset.shouldDisplay) {
///   // Show asset in UI
/// }
///
/// // Pre-check compatibility
/// final hdCompatible = asset.isCompatibleWith(AuthOptions(
///   derivationMethod: DerivationMethod.hdWallet,
/// ));
/// ```
