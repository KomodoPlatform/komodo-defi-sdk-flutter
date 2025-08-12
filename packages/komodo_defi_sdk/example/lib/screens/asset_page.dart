import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/widgets/asset/addresses_section_widget.dart';
import 'package:kdf_sdk_example/widgets/asset/asset_header_widget.dart';
import 'package:kdf_sdk_example/widgets/asset/new_address_dialog_widget.dart';
import 'package:kdf_sdk_example/widgets/asset/transactions_section_widget.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetPage extends StatefulWidget {
  const AssetPage(this.asset, {super.key});

  final Asset asset;

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  AssetPubkeys? _pubkeys;
  bool _isLoading = false;
  String? _error;

  late final _sdk = context.read<KomodoDefiSdk>();
  StreamSubscription<AssetPubkeys>? _pubkeysSubscription;

  @override
  void initState() {
    super.initState();
    _refreshUnavailableReasons().ignore();
    _startWatchingPubkeys();
  }

  void _startWatchingPubkeys() {
    setState(() => _isLoading = true);
    _pubkeysSubscription?.cancel();
    _pubkeysSubscription = _sdk.pubkeys
        .watchPubkeys(widget.asset)
        .listen(
          (pubkeys) {
            if (!mounted) return;
            setState(() {
              _pubkeys = pubkeys;
              _error = null;
              _isLoading = false;
            });
          },
          onError: (Object e) {
            if (!mounted) return;
            setState(() {
              _error = e.toString();
              _isLoading = false;
            });
          },
        );
  }

  Future<void> _forceRefreshPubkeys() async {
    setState(() => _isLoading = true);
    try {
      await _sdk.pubkeys.precachePubkeys(widget.asset);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
      await _refreshUnavailableReasons();
    }
  }

  Future<void> _generateNewAddress() async {
    setState(() => _isLoading = true);
    try {
      final stream = _sdk.pubkeys.watchCreateNewPubkey(widget.asset);

      final newPubkey = await showDialog<PubkeyInfo>(
        context: context,
        barrierDismissible: false,
        builder: (context) => NewAddressDialogWidget(stream: stream),
      );

      if (newPubkey != null) {
        setState(() {
          _pubkeys?.keys.add(newPubkey);
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
      await _refreshUnavailableReasons();
    }
  }

  Set<CantCreateNewAddressReason>? _cantCreateNewAddressReasons;

  Future<void> _refreshUnavailableReasons() async {
    final reasons = await widget.asset.getCantCreateNewAddressReasons(_sdk);
    setState(() => _cantCreateNewAddressReasons = reasons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset.id.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefreshPubkeys,
          ),
        ],
      ),
      body:
          _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                children: [
                  // Add linear progress indicator for pubkey loading
                  if (_isLoading) const LinearProgressIndicator(minHeight: 4),
                  AssetHeaderWidget(asset: widget.asset, pubkeys: _pubkeys),
                  const SizedBox(height: 32),
                  Flexible(
                    child: AddressesSectionWidget(
                      pubkeys:
                          _pubkeys ??
                          AssetPubkeys(
                            keys: const [],
                            assetId: widget.asset.id,
                            availableAddressesCount: 0,
                            syncStatus: SyncStatusEnum.inProgress,
                          ),
                      onGenerateNewAddress: _generateNewAddress,
                      cantCreateNewAddressReasons: _cantCreateNewAddressReasons,
                      isGeneratingAddress: _isLoading,
                    ),
                  ),
                  Expanded(
                    child: TransactionsSectionWidget(asset: widget.asset),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    _pubkeysSubscription?.cancel();
    _pubkeysSubscription = null;
    super.dispose();
  }
}
