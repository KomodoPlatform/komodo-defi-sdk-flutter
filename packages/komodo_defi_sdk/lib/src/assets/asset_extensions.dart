import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Core extension providing asset validation and compatibility checks
extension AssetValidation on Asset {
  /// Checks if this asset is valid for use.
  /// A valid asset has all required protocol fields and configuration.
  bool get isValid {
    try {
      // For SLP tokens, we don't require a derivation path
      if (protocol is SlpProtocol) {
        return true;
      }

      // Other protocols require derivation paths for multiple addresses
      if (protocol.supportsMultipleAddresses) {
        final derivationPath = id.derivationPath ?? protocol.derivationPath;
        if (derivationPath == null) {
          return false;
        }
      }

      // Ensure required servers are available
      if (protocol.requiredServers.isEmpty ?? true) {
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

  /// Check compatibility with specific wallet options.
  /// Useful for pre-checking compatibility before wallet mode changes.
  bool isCompatibleWith(AuthOptions options) {
    if (!isValid) return false;
    return _checkWalletCompatibility(options);
  }

  /// Core compatibility logic checking if the asset works with given wallet mode
  bool _checkWalletCompatibility(AuthOptions options) {
    final isHdWallet = options.derivationMethod == DerivationMethod.hdWallet;

    // SLP tokens always use single address mode regardless of wallet mode
    if (protocol is SlpProtocol) {
      return true;
    }

    // Check if protocol requires HD wallet
    if (protocol.requiresHdWallet && !isHdWallet) {
      return false;
    }

    // For HD wallets, check derivation path requirements for multi-address protocols
    if (isHdWallet && protocol.supportsMultipleAddresses) {
      final derivationPath = id.derivationPath ?? protocol.derivationPath;
      if (derivationPath == null) {
        return false;
      }
    }

    return true;
  }

  /// Get derivation path from either the asset ID or protocol
  String? get derivationPath => id.derivationPath ?? protocol.derivationPath;

  /// Whether this asset supports multiple addresses
  bool get supportsMultipleAddresses => protocol.supportsMultipleAddresses;

  /// Whether this asset requires HD wallet mode
  bool get requiresHdWallet => protocol.requiresHdWallet;

  /// Get human-readable reason why an asset might be disabled
  String? getDisabledReason(AuthOptions options) {
    if (!isValid) {
      if (protocol.supportsMultipleAddresses && derivationPath == null) {
        return 'Missing derivation path required for multiple addresses';
      }
      if (protocol.requiredServers.isEmpty ?? true) {
        return 'No servers configured';
      }
      return 'Invalid configuration';
    }

    final isHdWallet = options.derivationMethod == DerivationMethod.hdWallet;

    if (protocol.requiresHdWallet && !isHdWallet) {
      return 'Requires HD wallet mode';
    }

    if (isHdWallet &&
        protocol.supportsMultipleAddresses &&
        derivationPath == null) {
      return 'Missing derivation path for HD wallet';
    }

    return null;
  }
}
