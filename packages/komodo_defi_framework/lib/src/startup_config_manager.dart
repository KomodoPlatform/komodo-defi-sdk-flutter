// import 'dart:convert';

// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:komodo_defi_framework/komodo_defi_framework.dart';
// import 'package:komodo_defi_framework/src/extensions/http_extensions.dart';
// import 'package:komodo_defi_types/komodo_defi_types.dart';

// // `TODO`: Future refactoring to minimize time that seed is in memory
// // ignore: one_member_abstracts
// abstract class IKdfStartupConfig {
//   Future<JsonMap> generateStartParams(IKdfConfig config);
// }

// class StartupConfigBuilder implements IKdfStartupConfig {
//   static const String coinsUrl = 'https://komodoplatform.github.io/coins/coins';

//   Future<String> fetchCoinsData() async {
//     final coinsDataAssetOrEmpty =
//         await rootBundle.loadString('assets/coins.json').catchError((_) => '');

//     return coinsDataAssetOrEmpty.isNotEmpty
//         ? coinsDataAssetOrEmpty
//         : (await http.Client().getJsonList(coinsUrl)).toJsonString();
//   }

//   @override
//   Future<JsonMap> generateStartParams(IKdfConfig config) async {
//     final coinsData = await fetchCoinsData();

//     if (coinsData.isEmpty) {
//       throw Exception('Failed to fetch coins data.');
//     }

//     final startParams = {
//       'mm2': 1,
//       'allow_weak_password': false,
//       'rpc_password': config.userpass,
//       'netid': 8762,
//       'gui': 'komodo-defi-flutter',
//       'wallet_name': config.walletName,
//       'coins': json.decode(coinsData),
//       if (config.seed != null) 'seed': config.seed,
//       if (config is LocalConfig) ...{
//         'https': true,
//      if(config.dbDir!= null)?   'db_dir': config.dbDir,
//         'userhome': config.userHome,
//       },
//       if (config is RemoteConfig) ...{
//         'rpcip': '0.0.0.0',
//         'myipaddr': config.ipAddress,
//         'rpcport': config.port,
//         'rpc_local_only': false,
//         'rpccors': '*',
//       },
//     };

//     return startParams;
//   }

//   static String generatePassword() {
//     var result = '';

//     while (!validateRPCPassword(result)) {
//       result = SecurityUtils.securePassword(32);
//     }

//     return result;
//   }

//   static bool validateRPCPassword(String src) {
//     // Password must contain one digit, one lowercase letter, one uppercase
//     // letter, one special character and its length must be between 8 and
//     // 32 characters
//     final exp =
//         RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,32}$');
//     if (!exp.hasMatch(src)) return false;

//     // Password can't contain the same character three times in a row
//     if (RegExp(r'(.)\1\1').hasMatch(src)) return false;

//     return true;
//   }
// }
