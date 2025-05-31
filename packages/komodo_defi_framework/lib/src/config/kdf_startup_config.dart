// Imports
// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_framework/src/config/seed_node_validator.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class KdfStartupConfig {
  KdfStartupConfig._({
    required this.walletName,
    required this.walletPassword,
    required this.rpcPassword,
    required this.coins,
    required this.allowWeakPassword,
    required this.netid,
    required this.gui,
    required this.https,
    required this.seed,
    required this.dbDir,
    required this.userHome,
    required this.rpcIp,
    required this.rpcPort,
    required this.rpcLocalOnly,
    required this.hdAccountId,
    required this.allowRegistrations,
    required this.enableHd,
    required this.seedNodes,
    required this.disableP2p,
    required this.iAmSeed,
    required this.isBootstrapNode,
  }) {
    SeedNodeValidator.validate(
      seedNodes: seedNodes,
      disableP2p: disableP2p,
      iAmSeed: iAmSeed,
      isBootstrapNode: isBootstrapNode,
    );
  }

  final String? walletName;
  final String? walletPassword;
  final String? seed;
  final String rpcPassword;
  final String? dbDir;
  final String? userHome;
  final String? rpcIp;
  final int? rpcPort;
  final bool? rpcLocalOnly;
  final bool allowWeakPassword;
  final int netid;
  final int? hdAccountId;
  final String gui;
  final bool https;
  final bool allowRegistrations;
  final bool? enableHd;
  final List<String>? seedNodes;
  final bool? disableP2p;
  final bool? iAmSeed;
  final bool? isBootstrapNode;

  // Either a list of coin JSON objects or a string of the path to a file
  // containing a list of coin JSON objects.
  final dynamic coins;

  static Future<KdfStartupConfig> generateWithDefaults({
    required String walletName,
    required String walletPassword,
    required bool? enableHd,
    String? rpcPassword,
    String? coinsPath,
    String? seed,
    String? dbDir,
    String? userHome,
    String? rpcIp,
    int? hdAccountId,
    bool allowWeakPassword = false,
    int rpcPort = 7783,
    int netid = 8762,
    String gui = 'komodo-defi-flutter-auth',
    bool https = false,
    bool rpcLocalOnly = true,
    bool allowRegistrations = true,
    List<String>? seedNodes,
    bool? disableP2p,
    bool? iAmSeed,
    bool? isBootstrapNode,
  }) async {
    assert(
      !kIsWeb || userHome == null && dbDir == null,
      'Web does not support userHome or dbDir',
    );
    assert(
      [walletName, walletPassword].every((e) => e.isNotEmpty),
      'Wallet name and password must not be empty',
    );

    final (String? userHomePath, String? dbPath) = await _getAndSetupUserHome(
      userHome: userHome,
      dbHome: dbDir,
    );

    assert(
        hdAccountId == null,
        'HD Account ID is not supported yet in the SDK. '
        'Use at your own risk.');

    // Determine final seed nodes configuration
    // If P2P is disabled, no need for seed nodes
    // Otherwise, use provided nodes or default ones
    final finalSeedNodes = disableP2p == true
        ? null // Don't provide seed nodes if P2P is disabled
        : (seedNodes ?? SeedNodeValidator.getDefaultSeedNodes());

    // Validate seed node configuration here before creating the object
    SeedNodeValidator.validate(
      seedNodes: finalSeedNodes,
      disableP2p: disableP2p,
      iAmSeed: iAmSeed,
      isBootstrapNode: isBootstrapNode,
    );

    return KdfStartupConfig._(
      walletName: walletName,
      walletPassword: walletPassword,
      rpcPassword: rpcPassword ?? SecurityUtils.generatePasswordSecure(32),
      seed: seed,
      dbDir: dbPath,
      userHome: userHomePath,
      allowWeakPassword: allowWeakPassword,
      netid: netid,
      gui: gui,
      coins: coinsPath ?? await _fetchCoinsData(),
      https: https,
      seedNodes: finalSeedNodes,
      disableP2p: disableP2p,
      iAmSeed: iAmSeed,
      isBootstrapNode: isBootstrapNode,
      rpcIp: rpcIp,
      rpcPort: rpcPort,
      rpcLocalOnly: rpcLocalOnly,
      hdAccountId: hdAccountId,
      allowRegistrations: allowRegistrations,
      enableHd: enableHd,
    );
  }

  static Future<(String? home, String? dbDir)> _getAndSetupUserHome({
    String? userHome,
    String? dbHome,
  }) async {
    if (kIsWeb) return (null, null);

    final home = userHome ?? (await getApplicationDocumentsDirectory()).path;
    final dbDir = dbHome ?? path.join(home, '.kdf');

    // ignore: avoid_slow_async_io
    if (!await Directory(dbDir).exists()) {
      await Directory(dbDir).create(recursive: true);
    }

    return (home, dbDir);
  }

  static Future<KdfStartupConfig> noAuthStartup({
    String? rpcPassword,
    String? rpcIp,
    int rpcPort = 7783,
  }) async {
    final (String? home, String? dbDir) = await _getAndSetupUserHome();

    return KdfStartupConfig._(
      walletName: null,
      walletPassword: null,
      seed: null,
      rpcPassword: rpcPassword ?? SecurityUtils.generatePasswordSecure(32),
      userHome: home,
      dbDir: dbDir,
      allowWeakPassword: true,
      netid: 8762,
      gui: 'komodo-defi-flutter-auth',
      coins: await _fetchCoinsData(),
      https: false,
      rpcIp: rpcIp,
      rpcPort: rpcPort,
      rpcLocalOnly: true,
      hdAccountId: null,
      allowRegistrations: false,
      enableHd: false,
      disableP2p: true,
      seedNodes: [],
      iAmSeed: false,
      isBootstrapNode: false,
    );
  }

  JsonMap encodeStartParams() {
    return {
      'mm2': 1,
      'allow_weak_password': allowWeakPassword,
      'rpc_password': rpcPassword,
      'netid': netid,
      'gui': gui,
      if (walletPassword?.isNotEmpty ?? false)
        'wallet_password': walletPassword,
      if (walletName?.isNotEmpty ?? false) 'wallet_name': walletName,
      if (seed?.isNotEmpty ?? false) 'passphrase': seed,
      if (dbDir != null) 'dbdir': dbDir,
      if (userHome != null) 'userhome': userHome,
      if (rpcIp != null) 'rpcip': rpcIp,
      if (rpcPort != null) 'rpcport': rpcPort,
      if (rpcLocalOnly != null) 'rpc_local_only': rpcLocalOnly,
      'allow_registrations': allowRegistrations,
      if (enableHd != null) 'enable_hd': enableHd,
      if (hdAccountId != null) 'hd_account_id': hdAccountId,
      'https': https,
      'coins': coins,
      'trading_proto_v2': true,
      if (seedNodes != null && seedNodes!.isNotEmpty) 'seednodes': seedNodes,
      if (disableP2p != null) 'disable_p2p': disableP2p,
      if (iAmSeed != null) 'i_am_seed': iAmSeed,
      if (isBootstrapNode != null) 'is_bootstrap_node': isBootstrapNode,
    };
  }

  static JsonList? _memoizedCoins;

  static Future<JsonList> _fetchCoinsData() async {
    if (_memoizedCoins != null) return _memoizedCoins!;

    return _memoizedCoins = await KomodoCoins.fetchAndTransformCoinsList();

  }
}
