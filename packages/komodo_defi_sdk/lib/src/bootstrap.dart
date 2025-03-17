// ignore_for_file: cascade_invocations

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/addresses/address_operations.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
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
    return assetManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth]);

  // Register activation manager with asset manager dependency
  container.registerSingletonAsync<ActivationManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();
    final assetManager = await container.getAsync<AssetManager>();
    final activationManager = ActivationManager(
      client,
      auth,
      container<AssetHistoryStorage>(),
      container<CustomAssetHistoryStorage>(),
      assetManager,
    );

    return activationManager;
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth, AssetManager]);

  // Register remaining managers
  container.registerSingletonAsync<PubkeyManager>(() async {
    final client = await container.getAsync<ApiClient>();
    final auth = await container.getAsync<KomodoDefiLocalAuth>();
    final activationManager = await container.getAsync<ActivationManager>();
    return PubkeyManager(client, auth, activationManager);
  }, dependsOn: [ApiClient, KomodoDefiLocalAuth, ActivationManager]);

  container.registerSingleton(
    AddressOperations(await container.getAsync<ApiClient>()),
  );

  container.registerSingletonAsync<MnemonicValidator>(() async {
    final validator = MnemonicValidator();
    await validator.init();
    return validator;
  });

  container.registerSingletonAsync<BalanceManager>(() async {
    final activationManager = await container.getAsync<ActivationManager>();
    final assets = await container.getAsync<AssetManager>();
    return BalanceManager(
      activationManager: activationManager,
      assetLookup: assets,
      pubkeyManager: await container.getAsync<PubkeyManager>(),
      auth: await container.getAsync<KomodoDefiLocalAuth>(),
    );
  }, dependsOn: [ActivationManager, AssetManager, KomodoDefiLocalAuth]);

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

  // Wait for all async singletons to initialize
  await container.allReady();
}
