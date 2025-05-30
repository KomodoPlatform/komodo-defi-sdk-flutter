import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_ui/komodo_ui.dart';

/// Simple page showcasing the [DappBrowser] widget.
class DappBrowserPage extends StatelessWidget {
  const DappBrowserPage({required this.sdk, super.key});

  final KomodoDefiSdk sdk;

  @override
  Widget build(BuildContext context) {
    final evmProvider = EvmProvider(sdk.client);
    final komodoProvider = KomodoProvider(sdk.client);

    return Scaffold(
      appBar: AppBar(title: const Text('dApp Browser')),
      body: DappBrowser(
        initialUrl: 'https://uniswap.org',
        evmProvider: evmProvider,
        komodoProvider: komodoProvider,
      ),
    );
  }
}
