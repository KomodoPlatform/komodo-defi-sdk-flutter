// Imports
// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_types.dart';
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
    required this.rpcLocalOnly,
    required this.hdAccountId,
  });

  final String walletName;
  final String walletPassword;
  final String? seed;
  final String rpcPassword;
  final String? dbDir;
  final String? userHome;
  final String? rpcIp;
  final bool? rpcLocalOnly;
  final bool allowWeakPassword;
  final int netid;
  final int? hdAccountId;
  final String gui;
  final bool https;

  // Either a list of coin JSON objects or a string of the path to a file
  // containing a list of coin JSON objects.
  final dynamic coins;

  static Future<KdfStartupConfig> generateWithDefaults({
    required String walletName,
    required String walletPassword,
    String? rpcPassword,
    String? coinsPath,
    String? seed,
    String? dbDir,
    String? userHome,
    String? rpcIp,
    int? hdAccountId,
    bool allowWeakPassword = false,
    int netid = 8762,
    String gui = 'komodo-defi-flutter-auth',
    bool https = false,
    bool rpcLocalOnly = true,
  }) async {
    assert(
      !kIsWeb || userHome == null && dbDir == null,
      'Web does not support userHome or dbDir',
    );
    final home = userHome ??
        (kIsWeb ? null : (await getApplicationDocumentsDirectory()).path);

    if (userHome != null && !Directory(userHome).existsSync()) {
      Directory(userHome).createSync(recursive: true);
    }

    return KdfStartupConfig._(
      walletName: walletName,
      walletPassword: walletPassword,
      rpcPassword: rpcPassword ?? generatePassword(),
      seed: seed,
      dbDir: dbDir,
      userHome: home,
      allowWeakPassword: allowWeakPassword,
      netid: netid,
      gui: gui,
      coins: coinsPath ?? await _fetchCoinsData(),
      https: https,
      rpcIp: rpcIp,
      rpcLocalOnly: rpcLocalOnly,
      hdAccountId: hdAccountId,
    );
  }

  JsonMap encodeStartParams() {
    return {
      'mm2': 1,
      'allow_weak_password': allowWeakPassword,
      'rpc_password': rpcPassword,
      'netid': netid,
      'gui': gui,
      if (walletPassword.isNotEmpty) 'wallet_password': walletPassword,
      if (walletName.isNotEmpty) 'wallet_name': walletName,
      if (seed?.isNotEmpty ?? false) 'passphrase': seed,
      if (dbDir != null) 'dbdir': dbDir,
      if (userHome != null) 'userhome': userHome,
      if (rpcIp != null) 'rpcip': rpcIp,
      if (rpcLocalOnly != null) 'rpc_local_only': rpcLocalOnly,
      if (hdAccountId != null) 'hd_account_id': hdAccountId,
      'https': https,
      'coins': coins,
    };
  }

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
    return jsonListFromString((await http.get(Uri.parse(coinsUrl))).body);

    // final coinsDataAssetOrEmpty = await rootBundle
    //     .loadString('assets/config/coins.json')
    //     .catchError((_) => '');

    // return coinsDataAssetOrEmpty.isNotEmpty
    //     ? ListExtensions.fromJsonString(coinsDataAssetOrEmpty).toJsonString()
    //     : (await http.get(Uri.parse(coinsUrl))).body;
  }

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
