import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/activation/shared_activation_coordinator.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_sdk/src/pubkeys/pubkey_manager.dart';
import 'package:komodo_defi_sdk/src/security/private_key_conversion_extension.dart';
import 'package:komodo_defi_sdk/src/security/private_key_export_request.dart';
import 'package:komodo_defi_sdk/src/security/tron_export_key.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A capability tied to a verified wallet and authentication transition.
/// Retain it across confirmation and save dialogs, checking before disclosure.
class PrivateKeyExportSession {
  const PrivateKeyExportSession._(this.walletId, this.generation, this._owner);

  final Object _owner;

  /// Verified wallet selected when the operation began.
  final WalletId walletId;

  /// Source-owned epoch; also changes on same-wallet reauthentication.
  final int generation;

  @override
  String toString() => 'PrivateKeyExportSession(redacted)';
}

/// Recovery operations bound to the authoritative authentication generation.
class SecurityManager {
  /// Creates recovery operations; cached pubkeys supply account hints only.
  SecurityManager(
    this._client,
    this._auth,
    this._assetProvider,
    this._activationCoordinator, {
    IPubkeyManager? pubkeyManager,
  }) : _pubkeyManager = pubkeyManager;

  final ApiClient _client;
  final KomodoDefiLocalAuth _auth;
  final IAssetProvider _assetProvider;
  final SharedActivationCoordinator _activationCoordinator;
  final IPubkeyManager? _pubkeyManager;
  final Object _sessionOwner = Object();
  bool _disposed = false;

  /// Captures an authenticated wallet with a verified public identity.
  Future<PrivateKeyExportSession> captureExportSession() async {
    if (_disposed || _auth.isAuthTransitionInProgress) {
      throw const PrivateKeyExportSessionChangedException();
    }
    final generation = _auth.authGeneration;
    final user = await _auth.currentUser;
    if (generation != _auth.authGeneration ||
        _auth.isAuthTransitionInProgress) {
      throw const PrivateKeyExportSessionChangedException();
    }
    if (user == null) throw AuthException.notSignedIn();
    if (user.walletId.pubkeyHash?.trim().isNotEmpty != true) {
      throw const PrivateKeyExportSessionChangedException();
    }
    return PrivateKeyExportSession._(user.walletId, generation, _sessionOwner);
  }

  /// Rejects intervening sign-outs, restarts, or verified identity changes.
  Future<void> ensureExportSessionCurrent(
    PrivateKeyExportSession session,
  ) async {
    _checkGeneration(session);
    final user = await _auth.currentUser;
    _checkGeneration(session);
    final identity = user?.walletId.pubkeyHash?.trim().toLowerCase();
    if (user == null ||
        identity == null ||
        identity.isEmpty ||
        identity != session.walletId.pubkeyHash?.trim().toLowerCase() ||
        user.walletId.authOptions != session.walletId.authOptions) {
      throw const PrivateKeyExportSessionChangedException();
    }
  }

  void _checkGeneration(PrivateKeyExportSession session) {
    if (!identical(session._owner, _sessionOwner) ||
        _disposed ||
        _auth.authGeneration != session.generation ||
        _auth.isAuthTransitionInProgress) {
      throw const PrivateKeyExportSessionChangedException();
    }
  }

  /// Final synchronous disclosure guard after fresh asynchronous verification.
  /// Call immediately before clipboard, file-write, or share handoff, with no
  /// intervening await; this closes the caller's final continuation race.
  void ensureExportSessionCurrentSync(PrivateKeyExportSession session) {
    _checkGeneration(session);
  }

  Future<T> _guarded<T>(
    PrivateKeyExportSession session,
    Future<T> Function() operation,
  ) async {
    await ensureExportSessionCurrent(session);
    try {
      return await operation();
    } finally {
      // Failures also invalidate the entire export if the session changed.
      await ensureExportSessionCurrent(session);
      _checkGeneration(session);
    }
  }

  Future<List<AssetId>> _targets(
    List<AssetId>? explicit,
    PrivateKeyExportSession session,
  ) async {
    if (explicit != null) return explicit.toSet().toList();
    final activated = await _guarded(
      session,
      _assetProvider.getActivatedAssets,
    );
    return {
      ...activated.map((asset) => asset.id),
      ..._activationCoordinator.activationStates.keys,
    }.toList();
  }

