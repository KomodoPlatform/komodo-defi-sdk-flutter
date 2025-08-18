import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/bootstrap.dart';
import 'package:komodo_defi_sdk/src/fees/fee_manager.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_sdk/src/message_signing/message_signing_manager.dart';
import 'package:komodo_defi_sdk/src/merchant/merchant_invoices_manager.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/storage/secure_rpc_password_mixin.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoDefiSdk with SecureRpcPasswordMixin {
  factory KomodoDefiSdk({IKdfHostConfig? host, KomodoDefiSdkConfig? config}) {
    return KomodoDefiSdk._(host, config ?? const KomodoDefiSdkConfig(), null);
  }

  factory KomodoDefiSdk.fromFramework(
    KomodoDefiFramework framework, {
    KomodoDefiSdkConfig? config,
  }) {
    return KomodoDefiSdk._(
      null,
      config ?? const KomodoDefiSdkConfig(),
      framework,
    );
  }

  KomodoDefiSdk._(this._hostConfig, this._config, this._kdfFramework) {
    _container = GetIt.asNewInstance();
  }

  final IKdfHostConfig? _hostConfig;
  final KomodoDefiSdkConfig _config;
  KomodoDefiFramework? _kdfFramework;
  late final GetIt _container;
  bool _isInitialized = false;
  bool _isDisposed = false;
  Future<void>? _initializationFuture;

  ApiClient get client => _assertSdkInitialized(_container<ApiClient>());

  KomodoDefiLocalAuth get auth =>
      _assertSdkInitialized(_container<KomodoDefiLocalAuth>());

  PubkeyManager get pubkeys =>
      _assertSdkInitialized(_container<PubkeyManager>());

  AddressOperations get addresses =>
      _assertSdkInitialized(_container<AddressOperations>());

  AssetManager get assets => _assertSdkInitialized(_container<AssetManager>());

  TransactionHistoryManager get transactions =>
      _assertSdkInitialized(_container<TransactionHistoryManager>());

  MessageSigningManager get messageSigning =>
      _assertSdkInitialized(_container<MessageSigningManager>());

  MnemonicValidator get mnemonicValidator =>
      _assertSdkInitialized(_container<MnemonicValidator>());

  WithdrawalManager get withdrawals =>
      _assertSdkInitialized(_container<WithdrawalManager>());

  SecurityManager get security =>
      _assertSdkInitialized(_container<SecurityManager>());

  MarketDataManager get marketData =>
      _assertSdkInitialized(_container<MarketDataManager>());

  FeeManager get fees => _assertSdkInitialized(_container<FeeManager>());

  MerchantInvoicesManager get merchantInvoices =>
      _assertSdkInitialized(_container<MerchantInvoicesManager>());

  BalanceManager get balances =>
      _assertSdkInitialized(_container<BalanceManager>());

  Future<void> initialize() async {
    _assertNotDisposed();
    if (_isInitialized) return;
    _initializationFuture ??= _initialize();
    await _initializationFuture;
  }

  Future<void> ensureInitialized() async {
    _assertNotDisposed();
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _initialize() async {
    _assertNotDisposed();
    await bootstrap(
      hostConfig: _hostConfig,
      config: _config,
      kdfFramework: _kdfFramework,
      container: _container,
    );
    _isInitialized = true;
  }

  Future<AuthOptions?> currentUserAuthOptions() async {
    _assertSdkInitialized(auth);
    final user = await auth.currentUser;
    return user == null
        ? null
        : KomodoDefiLocalAuth.storedAuthOptions(user.walletId.name);
  }

  T _assertSdkInitialized<T>(T val) {
    _assertNotDisposed();
    if (!_isInitialized) {
      throw StateError(
        'Cannot call $T because KomodoDefiSdk is not '
        'initialized. Call initialize() or await ensureInitialized() first.',
      );
    }
    return val;
  }

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('KomodoDefiSdk has been disposed');
    }
  }

  Future<void> _disposeIfRegistered<T extends Object>(
    Future<void> Function(T) fn,
  ) async {
    if (_container.isRegistered<T>()) {
      try {
        await fn(_container<T>());
      } catch (e) {
        log('Error disposing $T: $e');
      }
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    if (!_isInitialized) return;

    _isInitialized = false;
    _initializationFuture = null;

    await Future.wait([
      _disposeIfRegistered<KomodoDefiLocalAuth>((m) => m.dispose()),
      _disposeIfRegistered<AssetManager>((m) => m.dispose()),
      _disposeIfRegistered<ActivationManager>((m) => m.dispose()),
      _disposeIfRegistered<BalanceManager>((m) => m.dispose()),
      _disposeIfRegistered<PubkeyManager>((m) => m.dispose()),
      _disposeIfRegistered<TransactionHistoryManager>((m) => m.dispose()),
      _disposeIfRegistered<MarketDataManager>((m) => m.dispose()),
      _disposeIfRegistered<FeeManager>((m) => m.dispose()),
      _disposeIfRegistered<WithdrawalManager>((m) => m.dispose()),
      _disposeIfRegistered<SecurityManager>((m) => m.dispose()),
      _disposeIfRegistered<MerchantInvoicesManager>((m) => m.dispose()),
    ]);

    await _container.reset();

    if (_kdfFramework != null) {
      await _kdfFramework!.dispose();
      _kdfFramework = null;
    }
  }
}