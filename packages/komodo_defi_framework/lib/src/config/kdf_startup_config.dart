// Imports
// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
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
  });

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
  }) async {
    assert(
      !kIsWeb || userHome == null && dbDir == null,
      'Web does not support userHome or dbDir',
    );
    assert(
      [walletName, walletPassword].every((e) => e.isNotEmpty),
      'Wallet name and password must not be empty',
    );
    final home = userHome ?? await _getAndSetupUserHome();

    assert(hdAccountId == null, 'HD Account ID is not supported yet.');

    return KdfStartupConfig._(
      walletName: walletName,
      walletPassword: walletPassword,
      rpcPassword: rpcPassword ?? generatePassword(),
      seed: seed,
      dbDir: dbDir ?? home,
      userHome: home,
      allowWeakPassword: allowWeakPassword,
      netid: netid,
      gui: gui,
      coins: coinsPath ?? await _fetchCoinsData(),
      https: https,
      rpcIp: rpcIp,
      rpcPort: rpcPort,
      rpcLocalOnly: rpcLocalOnly,
      hdAccountId: hdAccountId,
      allowRegistrations: allowRegistrations,
      enableHd: enableHd,
    );
  }

  static Future<String?> _getAndSetupUserHome() async {
    final home =
        (kIsWeb ? null : (await getApplicationDocumentsDirectory()).path);

    if (home != null && !Directory(home).existsSync()) {
      Directory(home).createSync(recursive: true);
    }
    return home;
  }

  static Future<KdfStartupConfig> noAuthStartup({
    String? rpcPassword,
    String? rpcIp,
    int rpcPort = 7783,
  }) async {
    final home = await _getAndSetupUserHome();
    return KdfStartupConfig._(
      walletName: null,
      walletPassword: null,
      seed: null,
      rpcPassword: rpcPassword ?? generatePassword(),
      userHome: home,
      dbDir: home,
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
    };
  }

  // static Future<KdfStartupConfig> noAuthConfig()

  // Map<String, dynamic> toJson() => {
  //       'wallet_name': walletName,
  //       'wallet_password': walletPassword,
  //       'rpc_password': rpcPassword,
  //       if (dbDir != null) 'dbdir': dbDir,
  //       if (userHome != null) 'userhome': userHome,
  //       'allow_weak_password': allowWeakPassword,
  //       'netid': netid,
  //       'gui': gui,
  //       'mm2': 1,
  //     };

  static const coinsUrl = 'https://komodoplatform.github.io/coins/coins';

  static Future<JsonList> _fetchCoinsData() async {
    if (_memoizedCoins != null) return _memoizedCoins!;

    return _memoizedCoins =
        jsonListFromString((await http.get(Uri.parse(coinsUrl))).body);

    // TODO: Implement getting from local asset as a fallback
    // final coinsDataAssetOrEmpty = await rootBundle
    //     .loadString('assets/config/coins.json')
    //     .catchError((_) => '');

    // return coinsDataAssetOrEmpty.isNotEmpty
    //     ? ListExtensions.fromJsonString(coinsDataAssetOrEmpty).toJsonString()
    //     : (await http.get(Uri.parse(coinsUrl))).body;
  }

  static JsonList? _memoizedCoins;

  static String generatePassword() {
    var result = '';
    while (!_validateRPCPassword(result)) {
      result = SecurityUtils.generatePasswordSecure(32);
    }
    return result;
  }

  static bool _validateRPCPassword(String src) {
    final exp =
        RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,32}$');
    if (!exp.hasMatch(src)) return false;
    if (RegExp(r'(.)\1\1').hasMatch(src)) return false;
    return true;
  }
}
