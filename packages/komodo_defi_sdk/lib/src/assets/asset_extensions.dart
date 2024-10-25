import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

extension AssetCompat on Asset {
  /// Returns whether the asset is compatible with the current wallet mode
  Future<bool> get isCompatible async {
    // TODO: Singleton usage.
    final isHdWallet = await KomodoDefiSdk.global.currentUserAuthOptions().then(
          (options) => options?.derivationMethod == DerivationMethod.hdWallet,
        );

    return isSupported(isHdWallet: isHdWallet);
  }

  bool isCompatibleWith({required AuthOptions options}) {
    return isSupported(
      isHdWallet: options.derivationMethod == DerivationMethod.hdWallet,
    );
  }

  /// Returns whether the asset should be filtered from display
  Future<bool> get shouldBeFiltered async {
    final isHdWallet = await isCompatible;

    return isFilteredOut(isHdWallet: isHdWallet);
  }
}

extension AssetStrategyExtension on Asset {
  /// Get the preferred strategy for this asset based on HD wallet status
  PubkeyStrategy preferredPubkeyStrategy({required bool isHdWallet}) {
    return PubkeyStrategyFactory.createStrategy(
      protocol,
      isHdWallet: isHdWallet,
    );
  }

  /// Helper to check if an asset should be filtered from display
  bool isFilteredOut({required bool isHdWallet}) {
    final strategy = preferredPubkeyStrategy(isHdWallet: isHdWallet);
    return strategy.supportsMultipleAddresses && id.derivationPath == null;
  }
}

extension AssetSupport on Asset {
  /// Check if asset is compatible with the SDK.
  ///
  /// [isHdWallet]: Whether the wallet is in HD mode
  /// [isHdWallet] = `null` returns coins that are compatible with both HD and non-HD wallets
  /// [isHdWallet] = `true` returns coins that require HD wallet
  /// [isHdWallet]= `false` returns coins that require non-HD wallet
  /// `
  bool isSupported({required bool isHdWallet}) {
    // // Some assets require HD wallet
    // if (protocol is UtxoProtocol && !isHdWallet) {
    //   return false;
    // }
    try {
      final pubkeyStrategy = preferredPubkeyStrategy(isHdWallet: isHdWallet);

      if (isHdWallet &&
          id.derivationPath == null &&
          pubkeyStrategy.supportsMultipleAddresses) {
        return false;
      }

      // Check if strategy supports current wallet mode
      return pubkeyStrategy.protocolSupported(protocol);
    } catch (e) {
      // print(e);
      return false;
    }
  }
}
