import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_framework/src/extensions/http_extensions.dart';
import 'package:komodo_defi_framework/src/extensions/map_extension.dart';
import 'package:path_provider/path_provider.dart';

// TODO: Future refactoring to minimize time that seed is in memory
abstract class IConfigManager {
  Future<JsonMap> generateStartParamsFromDefault(String seed);
}

// TODO: Refactor so that separate implementation for web vs native?
class StartupConfigManager implements IConfigManager {
  static const String coinsUrl =
      // 'https://komodoplatform.github.io/coins/utils/coins_config.json';
      'https://komodoplatform.github.io/coins/coins';

  @override
  Future<JsonMap> generateStartParamsFromDefault(String seed) async {
    final homeDir = kIsWeb ? null : await getApplicationDocumentsDirectory();
    final userHome = homeDir?.path;
    final dbDir = userHome;

    return generateStartParams(
      'GUI_FFI',
      seed,
      userHome,
      dbDir,
    );
  }

  Future<JsonMap> generateStartParams(
    String gui,
    String passphrase,
    String? userHome,
    String? dbDir,
  ) async {
    String coinsData = await fetchCoinsData();

    if (coinsData.isEmpty) {
      throw Exception('Failed to fetch coins data.');
    }

    var startParams = {
      'mm2': 1,
      'allow_weak_password': false,
      'rpc_password': generatePassword(),
      'netid': 8762,
      'gui': gui,
      if (userHome != null) 'userhome': userHome,
      if (dbDir != null) 'dbdir': dbDir,
      'passphrase': passphrase,
      'coins': json.decode(coinsData),
    };

    // String jsonParams = json.encode(startParams);

    // // Censor the rpc_password and passphrase, and shorten the coins list to first and last 5 characters
    // final consoleSafeParams = jsonParams
    //     .replaceAll(RegExp(r'"rpc_password":".*?"'), '"rpc_password":"***"')
    //     .replaceAll(RegExp(r'"passphrase":".*?"'), '"passphrase":"***"')
    //     .replaceAll(RegExp(r'"coins":\[{.*?}\]'), '"coins":"_{{SNIP}}_"');
    // print('Start params: $consoleSafeParams');

    return startParams;
  }

  Future<String> fetchCoinsData() async =>
      (await http.Client().getJsonList(coinsUrl)).toJsonString();

  String generatePassword() {
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digit = '0123456789';
    const String punctuation = '*.!@#\$%^(){}:;\',.?/~`_+-=|';
    final List<String> stringSets = [lowerCase, upperCase, digit, punctuation];

    final Random rng = Random.secure();
    final int length =
        rng.nextInt(24) + 8; // Password length between 8 and 32 characters

    List<int> password = List.filled(length, 0);
    List<int> setCounts = List.filled(4, 0);

    for (int i = 0; i < length; i++) {
      int set = rng.nextInt(4);
      setCounts[set]++;
      password[i] =
          stringSets[set].codeUnitAt(rng.nextInt(stringSets[set].length));
    }

    // Ensure each character set is used at least once
    for (int i = 0; i < setCounts.length; i++) {
      if (setCounts[i] == 0) {
        int pos = rng.nextInt(length);
        password[pos] =
            stringSets[i].codeUnitAt(rng.nextInt(stringSets[i].length));
      }
    }

    String result = String.fromCharCodes(password);

    if (!validateRPCPassword(result)) {
      return generatePassword(); // Recursively regenerate if the password is invalid
    }

    return result;
  }

  bool validateRPCPassword(String src) {
    if (src.isEmpty) return false;

    // Password can't contain the word 'password'
    if (src.toLowerCase().contains('password')) return false;

    // Password must contain one digit, one lowercase letter, one uppercase letter,
    // one special character and its length must be between 8 and 32 characters
    RegExp exp =
        RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,32}$');
    if (!exp.hasMatch(src)) return false;

    // Password can't contain the same character three times in a row
    for (int i = 0; i < src.length - 2; i++) {
      if (src[i] == src[i + 1] && src[i + 1] == src[i + 2]) return false;
    }

    return true;
  }
}
