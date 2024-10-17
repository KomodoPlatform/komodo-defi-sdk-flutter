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
    _loadPubkeys();
  }

  Future<void> _loadPubkeys() async {
    setState(() => _isLoading = true);
    try {
      final pubkeys = await _sdk.pubkeys.getPubkeys(widget.asset);
      setState(() => _pubkeys = pubkeys);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateNewAddress() async {
    setState(() => _isLoading = true);
    try {
      final newPubkey = await _sdk.pubkeys.createNewPubkey(widget.asset);
      setState(() {
        _pubkeys?.addresses.add(newPubkey);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportsMultipleAddresses =
        widget.asset.pubkeyStrategy.supportsMultipleAddresses;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset.id.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPubkeys,
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text('Error: $_error'))
          : _AddressesSection(
              pubkeys: _pubkeys == null
                  ? AssetPubkeys(
                      addresses: [],
                      assetId: widget.asset.id,
                      availableAddressesCount: 0,
                      syncStatus: SyncStatus.inProgress,
                    )
                  : _pubkeys!,
              onGenerateNewAddress:
                  supportsMultipleAddresses ? _generateNewAddress : null,
              supportsMultipleAddresses: supportsMultipleAddresses,
            ),
    );
  }
}

class _AddressesSection extends StatelessWidget {
  const _AddressesSection({
    required this.pubkeys,
    required this.onGenerateNewAddress,
    required this.supportsMultipleAddresses,
  });

  final AssetPubkeys pubkeys;
  final VoidCallback? onGenerateNewAddress;
  final bool supportsMultipleAddresses;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Addresses'),
              if (supportsMultipleAddresses)
                ElevatedButton(
                  onPressed: onGenerateNewAddress,
                  child: const Text('Generate New Address'),
                ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pubkeys.addresses.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(index.toString()),
                subtitle:
                    Text(pubkeys.addresses[index].toJson().toJsonString()),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: pubkeys.addresses[index].address),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
