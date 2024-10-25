/// A high-level opinionated library that provides a simple way to build cross-platform Komodo Defi Framework applications (primarily focused on wallets). This package consists of multiple sub-packages in the packages folder which are orchestrated by this package (komodo_defi_sdk)
library;

export 'package:komodo_defi_sdk/src/sdk/sdk_config.dart';

export 'src/assets/asset_extensions.dart' show AssetSupport;
// // Export coin activation extension
// export 'package:komodo_defi_sdk/src/assets/asset_manager.dart'
//     show AssetActivation;

export 'src/komodo_defi_sdk.dart';
