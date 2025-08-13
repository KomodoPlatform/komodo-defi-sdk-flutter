/// A high-level opinionated library that provides a simple way to build
/// cross-platform Komodo Defi Framework applications
/// (primarily focused on wallets). This package consists of multiple
/// sub-packages in the packages folder which are orchestrated by this
/// package (komodo_defi_sdk)
library;

export 'package:komodo_cex_market_data/komodo_cex_market_data.dart'
    show Commodity, Cryptocurrency, FiatCurrency, QuoteCurrency, Stablecoin;
export 'package:komodo_defi_framework/komodo_defi_framework.dart'
    show IKdfHostConfig, LocalConfig, RemoteConfig;
export 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart'
    show AuthenticationState, AuthenticationStatus;
export 'package:komodo_defi_sdk/src/addresses/address_operations.dart'
    show AddressOperations;
export 'package:komodo_defi_sdk/src/balances/balance_manager.dart'
    show BalanceManager;
export 'package:komodo_defi_sdk/src/sdk/komodo_defi_sdk_config.dart';
export 'package:komodo_defi_sdk/src/security/security_manager.dart'
    show SecurityManager;
export 'package:komodo_defi_sdk/src/swaps/swap_manager.dart' show SwapManager;
export 'package:komodo_defi_sdk/src/swaps/swap_manager_interface.dart'
    show ISwapManager;
export 'package:komodo_defi_types/komodo_defi_types.dart'
    show
        SwapStatus,
        OrderSide,
        OrderbookSnapshot,
        OrderbookEntry,
        PlacedOrderSummary,
        TradePreimageQuote,
        CoinAmount,
        TotalFeeEntry,
        SwapSummary;

export 'src/assets/_assets_index.dart' show AssetHdWalletAddressesExtension;
export 'src/assets/asset_extensions.dart'
    show
        AssetFaucetExtension,
        AssetUnavailableErrorReasonExtension,
        AssetValidation;
export 'src/assets/asset_pubkey_extensions.dart';
export 'src/assets/legacy_asset_extensions.dart';
export 'src/komodo_defi_sdk.dart' show KomodoDefiSdk;
export 'src/widgets/asset_balance_text.dart';
