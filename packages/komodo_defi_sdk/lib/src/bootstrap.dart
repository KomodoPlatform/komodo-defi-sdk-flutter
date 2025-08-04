// ignore_for_file: cascade_invocations

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/fees/fee_manager.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_sdk/src/message_signing/message_signing_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
import 'package:komodo_defi_sdk/src/swaps/swap_history_manager.dart';

import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Bootstrap the SDK's dependencies
Future<void> bootstrap({
  required IKdfHostConfig? hostConfig,
  required KomodoDefiSdkConfig config,
  required GetIt container,
  KomodoDefiFramework? kdfFramework,
}) async {
  final rpcPassword = await SecureRpcPasswordMixin().ensureRpcPassword();

  // Framework and core dependencies
  container.registerSingletonAsync<KomodoDefiFramework>(() async {
    if (kdfFramework != null) return kdfFramework;

    final resolvedHostConfig =
        hostConfig ?? LocalConfig(https: true, rpcPassword: rpcPassword);

    return KomodoDefiFramework.create(
      hostConfig: resolvedHostConfig,
      externalLogger: kDebugMode ? print : null,
    );
  });

  container.registerSingletonAsync<ApiClient>(() async {
    final framework = await container.getAsync<KomodoDefiFramework>();
    return framework.client;
  }, dependsOn: [KomodoDefiFramework]);

  // Auth and storage dependencies
  container.registerSingletonAsync<KomodoDefiLocalAuth>(() async {
    final framework = await container.getAsync<KomodoDefiFramework>();
    final auth = KomodoDefiLocalAuth(
      kdf: framework,
      hostConfig:
          hostConfig ?? LocalConfig(https: true, rpcPassword: rpcPassword),
    );
    await auth.ensureInitialized();
    return auth;
  }, dependsOn: [KomodoDefiFramework]);

  // Asset history storage singletons
  container.registerLazySingleton(AssetHistoryStorage.new);
  container.registerLazySingleton(CustomAssetHistoryStorage.new);

  // Register asset manager first since it's a core dependency
  container.registerSingletonAsync<AssetManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();
    final assetManager = AssetManager(
      client,
      auth,
      config,
      container<CustomAssetHistoryStorage>(),
      () => container<ActivationManager>(),
    );
    await assetManager.init();
    // Will be removed in near future after KW is fully migrated to KDF
    await assetManager.initTickerIndex();
    return assetManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth]);

  // Register BalanceManager BEFORE ActivationManager to avoid circular dependency
  container.registerSingletonAsync<BalanceManager>(() async {
    final assets = await container.getAsync<AssetManager>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();

    // Create BalanceManager without its dependencies on SharedActivationCoordinator and PubkeyManager initially
    return BalanceManager(
      activationCoordinator:
          null, // Will be set after SharedActivationCoordinator is created
      assetLookup: assets,
      pubkeyManager: null, // Will be set after PubkeyManager is created
      auth: auth,
    );
  }, dependsOn: [AssetManager, KomodoDefiLocalAuth]);

  // Register activation manager with asset manager dependency
  container.registerSingletonAsync<ActivationManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();
    final assetManager = await container.getAsync<AssetManager>();
    final balanceManager = await container.getAsync<BalanceManager>();

    final activationManager = ActivationManager(
      client,
      auth,
      container<AssetHistoryStorage>(),
      container<CustomAssetHistoryStorage>(),
      assetManager,
      balanceManager,
    );

    return activationManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth, AssetManager, BalanceManager]);

  // Register shared activation coordinator
  container.registerSingletonAsync<SharedActivationCoordinator>(() async {
    final activationManager = await container.getAsync<ActivationManager>();
    final balanceManager = await container.getAsync<BalanceManager>();

    final coordinator = SharedActivationCoordinator(
      activationManager,
      await container.getAsync<KomodoDefiLocalAuth>(),
    );

    if (balanceManager.activationCoordinator == null) {
      balanceManager.setActivationCoordinator(coordinator);
    }

    return coordinator;
  }, dependsOn: [ActivationManager, BalanceManager, KomodoDefiLocalAuth]);

  // Register remaining managers
  container.registerSingletonAsync<PubkeyManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();
    final activationCoordinator =
        await container.getAsync<SharedActivationCoordinator>();
    final pubkeyManager = PubkeyManager(client, auth, activationCoordinator);

    // Set the PubkeyManager on BalanceManager now that it's available
    final balanceManager = await container.getAsync<BalanceManager>();
    if (balanceManager.pubkeyManager == null) {
      balanceManager.setPubkeyManager(pubkeyManager);
    }

    return pubkeyManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth, SharedActivationCoordinator]);

  container.registerSingleton(
    AddressOperations(await container.getAsync<ApiClient>()),
  );

  container.registerSingletonAsync<MnemonicValidator>(() async {
    final validator = MnemonicValidator();
    await validator.init();
    return validator;
  });

  // TODO: Consider if more appropropriate for initialization of these
  // dependencies to be done internally in the `cex_market_data` package.
  container.registerSingleton<CexRepository>(
    BinanceRepository(binanceProvider: const BinanceProvider()),
  );

  container.registerSingleton<KomodoPriceProvider>(KomodoPriceProvider());

  container.registerSingletonAsync<MessageSigningManager>(
    () async => MessageSigningManager(await container.getAsync<ApiClient>()),
    dependsOn: [ApiClient],
  );

  container.registerSingleton<KomodoPriceRepository>(
    KomodoPriceRepository(cexPriceProvider: container<KomodoPriceProvider>()),
  );

  container.registerSingletonAsync<MarketDataManager>(() async {
    final manager = CexMarketDataManager(
      priceRepository: container<CexRepository>(),
      komodoPriceRepository: container<KomodoPriceRepository>(),
    );
    await manager.init();
    return manager;
  });

  container.registerSingletonAsync<FeeManager>(() async {
    final client = await container.getAsync<ApiClient>();
    return FeeManager(client);
  }, dependsOn: [ApiClient]);

  container.registerSingletonAsync<TransactionHistoryManager>(
    () async {
      final client = await container.getAsync<ApiClient>();
      final auth = await container.getAsync<KomodoDefiLocalAuth>();
      final assetProvider = await container.getAsync<AssetManager>();
      final pubkeys = await container.getAsync<PubkeyManager>();
      final activationCoordinator =
          await container.getAsync<SharedActivationCoordinator>();
      return TransactionHistoryManager(
        client,
        auth,
        assetProvider,
        activationCoordinator,
        pubkeyManager: pubkeys,
      );
    },
    dependsOn: [
      ApiClient,
      KomodoDefiLocalAuth,
      AssetManager,
      PubkeyManager,
      SharedActivationCoordinator,
    ],
  );

  container.registerSingletonAsync<WithdrawalManager>(
    () async {
      final client = await container.getAsync<ApiClient>();
      final assetProvider = await container.getAsync<AssetManager>();
      final feeManager = await container.getAsync<FeeManager>();

      final activationCoordinator =
          await container.getAsync<SharedActivationCoordinator>();
      return WithdrawalManager(
        client,
        assetProvider,
        feeManager,
        activationCoordinator,
      );
    },
    dependsOn: [
      ApiClient,
      AssetManager,
      SharedActivationCoordinator,
      FeeManager,
    ],
  );

  container.registerSingletonAsync<SecurityManager>(
    () async {
      final client = await container.getAsync<ApiClient>();
      final auth = await container.getAsync<KomodoDefiLocalAuth>();
      final assetProvider = await container.getAsync<AssetManager>();
      final activationCoordinator =
          await container.getAsync<SharedActivationCoordinator>();
      return SecurityManager(
        client,
        auth,
        assetProvider,
        activationCoordinator,
      );
    },
    dependsOn: [
      ApiClient,
      KomodoDefiLocalAuth,
      AssetManager,
      SharedActivationCoordinator,
    ],
  );

  container.registerSingletonAsync<OrderbookManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final assetProvider = await container.getAsync<AssetManager>();
    final activationManager = await container.getAsync<ActivationManager>();
    return OrderbookManager(client, assetProvider, activationManager);
  }, dependsOn: [ApiClient, AssetManager, ActivationManager]);

  container.registerSingletonAsync<SwapManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final assetProvider = await container.getAsync<AssetManager>();
    final activationManager = await container.getAsync<ActivationManager>();
    return SwapManager(client, assetProvider, activationManager);
  }, dependsOn: [ApiClient, AssetManager, ActivationManager]);

  container.registerSingletonAsync<SwapHistoryManager>(
    () async {
      final client = await container.getAsync<ApiClient>();
      final auth = await container.getAsync<KomodoDefiLocalAuth>();
      final activationManager = await container.getAsync<ActivationManager>();
      final assetManager = await container.getAsync<AssetManager>();
      return SwapHistoryManager(client, auth, activationManager, assetManager);
    },
    dependsOn: [
      ApiClient,
      KomodoDefiLocalAuth,
      AssetManager,
      ActivationManager,
    ],
  );

  // Wait for all async singletons to initialize
  await container.allReady();
}
