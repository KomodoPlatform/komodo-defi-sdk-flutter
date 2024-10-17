import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetPage extends StatefulWidget {
  const AssetPage(this.asset, {super.key});

  final Asset asset;

  @override
  State<AssetPage> createState() => _AssetPageState();
}

final _sdk = KomodoDefiSdk();

class _AssetPageState extends State<AssetPage> {
  AssetPubkeys? _pubkeys;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPubkey();
  }

  Future<void> _loadPubkey() async {
    setState(() => _isLoading = true);
    try {
      final pubkey = await widget.asset.getPubkey();
      setState(() => _pubkeys = pubkey);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset.id.name),
      ),
      body: Column(
        children: [
          if (_error != null)
            Text('Error: $_error')
          else if (_isLoading)
            const LinearProgressIndicator()
          else if (_pubkeys != null)
            _AddressesSection(_pubkeys!),
        ],
      ),
    );
  }
}

class _AddressesSection extends StatelessWidget {
  const _AddressesSection(this.pubkeys);

  final AssetPubkeys pubkeys;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Addresses'),
        for (final key in pubkeys.addresses)
          ListTile(
            title: Text(pubkeys.addresses.indexOf(key).toString()),
            // subtitle: Text(key.address),
            subtitle: Text(key.toJson().toJsonString()),
            onTap: () {
              Clipboard.setData(ClipboardData(text: key.address));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
      ],
    );
  }
}
