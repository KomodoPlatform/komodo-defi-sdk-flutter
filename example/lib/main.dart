import 'package:bip39/bip39.dart';
import 'package:flutter/material.dart';

import 'package:komodo_defi_framework/komodo_defi_framework.dart'
    as komodo_defi_framework;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // komodo_defi_framework
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                OutlinedButton(
                  onPressed: () async {
                    // TODO: Pass seed phrase from text input (generate random)
                    await komodo_defi_framework.KomodoDefiFramework.create(
                      externalLogger: print,
                    ).startKdf(generateMnemonic());
                  },
                  child: const Text('Start KDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
