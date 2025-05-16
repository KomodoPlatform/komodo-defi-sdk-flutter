// // lib/src/auth/auth_repository.dart

// import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
// import 'package:komodo_defi_local_auth/src/auth/biometric_service.dart';

// class AuthRepository {
//   final AuthService _authService;
//   final BiometricService _biometricService;

//   AuthRepository(this._authService, this._biometricService);

//   Future<bool> login(String accountId, String password) async {
//     return await _authService.login(accountId, password);
//   }

//   Future<String?> loginWithSeed(String seed) async {
//     return await _authService.loginWithSeed(seed);
//   }

//   Future<bool> loginWithBiometrics(String accountId) async {
//     final isAuthenticated = await _biometricService.authenticate();
//     if (isAuthenticated) {
//       return await _authService.loginWithBiometrics(accountId);
//     }
//     return false;
//   }

//   Future<void> logout() async {
//     await _authService.logout();
//   }

//   Future<String?> createAccount(String seed, String password) async {
//     return await _authService.createAccount(seed, password);
//   }

//   Future<bool> resetPassword(
//       String accountId, String seed, String newPassword) async {
//     return await _authService.resetPassword(accountId, seed, newPassword);
//   }
// }