  KeyExportMode _validate(
    PrivateKeyExportRequest request,
    PrivateKeyExportSession session,
  ) {
    final mode =
        request.mode ??
        (session.walletId.isHd ? KeyExportMode.hd : KeyExportMode.iguana);
    if (mode == KeyExportMode.iguana && request.hasExplicitRange) {
      throw ArgumentError('Address ranges require HD export mode');
    }
    final start = request.startIndex ?? 0;
    final end = request.endIndex ?? start + 10;
    if (start < 0 ||
        end > 0x7fffffff ||
        (request.accountIndex ?? 0) > 0x7fffffff ||
        end < start ||
        end - start > 100 ||
        (request.accountIndex ?? 0) < 0) {
      throw ArgumentError('Invalid private key export range');
    }
    return mode;
  }

  /// Strict offline compatibility API. Failures remain failures; no online
  /// single-key substitution or silent omission of unsupported assets occurs.
  Future<Map<AssetId, List<PrivateKey>>> getPrivateKeys({
    List<AssetId>? assets,
    KeyExportMode? mode,
    int? startIndex,
    int? endIndex,
    int? accountIndex,
  }) async {
    final selectedAssets = assets?.toList(growable: false);
    final session = await captureExportSession();
    final request = PrivateKeyExportRequest(
      assets: assets,
      mode: mode,
      startIndex: startIndex,
      endIndex: endIndex,
      accountIndex: accountIndex,
    );
    final resolvedMode = _validate(request, session);
    final targets = await _targets(selectedAssets, session);
    if (targets.isEmpty) return {};
    final response = await _guarded(
      session,
      () => _client.rpc.wallet.getPrivateKeys(
        coins: targets.map((asset) => asset.id).toList(),
        mode: resolvedMode,
        startIndex: startIndex,
        endIndex: endIndex,
        accountIndex: accountIndex,
      ),
    );
    final result = response.toPrivateKeyInfoMap({
      for (final asset in targets) asset.id: asset,
    });
    if ((response.isHdResponse != (resolvedMode == KeyExportMode.hd)) ||
        (response.hdKeys?.length ?? response.standardKeys?.length) !=
            targets.length ||
        result.length != targets.length ||
        targets.any((asset) => result[asset]?.isNotEmpty != true)) {
      throw const FormatException('Incomplete private key export response');
    }
    await ensureExportSessionCurrent(session);
    _checkGeneration(session);
    return result;
  }

  /// Strict offline convenience wrapper for one asset.
  Future<Map<AssetId, List<PrivateKey>>> getPrivateKey(
    AssetId asset, {
    KeyExportMode? mode,
    int? startIndex,
    int? endIndex,
    int? accountIndex,
  }) => getPrivateKeys(
    assets: [asset],
    mode: mode,
    startIndex: startIndex,
    endIndex: endIndex,
    accountIndex: accountIndex,
  );

  /// Reports unsupported assets individually and explicitly labels the narrow
  /// coverage of an activated TRON signing key. Never activates an asset.
  Future<PrivateKeyExportResult> exportPrivateKeys({
    PrivateKeyExportRequest request = const PrivateKeyExportRequest(),
    PrivateKeyExportSession? session,
  }) async {
    final selectedAssets = request.assets?.toList(growable: false);
    final context = session ?? await captureExportSession();
    await ensureExportSessionCurrent(context);
    final mode = _validate(request, context);
    final targets = await _targets(selectedAssets, context);
    final outcomes = List<PrivateKeyExportOutcome?>.filled(
      targets.length,
      null,
    );
    final tron = <Asset, Future<PrivateKeyExportOutcome>>{};
    var next = 0;
    Future<void> worker() async {
      while (next < targets.length) {
        _checkGeneration(context);
        final index = next++;
        final id = targets[index];
        final asset = _assetProvider.fromId(id);
        if (asset == null) {
          outcomes[index] = _unavailable(
            id,
            PrivateKeyExportFailure.assetUnavailable,
          );
        } else if (asset.protocol is TrxProtocol ||
            asset.protocol is Trc20Protocol) {
          outcomes[index] = await _tronAsset(
            asset,
            request,
            mode,
            context,
            tron,
          );
        } else {
          outcomes[index] = await _offline(asset, request, mode, context);
        }
      }
    }

    // Bounds the expensive offline derivation RPCs to two concurrent calls.
    await Future.wait([worker(), worker()]);
    await ensureExportSessionCurrent(context);
    _checkGeneration(context);
    return PrivateKeyExportResult(
      outcomes: outcomes.cast<PrivateKeyExportOutcome>(),
    );
  }

