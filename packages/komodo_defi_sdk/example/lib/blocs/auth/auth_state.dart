part of 'auth_bloc.dart';

/// Enum representing the different authentication status values
enum AuthStatus {
  /// Initial state when authentication BLoC is first created
  initial,

  /// Loading operations are in progress
  loading,

  /// User is not authenticated
  unauthenticated,

  /// User is successfully authenticated
  authenticated,

  /// Authentication operation failed
  error,

  /// Sign out is in progress
  signingOut,
}

/// Enum representing the different Trezor authentication status values
enum TrezorAuthStatus {
  /// No Trezor operation in progress
  none,

  /// Trezor initialization is in progress
  initializing,

  /// Trezor requires PIN input
  pinRequired,

  /// Trezor requires passphrase input
  passphraseRequired,

  /// Trezor is waiting for device confirmation
  awaitingConfirmation,

  /// Trezor initialization is completed and ready for auth
  ready;

  /// Factory constructor to create TrezorAuthStatus from TrezorInitializationStatus
  factory TrezorAuthStatus.fromTrezorInitializationStatus(
    TrezorInitializationStatus status,
  ) {
    switch (status) {
      case TrezorInitializationStatus.initializing:
      case TrezorInitializationStatus.waitingForDevice:
        return TrezorAuthStatus.initializing;
      case TrezorInitializationStatus.waitingForDeviceConfirmation:
        return TrezorAuthStatus.awaitingConfirmation;
      case TrezorInitializationStatus.pinRequired:
        return TrezorAuthStatus.pinRequired;
      case TrezorInitializationStatus.passphraseRequired:
        return TrezorAuthStatus.passphraseRequired;
      case TrezorInitializationStatus.completed:
        return TrezorAuthStatus.ready;
      case TrezorInitializationStatus.error:
      case TrezorInitializationStatus.cancelled:
        return TrezorAuthStatus.none;
    }
  }
}

