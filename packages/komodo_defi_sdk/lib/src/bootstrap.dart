// ignore_for_file: cascade_invocations

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_sdk/src/message_signing/message_signing_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_sdk/src/staking/staking_manager.dart';
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

    // Create BalanceManager without its dependencies on ActivationManager and PubkeyManager initially
    return BalanceManager(
      activationManager: null, // Will be set after ActivationManager is created
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

    // Now that we have the ActivationManager, we can set it in BalanceManager
    // This assumes BalanceManager has a setter for activationManager
    if (balanceManager.activationManager == null) {
      balanceManager.setActivationManager(activationManager);
    }

    return activationManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth, AssetManager, BalanceManager]);

  // Register remaining managers
  container.registerSingletonAsync<PubkeyManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();
    final activationManager = await container.getAsync<ActivationManager>();
    final pubkeyManager = PubkeyManager(client, auth, activationManager);

    // Set the PubkeyManager on BalanceManager now that it's available
    final balanceManager = await container.getAsync<BalanceManager>();
    if (balanceManager.pubkeyManager == null) {
      balanceManager.setPubkeyManager(pubkeyManager);
    }

    return pubkeyManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth, ActivationManager]);

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

  container.registerSingletonAsync<TransactionHistoryManager>(
    () async {
      final client = await container.getAsync<ApiClient>();
      final auth = await container.getAsync<KomodoDefiLocalAuth>();
      final assetProvider = await container.getAsync<AssetManager>();
      final pubkeys = await container.getAsync<PubkeyManager>();
      final activationManager = await container.getAsync<ActivationManager>();
      return TransactionHistoryManager(
        client,
        auth,
        assetProvider,
        activationManager,
        pubkeyManager: pubkeys,
      );
    },
    dependsOn: [
      ApiClient,
      KomodoDefiLocalAuth,
      AssetManager,
      PubkeyManager,
      ActivationManager,
    ],
  );

  container.registerSingletonAsync<WithdrawalManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final assetProvider = await container.getAsync<AssetManager>();
    final activationManager = await container.getAsync<ActivationManager>();
    return WithdrawalManager(client, assetProvider, activationManager);
  }, dependsOn: [ApiClient, AssetManager, ActivationManager]);

  container.registerSingletonAsync<StakingManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final assetProvider = await container.getAsync<AssetManager>();
    final activationManager = await container.getAsync<ActivationManager>();
    return StakingManager(client, assetProvider, activationManager);
  }, dependsOn: [ApiClient, AssetManager, ActivationManager]);

  // Wait for all async singletons to initialize
  await container.allReady();
}