  PrivateKeyExportOutcome _unavailable(
    AssetId id,
    PrivateKeyExportFailure failure, [
    AssetId? signingId,
  ]) => PrivateKeyExportOutcome.unavailable(
    assetId: id,
    signingAssetId: signingId,
    failure: failure,
  );

  Future<PrivateKeyExportOutcome> _offline(
    Asset asset,
    PrivateKeyExportRequest request,
    KeyExportMode mode,
    PrivateKeyExportSession session,
  ) async {
    if (asset.id.subClass == CoinSubClass.sia) {
      return _unavailable(
        asset.id,
        PrivateKeyExportFailure.unsupportedProtocol,
      );
    }
    try {
      final response = await _guarded(
        session,
        () => _client.rpc.wallet.getPrivateKeys(
          coins: [asset.id.id],
          mode: mode,
          startIndex: request.startIndex,
          endIndex: request.endIndex,
          accountIndex: request.accountIndex,
        ),
      );
      final keys = response.toPrivateKeyInfoMap({
        asset.id.id: asset.id,
      })[asset.id];
      final shielded = asset.protocol is ZhtlcProtocol;
      if (keys == null ||
          keys.isEmpty ||
          keys.any(
            (key) =>
                key.privateKey.isEmpty ||
                key.publicKeyAddress.isEmpty ||
                (!shielded && key.publicKeySecp256k1.isEmpty),
          ) ||
          (mode == KeyExportMode.hd) != response.isHdResponse) {
        return _unavailable(asset.id, PrivateKeyExportFailure.invalidResponse);
      }
      final start = request.startIndex ?? 0;
      final end = request.endIndex ?? start + 10;
      final account = request.accountIndex ?? 0;
      if (mode == KeyExportMode.hd) {
        final basePath = _configuredPath(asset);
        final expectedPaths = shielded
            ? {"$basePath/$account'"}
            : {
                for (var index = start; index <= end; index++)
                  "$basePath/$account'/0/$index",
              };
        if (keys.length != expectedPaths.length ||
            keys.map((key) => key.hdInfo?.derivationPath).toSet().length !=
                expectedPaths.length ||
            keys
                .map((key) => key.hdInfo?.derivationPath)
                .toSet()
                .difference(expectedPaths)
                .isNotEmpty) {
          return _unavailable(
            asset.id,
            PrivateKeyExportFailure.invalidResponse,
          );
        }
      } else if (keys.length != 1) {
        return _unavailable(asset.id, PrivateKeyExportFailure.invalidResponse);
      }
      return PrivateKeyExportOutcome.success(
        assetId: asset.id,
        signingAssetId: asset.id,
        keys: keys,
        coverage: PrivateKeyExportCoverage(
          kind: mode == KeyExportMode.hd
              ? shielded
                    ? PrivateKeyExportCoverageKind.offlineAccount
                    : PrivateKeyExportCoverageKind.offlineHdRange
              : PrivateKeyExportCoverageKind.legacyWallet,
          accountIndex: mode == KeyExportMode.hd
              ? request.accountIndex ?? 0
              : null,
          derivationPath: shielded ? keys.single.hdInfo?.derivationPath : null,
          chain: mode == KeyExportMode.hd && !shielded ? 'External' : null,
          startIndex: mode == KeyExportMode.hd && !shielded
              ? request.startIndex ?? 0
              : null,
          endIndex: mode == KeyExportMode.hd && !shielded
              ? request.endIndex ?? (request.startIndex ?? 0) + 10
              : null,
        ),
      );
    } on PrivateKeyExportSessionChangedException {
      rethrow;
    } on FormatException {
      return _unavailable(asset.id, PrivateKeyExportFailure.invalidResponse);
    } on Object {
      return _unavailable(asset.id, PrivateKeyExportFailure.rpcFailed);
    }
  }

