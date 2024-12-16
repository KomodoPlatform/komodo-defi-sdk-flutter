import 'package:komodo_defi_sdk/src/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/types.dart';

extension AssetHdWalletAddressesExtension on Asset {
  /// Returns a set of the reasons why a new address cannot be created. This is
  /// useful for the UI to determine why the "Create New Address" button is
  /// disabled.
  ///
  /// Returns null if a new address can be created.
  ///
  /// Note: This method may take long to complete if the asset isn't already
  /// activated.
  ///
  ///! Do not use this on a long list of coins as it requires activating each
  ///! coin to check if the last 3 addresses are unused, and potentially other
  ///! expensive operations. If this is absolutely necessary, then we will
  ///! revisit the implementation with a more efficient solution.
  ///
  /// If you need to check multiple assets (e.g. an assets list page) then
  /// consider using [Asset().getUnavailableReasons()] instead. It can potentially
  /// be converted to a sync method if needed.
  Future<Set<CantCreateNewAddressReason>?> getCantCreateNewAddressReasons([
    KomodoDefiSdk? sdk,
  ]) async {
    sdk ??= KomodoDefiSdk();

    final user = await sdk.auth.currentUser;

    final reasons = <CantCreateNewAddressReason>{};

    final supportsMultipleAddresses = protocol.supportsMultipleAddresses;

    if (supportsMultipleAddresses && id.derivationPath == null) {
      reasons.add(CantCreateNewAddressReason.missingDerivationPath);
    }

    if (!protocol.supportsMultipleAddresses) {
      reasons.add(CantCreateNewAddressReason.protocolNotSupported);
    }

    if (user == null) {
      return reasons..add(CantCreateNewAddressReason.noActiveWallet);
    }
    final isHdWallet = user.isHd;
    if (!isHdWallet) {
      reasons.add(CantCreateNewAddressReason.derivationModeNotSupported);
    }

    if (supportsMultipleAddresses) {
      final addresses = await sdk.pubkeys.getPubkeys(this);
      if (addresses.keys.length >= 20) {
        reasons.add(CantCreateNewAddressReason.maxAddressesReached);
      }

      // Consider carefully how to handle this as it would break things if
      // TODO! Replace the balance check with a check for transactions.
      // If 3 addresses are unused, we can't create a new one.
      // this is used in a long list of addresses.
      final unusedAddressesCount =
          addresses.keys.where((key) => !key.balance.hasBalance).length;

      if (unusedAddressesCount >= 3) {
        reasons.add(CantCreateNewAddressReason.maxGapLimitReached);
      }
    }
    return reasons;
  }
}
