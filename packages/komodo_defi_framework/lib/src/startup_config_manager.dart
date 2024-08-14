import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_framework/src/extensions/http_extensions.dart';
import 'package:komodo_defi_framework/src/extensions/map_extension.dart';
import 'package:path_provider/path_provider.dart';

// TODO: Future refactoring to minimize time that seed is in memory
abstract class IKdfStartupConfig {
  Future<JsonMap> generateStartParamsFromDefault(
    String seed, {
    required String userpass,
  });
}

// TODO: Refactor so that separate implementation for web vs native?
class StartupConfigManager implements IKdfStartupConfig {
  static const String coinsUrl =
      // 'https://komodoplatform.github.io/coins/utils/coins_config.json';
      'https://komodoplatform.github.io/coins/coins';

  @override
  Future<JsonMap> generateStartParamsFromDefault(
    String seed, {
    required String userpass,
  }) async {
    final homeDir = kIsWeb ? null : await getApplicationDocumentsDirectory();
    final userHome = homeDir?.path;
    final dbDir = userHome;
    // userpass ??= generatePassword();

    return generateStartParams(
      'GUI_FFI',
      seed,
      userHome,
      dbDir,
      rpcPassword: userpass,
    );
  }

  Future<JsonMap> generateStartParams(
    String gui,
    String passphrase,
    String? userHome,
    String? dbDir, {
    required String rpcPassword,
  }) async {
    final coinsData = await fetchCoinsData();

    if (coinsData.isEmpty) {
      throw Exception('Failed to fetch coins data.');
    }

    final startParams = {
      'mm2': 1,
      'allow_weak_password': false,
      'rpc_password': rpcPassword,
      'netid': 8762,
      'gui': gui,
      if (!kIsWeb) 'https': true,
      if (userHome != null) 'userhome': userHome,
      if (dbDir != null) 'dbdir': dbDir,
      'passphrase': passphrase,
      'coins': json.decode(coinsData),
    };

    return startParams;
  }

  Future<String> fetchCoinsData() async =>
      (await http.Client().getJsonList(coinsUrl)).toJsonString();

  static String generatePassword() {
    const lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digit = '0123456789';
    const punctuation = r"*.!@#$%^(){}:;',.?/~`_+-=|";
    final stringSets = <String>[lowerCase, upperCase, digit, punctuation];

    final rng = Random.secure();
    final length =
        rng.nextInt(24) + 8; // Password length between 8 and 32 characters

    final password = List<int>.filled(length, 0);
    final setCounts = List<int>.filled(4, 0);

    for (var i = 0; i < length; i++) {
      final set = rng.nextInt(4);
      setCounts[set]++;
      password[i] =
          stringSets[set].codeUnitAt(rng.nextInt(stringSets[set].length));
    }

    // Ensure each character set is used at least once
    for (var i = 0; i < setCounts.length; i++) {
      if (setCounts[i] == 0) {
        final pos = rng.nextInt(length);
        password[pos] =
            stringSets[i].codeUnitAt(rng.nextInt(stringSets[i].length));
      }
    }

    final result = String.fromCharCodes(password);

    if (!validateRPCPassword(result)) {
      return generatePassword();
    }

    return result;
  }

  static bool validateRPCPassword(String src) {
    if (src.isEmpty) return false;

    // Password can't contain the word 'password'
    if (src.toLowerCase().contains('password')) return false;

    // Password must contain one digit, one lowercase letter, one uppercase letter,
    // one special character and its length must be between 8 and 32 characters
    final exp =
        RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,32}$');
    if (!exp.hasMatch(src)) return false;

    // Password can't contain the same character three times in a row
    for (var i = 0; i < src.length - 2; i++) {
      if (src[i] == src[i + 1] && src[i + 1] == src[i + 2]) return false;
    }

    return true;
  }
}
