// // lib/src/komodo_defi_local_auth.dart

// import 'dart:async';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:komodo_defi_framework/komodo_defi_framework.dart';
// import 'package:komodo_defi_local_auth/src/auth/auth_result.dart';
// import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
// import 'package:komodo_defi_local_auth/src/auth/biometric_service.dart';
// import 'package:komodo_defi_local_auth/src/auth/kdf_user.dart';

// /// A package responsible for managing and abstracting out an authentication service
// /// on top of the Komodo DeFi Framework API's methods.
// class KomodoDefiLocalAuth {
//   final KomodoDefiFramework _kdf;
//   final AuthService _authService;
//   final BiometricService _biometricService;
//   final FlutterSecureStorage _secureStorage;

//   KdfUser? _currentUser;
//   final _authStateController = StreamController<KdfUser?>.broadcast();
//   bool _initialized = false;

//   /// Creates a new instance of [KomodoDefiLocalAuth].
//   ///
//   /// Requires an instance of [KomodoDefiFramework].
//   KomodoDefiLocalAuth(this._kdf)
//       : _authService = AuthService(_kdf),
//         _biometricService = BiometricService(),
//         _secureStorage = const FlutterSecureStorage();

//   /// Initializes the authentication service.
//   ///
//   /// This method should be called before using any other methods of this class.
//   /// It retrieves the stored user data, if any, and sets up the initial auth state.
//   Future<void> initialize() async {
//     if (_initialized) return;

//     final storedUserJson = await _secureStorage.read(key: 'kdf_user');
//     if (storedUserJson != null) {
//       _currentUser = KdfUser.fromJson(storedUserJson);
//       _authStateController.add(_currentUser);
//     }

//     _initialized = true;
//   }

//   /// Returns a stream of authentication state changes.
//   ///
//   /// Emits the current [KdfUser] when signed in, or `null` when signed out.
//   Stream<KdfUser?> get authStateChanges => _authStateController.stream;

//   /// Returns the currently authenticated user, or `null` if not authenticated.
//   KdfUser? get currentUser => _currentUser;

//   /// Attempts to log in a user with the provided [accountId] and [password].
//   ///
//   /// Returns an [AuthResult] indicating success or failure.
//   Future<AuthResult> login(String accountId, String password) async {
//     _checkInitialized();
//     final result = await _authService.login(accountId, password);
//     if (result.success) {
//       await _setCurrentUser(KdfUser(accountId: accountId));
//     }
//     return result;
//   }

//   /// Attempts to log in a user with the provided [seed].
//   ///
//   /// Returns an [AuthResult] indicating success or failure.
//   Future<AuthResult> loginWithSeed(String seed) async {
//     _checkInitialized();
//     final result = await _authService.loginWithSeed(seed);
//     if (result.success) {
//       await _setCurrentUser(KdfUser(accountId: result.accountId!));
//     }
//     return result;
//   }

//   /// Attempts to log in a user with biometrics for the given [accountId].
//   ///
//   /// Returns an [AuthResult] indicating success or failure.
//   Future<AuthResult> loginWithBiometrics(String accountId) async {
//     _checkInitialized();
//     final biometricResult = await _biometricService.authenticate();
//     if (!biometricResult) {
//       return AuthResult.failure('Biometric authentication failed');
//     }
//     final result = await _authService.loginWithBiometrics(accountId);
//     if (result.success) {
//       await _setCurrentUser(KdfUser(accountId: accountId));
//     }
//     return result;
//   }

//   /// Logs out the current user.
//   Future<void> logout() async {
//     _checkInitialized();
//     await _authService.logout();
//     await _clearCurrentUser();
//   }

//   /// Creates a new account with the given [seed] and [password].
//   ///
//   /// Returns an [AuthResult] indicating success or failure.
//   Future<AuthResult> createAccount(String seed, String password) async {
//     _checkInitialized();
//     final result = await _authService.createAccount(seed, password);
//     if (result.success) {
//       await _setCurrentUser(KdfUser(accountId: result.accountId!));
//     }
//     return result;
//   }

//   /// Resets the password for the account with the given [accountId].
//   ///
//   /// Requires the account [seed] for verification.
//   /// Returns an [AuthResult] indicating success or failure.
//   Future<AuthResult> resetPassword(
//       String accountId, String seed, String newPassword) async {
//     _checkInitialized();
//     final result =
//         await _authService.resetPassword(accountId, seed, newPassword);
//     if (result.success) {
//       await _setCurrentUser(KdfUser(accountId: accountId));
//     }
//     return result;
//   }

//   /// Checks if biometric authentication is available on the device.
//   Future<bool> isBiometricAvailable() async {
//     return _biometricService.isBiometricAvailable();
//   }

//   /// Sets the current user and updates the auth state.
//   Future<void> _setCurrentUser(KdfUser? user) async {
//     _currentUser = user;
//     if (user != null) {
//       await _secureStorage.write(key: 'kdf_user', value: user.toJson());
//     } else {
//       await _secureStorage.delete(key: 'kdf_user');
//     }
//     _authStateController.add(user);
//   }

//   /// Clears the current user and updates the auth state.
//   Future<void> _clearCurrentUser() async {
//     await _setCurrentUser(null);
//   }

//   /// Checks if the auth service has been initialized.
//   void _checkInitialized() {
//     if (!_initialized) {
//       throw StateError(
//           'KomodoDefiLocalAuth has not been initialized. Call initialize() first.');
//     }
//   }

//   /// Disposes of the resources used by this instance.
//   void dispose() {
//     _authStateController.close();
//   }
// }