/// Single authentication state class with status enum
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.knownUsers = const [],
    this.selectedUser,
    this.user,
    this.walletName = '',
    this.isHdMode = true,
    this.errorMessage,
    this.trezorStatus = TrezorAuthStatus.none,
    this.trezorMessage,
    this.trezorTaskId,
    this.trezorDeviceInfo,
  });

  /// Current authentication status
  final AuthStatus status;

  /// List of known users from previous sessions
  final List<KdfUser> knownUsers;

  /// Currently selected user for authentication
  final KdfUser? selectedUser;

  /// Authenticated user (only available when status is authenticated)
  final KdfUser? user;

  /// Wallet name for new wallet creation
  final String walletName;

  /// Whether HD mode is enabled
  final bool isHdMode;

  /// Error message when status is error
  final String? errorMessage;

  /// Current Trezor-specific status
  final TrezorAuthStatus trezorStatus;

  /// Trezor-specific message
  final String? trezorMessage;

  /// Task ID for Trezor operations
  final int? trezorTaskId;

  /// Trezor device information
  final dynamic trezorDeviceInfo;

  @override
  List<Object?> get props => [
    status,
    knownUsers,
    selectedUser,
    user,
    walletName,
    isHdMode,
    errorMessage,
    trezorStatus,
    trezorMessage,
    trezorTaskId,
    trezorDeviceInfo,
  ];

  /// Creates a copy of this state with the given fields replaced
  AuthState copyWith({
    AuthStatus? status,
    List<KdfUser>? knownUsers,
    KdfUser? selectedUser,
    KdfUser? user,
    String? walletName,
    bool? isHdMode,
    String? errorMessage,
    TrezorAuthStatus? trezorStatus,
    String? trezorMessage,
    int? trezorTaskId,
    dynamic trezorDeviceInfo,
    bool clearError = false,
    bool clearSelectedUser = false,
    bool clearUser = false,
    bool clearTrezorMessage = false,
    bool clearTrezorTaskId = false,
    bool clearTrezorDeviceInfo = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      knownUsers: knownUsers ?? this.knownUsers,
      selectedUser:
          clearSelectedUser ? null : (selectedUser ?? this.selectedUser),
      user: clearUser ? null : (user ?? this.user),
      walletName: walletName ?? this.walletName,
      isHdMode: isHdMode ?? this.isHdMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      trezorStatus: trezorStatus ?? this.trezorStatus,
      trezorMessage:
          clearTrezorMessage ? null : (trezorMessage ?? this.trezorMessage),
      trezorTaskId:
          clearTrezorTaskId ? null : (trezorTaskId ?? this.trezorTaskId),
      trezorDeviceInfo:
          clearTrezorDeviceInfo
              ? null
              : (trezorDeviceInfo ?? this.trezorDeviceInfo),
    );
  }

  /// Factory constructors for common state configurations

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Loading state
  factory AuthState.loading({
    List<KdfUser> knownUsers = const [],
    KdfUser? selectedUser,
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.loading,
    knownUsers: knownUsers,
    selectedUser: selectedUser,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Unauthenticated state
  factory AuthState.unauthenticated({
    List<KdfUser> knownUsers = const [],
    KdfUser? selectedUser,
    String walletName = '',
    bool isHdMode = true,
    String? errorMessage,
  }) => AuthState(
    status: AuthStatus.unauthenticated,
    knownUsers: knownUsers,
    selectedUser: selectedUser,
    walletName: walletName,
    isHdMode: isHdMode,
    errorMessage: errorMessage,
  );

  /// Authenticated state
  factory AuthState.authenticated({
    required KdfUser user,
    List<KdfUser> knownUsers = const [],
  }) => AuthState(
    status: AuthStatus.authenticated,
    user: user,
    knownUsers: knownUsers,
  );

  /// Error state
  factory AuthState.error({
    required String message,
    List<KdfUser> knownUsers = const [],
    KdfUser? selectedUser,
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.error,
    errorMessage: message,
    knownUsers: knownUsers,
    selectedUser: selectedUser,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Signing out state
  factory AuthState.signingOut() =>
      const AuthState(status: AuthStatus.signingOut);

  /// Trezor initializing state
  factory AuthState.trezorInitializing({
    String? message,
    int? taskId,
    List<KdfUser> knownUsers = const [],
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.loading,
    trezorStatus: TrezorAuthStatus.initializing,
    trezorMessage: message,
    trezorTaskId: taskId,
    knownUsers: knownUsers,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Trezor PIN required state
  factory AuthState.trezorPinRequired({
    required int taskId,
    String? message,
    List<KdfUser> knownUsers = const [],
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.loading,
    trezorStatus: TrezorAuthStatus.pinRequired,
    trezorTaskId: taskId,
    trezorMessage: message,
    knownUsers: knownUsers,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Trezor passphrase required state
  factory AuthState.trezorPassphraseRequired({
    required int taskId,
    String? message,
    List<KdfUser> knownUsers = const [],
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.loading,
    trezorStatus: TrezorAuthStatus.passphraseRequired,
    trezorTaskId: taskId,
    trezorMessage: message,
    knownUsers: knownUsers,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Trezor awaiting confirmation state
  factory AuthState.trezorAwaitingConfirmation({
    required int taskId,
    String? message,
    List<KdfUser> knownUsers = const [],
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.loading,
    trezorStatus: TrezorAuthStatus.awaitingConfirmation,
    trezorTaskId: taskId,
    trezorMessage: message,
    knownUsers: knownUsers,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Trezor ready state
  factory AuthState.trezorReady({
    required dynamic deviceInfo,
    List<KdfUser> knownUsers = const [],
    String walletName = '',
    bool isHdMode = true,
  }) => AuthState(
    status: AuthStatus.authenticated,
    trezorStatus: TrezorAuthStatus.ready,
    trezorDeviceInfo: deviceInfo,
    knownUsers: knownUsers,
    walletName: walletName,
    isHdMode: isHdMode,
  );

  /// Convenience getters for checking status
  bool get isInitial => status == AuthStatus.initial;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
  bool get isSigningOut => status == AuthStatus.signingOut;

  /// Convenience getters for checking Trezor status
  bool get isTrezorActive => trezorStatus != TrezorAuthStatus.none;
  bool get isTrezorInitializing =>
      trezorStatus == TrezorAuthStatus.initializing;
  bool get isTrezorPinRequired => trezorStatus == TrezorAuthStatus.pinRequired;
  bool get isTrezorPassphraseRequired =>
      trezorStatus == TrezorAuthStatus.passphraseRequired;
  bool get isTrezorAwaitingConfirmation =>
      trezorStatus == TrezorAuthStatus.awaitingConfirmation;
  bool get isTrezorReady => trezorStatus == TrezorAuthStatus.ready;
}