  Asset? _tronPlatform(Asset asset) {
    if (asset.protocol is TrxProtocol) return asset;
    final protocol = asset.protocol as Trc20Protocol;
    final candidates = _assetProvider.findAssetsByConfigId(protocol.platform);
    if (candidates.length != 1) return null;
    final parent = candidates.single;
    if (parent.protocol is! TrxProtocol ||
        (asset.id.parentId != null && asset.id.parentId != parent.id)) {
      return null;
    }
    return parent;
  }

  String? _configuredPath(Asset asset) {
    final path = asset.protocol.config['derivation_path'];
    return path is String ? path : asset.id.derivationPath;
  }

  Future<Set<String>> _enabled(PrivateKeyExportSession session) async =>
      (await _guarded(
        session,
        () => _client.post(GetEnabledCoinsRequest()),
      )).result.map((coin) => coin.ticker).toSet();

  // KDF can omit TRX while listing an enabled TRC20 token. After _tronPlatform
  // validates the parent, the requested token proves platform availability.
  bool _tronPlatformEnabled(Asset asset, Asset parent, Set<String> enabled) =>
      enabled.contains(parent.id.id) ||
      (asset.protocol is Trc20Protocol && enabled.contains(asset.id.id));

  Future<PrivateKeyExportOutcome> _tronAsset(
    Asset asset,
    PrivateKeyExportRequest request,
    KeyExportMode mode,
    PrivateKeyExportSession session,
    Map<Asset, Future<PrivateKeyExportOutcome>> shared,
  ) async {
    if (!request.allowTronActiveKey ||
        request.hasExplicitRange ||
        mode !=
            (session.walletId.isHd ? KeyExportMode.hd : KeyExportMode.iguana)) {
      return _unavailable(
        asset.id,
        PrivateKeyExportFailure.requestedCoverageUnavailable,
      );
    }
    final parent = _tronPlatform(asset);
    if (parent == null ||
        !{
          'Mainnet',
          'Nile',
          'Shasta',
        }.contains((parent.protocol as TrxProtocol).network)) {
      return _unavailable(asset.id, PrivateKeyExportFailure.invalidPlatform);
    }
    for (final id in {asset.id, parent.id}) {
      final state = _activationCoordinator.activationStates[id];
      if (state?.isActivating ?? false) {
        return _unavailable(
          asset.id,
          PrivateKeyExportFailure.activationPending,
          parent.id,
        );
      }
      if (state?.isFailed ?? false) {
        return _unavailable(
          asset.id,
          PrivateKeyExportFailure.activationFailed,
          parent.id,
        );
      }
    }
    try {
      final enabled = await _enabled(session);
      if (!_tronPlatformEnabled(asset, parent, enabled)) {
        return _unavailable(
          asset.id,
          PrivateKeyExportFailure.platformNotEnabled,
          parent.id,
        );
      }
      if (!enabled.contains(asset.id.id)) {
        return _unavailable(
          asset.id,
          PrivateKeyExportFailure.assetUnavailable,
          parent.id,
        );
      }
      final result = await shared.putIfAbsent(
        parent,
        () => _tronKey(parent, session),
      );
      await ensureExportSessionCurrent(session);
      final stillEnabled = await _enabled(session);
      if (!_tronPlatformEnabled(asset, parent, stillEnabled) ||
          !stillEnabled.contains(asset.id.id)) {
        return _unavailable(
          asset.id,
          PrivateKeyExportFailure.assetUnavailable,
          parent.id,
        );
      }
      if (!result.isSuccess) {
        return _unavailable(asset.id, result.failure!, parent.id);
      }
      return PrivateKeyExportOutcome.success(
        assetId: asset.id,
        signingAssetId: parent.id,
        keys: result.keys
            .map(
              (key) => PrivateKey(
                assetId: asset.id,
                publicKeySecp256k1: key.publicKeySecp256k1,
                publicKeyAddress: key.publicKeyAddress,
                privateKey: key.privateKey,
                hdInfo: key.hdInfo,
              ),
            )
            .toList(),
        coverage: result.coverage!,
      );
    } on PrivateKeyExportSessionChangedException {
      rethrow;
    } on Object {
      return _unavailable(
        asset.id,
        PrivateKeyExportFailure.rpcFailed,
        parent.id,
      );
    }
  }

