// import 'dart:async';
// import 'dart:convert';
// import 'dart:js_interop';
// import 'package:flutter/services.dart';
// // import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// @JS('mm2')
// external set _mm2SetUp(void Function() f);

// @JS('mm2.initMm2')
// external Future<void> _initMm2(String config);

// @JS('mm2.rpcRequest')
// external Future<String> _rpcRequest(String request);

// @JS('mm2.getMm2Status')
// external Future<int> _getMm2Status();

// @JS('mm2.stopMm2')
// external Future<void> _stopMm2();

// @JS('mm2.getMm2Version')
// external Future<String> _getMm2Version();

// class Mm2PluginWeb {
//   static void registerWith(Registrar registrar) {
//     final MethodChannel channel = MethodChannel(
//       'mm2_plugin',
//       const StandardMethodCodec(),
//       registrar,
//     );

//     final plugin = Mm2PluginWeb();
//     channel.setMethodCallHandler(plugin.handleMethodCall);
//   }

//   Future<void> initMm2(String config) => _initMm2(config);

//   Future<Map<String, dynamic>> rpcRequest(Map<String, dynamic> request) async {
//     final response = await _rpcRequest(json.encode(request));
//     return json.decode(response);
//   }

//   Future<int> getMm2Status() => _getMm2Status();

//   Future<void> stopMm2() => _stopMm2();

//   Future<String> getMm2Version() => _getMm2Version();

//   Future<dynamic> handleMethodCall(MethodCall call) async {
//     switch (call.method) {
//       case 'initMm2':
//         await initMm2(call.arguments as String);
//         break;
//       case 'rpcRequest':
//         final response =
//             await rpcRequest(call.arguments as Map<String, dynamic>);
//         return response;
//       case 'getMm2Status':
//         return getMm2Status();
//       case 'stopMm2':
//         return stopMm2();
//       case 'getMm2Version':
//         return getMm2Version();
//       default:
//         throw PlatformException(
//           code: 'Unimplemented',
//           details: 'mm2_plugin for web doesn\'t implement \'${call.method}\'',
//         );
//     }
//   }
// }
