/// A high-level opinionated library that provides a simple way to build cross-platform Komodo Defi Framework applications (primarily focused on wallets). This package consists of multiple sub-packages in the packages folder which are orchestrated by this package (komodo_defi_sdk)
library;

export 'package:komodo_defi_framework/komodo_defi_framework.dart'
    show LocalConfig, RemoteConfig;

export 'package:komodo_defi_sdk/src/addresses/address_operations.dart'
    show AddressValidation;
export 'package:komodo_defi_sdk/src/sdk/komodo_defi_sdk_config.dart';

export 'src/assets/_assets_index.dart' show AssetHdWalletAddressesExtension;
export 'src/assets/asset_extensions.dart'
    show
        AssetFaucetExtension,
        AssetUnavailableErrorReasonExtension,
        AssetValidation;
export 'src/assets/asset_pubkey_extensions.dart';
export 'src/assets/legacy_asset_extensions.dart';
// // Export coin activation extension
// export 'package:komodo_defi_sdk/src/assets/asset_manager.dart'
//     show AssetActivation;

export 'src/komodo_defi_sdk.dart';

export 'src/widgets/asset_balance.dart';
