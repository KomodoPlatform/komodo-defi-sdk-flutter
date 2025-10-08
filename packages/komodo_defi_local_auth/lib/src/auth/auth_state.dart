import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'auth_state.freezed.dart';

/// Represents the current state of an authentication process
@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    required AuthenticationStatus status,
    String? message,
    int? taskId,
    String? error,
    KdfUser? user,
    AuthenticationData? data,
  }) = _AuthenticationState;

  factory AuthenticationState.completed(KdfUser user) =>
      AuthenticationState(status: AuthenticationStatus.completed, user: user);

  factory AuthenticationState.error(String error) =>
      AuthenticationState(status: AuthenticationStatus.error, error: error);
}

/// Union type for wallet-specific authentication data
@freezed
abstract class AuthenticationData with _$AuthenticationData {
  /// QR code data for WalletConnect authentication
  const factory AuthenticationData.qrCode({
    required String uri,
    required Map<String, dynamic> requiredNamespaces,
    String? sessionTopic,
  }) = QRCodeData;

  /// Trezor-specific authentication data
  const factory AuthenticationData.trezor({
    required int taskId,
    String? deviceInfo,
  }) = TrezorData;

  /// WalletConnect session data
  const factory AuthenticationData.walletConnect({
    required String sessionTopic,
    Map<String, dynamic>? session,
    List<String>? supportedChains,
  }) = WalletConnectData;
}

/// General authentication status that can be used for any wallet type
enum AuthenticationStatus {
  initializing,
  waitingForDevice,
  waitingForDeviceConfirmation,
  pinRequired,
  passphraseRequired,
  authenticating,
  completed,
  error,
  cancelled,
  // WalletConnect-specific statuses
  generatingQrCode,
  waitingForConnection,
  walletConnected,
  sessionEstablished,
}