  Future<PrivateKeyExportOutcome> _tronKey(
    Asset parent,
    PrivateKeyExportSession session,
  ) async {
    try {
      final response = await _guarded(
        session,
        () => _client.rpc.wallet.showPrivKey(parent.id.id),
      );
      if (response.coin != parent.id.id) {
        return _unavailable(parent.id, PrivateKeyExportFailure.invalidResponse);
      }
      final key = TronExportKey.parse(response.privKey);
      ExportAddressMetadata? metadata;
      if (session.walletId.isHd) {
        metadata = await _findTronMetadata(parent, key.address, session);
        if (metadata == null) {
          return _unavailable(
            parent.id,
            PrivateKeyExportFailure.metadataUnverified,
          );
        }
      } else {
        final balance = await _guarded(
          session,
          () => _client.post(MyBalanceRequest(rpcPass: '', coin: parent.id.id)),
        );
        if (balance.coin != parent.id.id || balance.address != key.address) {
          return _unavailable(
            parent.id,
            PrivateKeyExportFailure.metadataUnverified,
          );
        }
      }
      return PrivateKeyExportOutcome.success(
        assetId: parent.id,
        signingAssetId: parent.id,
        keys: [
          PrivateKey(
            assetId: parent.id,
            publicKeySecp256k1: key.publicKey,
            publicKeyAddress: key.address,
            privateKey: key.privateKey,
            hdInfo: metadata == null
                ? null
                : PrivateKeyHdInfo(derivationPath: metadata.derivationPath),
          ),
        ],
        coverage: PrivateKeyExportCoverage(
          kind: PrivateKeyExportCoverageKind.activeAddressOnly,
          chain: metadata?.chain,
          derivationPath: metadata?.derivationPath,
          accountIndex: metadata == null
              ? null
              : _pathParts(metadata.derivationPath)?[2],
        ),
      );
    } on PrivateKeyExportSessionChangedException {
      rethrow;
    } on FormatException {
      return _unavailable(parent.id, PrivateKeyExportFailure.invalidResponse);
    } on Object {
      return _unavailable(
        parent.id,
        PrivateKeyExportFailure.metadataUnverified,
      );
    }
  }

  List<int>? _pathParts(String path) {
    final match = RegExp(
      r"^m/(\d+)'/(\d+)'/(\d+)'/([01])/(\d+)$",
    ).firstMatch(path);
    if (match == null) return null;
    return [for (var i = 1; i <= 5; i++) int.parse(match.group(i)!)];
  }

  Future<ExportAddressMetadata?> _findTronMetadata(
    Asset parent,
    String address,
    PrivateKeyExportSession session,
  ) async {
    final basePath = _configuredPath(parent);
    if (basePath == null) return null;
    // Cached data supplies account IDs only. It can never authenticate a key.
    final accounts = <int>{0};
    for (final key
        in _pubkeyManager?.lastKnown(parent.id)?.keys ?? <PubkeyInfo>[]) {
      final path = key.derivationPath;
      final parts = path == null ? null : _pathParts(path);
      if (parts != null) accounts.add(parts[2]);
    }
    if (accounts.length > 32) return null;
    var remainingPages = 64;
    for (final account in accounts) {
      for (final chain in ['External', 'Internal']) {
        for (var page = 1; page <= 100; page++) {
          if (remainingPages-- == 0) return null;
          AccountBalanceReadResponse response;
          try {
            response = await _guarded(
              session,
              () => _client.post(
                AccountBalanceReadRequest(
                  coin: parent.id.id,
                  accountIndex: account,
                  chain: chain,
                  page: page,
                ),
              ),
            );
          } on PrivateKeyExportSessionChangedException {
            rethrow;
          } on Object {
            break;
          }
          if (response.accountIndex != account ||
              response.totalPages < 0 ||
              response.totalPages > 100 ||
              response.addresses.length > 100) {
            return null;
          }
          for (final candidate in response.addresses) {
            if (candidate.address != address) continue;
            final path = _pathParts(candidate.derivationPath);
            if (path == null ||
                path[2] != account ||
                path[3] != (chain == 'External' ? 0 : 1) ||
                candidate.chain != chain ||
                !candidate.derivationPath.startsWith('$basePath/')) {
              return null;
            }
            return candidate;
          }
          if (page >= response.totalPages) break;
        }
      }
    }
    return null;
  }

  /// Releases this manager; it owns no persistent secret cache.
  Future<void> dispose() async {
    _disposed = true;
  }
}
