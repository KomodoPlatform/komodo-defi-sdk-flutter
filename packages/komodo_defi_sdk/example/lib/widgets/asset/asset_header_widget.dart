import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/screens/withdrawal_page.dart';
import 'package:kdf_sdk_example/widgets/asset/asset_actions_widget.dart';
import 'package:kdf_sdk_example/widgets/asset/balance_overview_widget.dart';
import 'package:kdf_sdk_example/widgets/common/private_keys_display_widget.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetHeaderWidget extends StatefulWidget {
  const AssetHeaderWidget({
    required this.asset,
    required this.pubkeys,
    super.key,
  });

  final Asset asset;
  final AssetPubkeys? pubkeys;

  @override
  State<AssetHeaderWidget> createState() => _AssetHeaderWidgetState();
}

class _AssetHeaderWidgetState extends State<AssetHeaderWidget> {
  StreamSubscription<BalanceInfo?>? _balanceSubscription;
  BalanceInfo? _balance;
  bool _balanceLoading = false;
  String? _balanceError;
  String? _signedMessage;
  bool _isSigningMessage = false;
  KdfUser? _currentUser;
  List<PrivateKey>? _privateKeys;
  bool _isExportingPrivateKey = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _balanceLoading = true;

    // Subscribe to balance updates with a small delay to allow pooled activation checks
    Future.delayed(
      const Duration(milliseconds: 50),
      _subscribeToBalanceUpdates,
    );
  }

  void _subscribeToBalanceUpdates() {
    _balanceSubscription = context
        .read<KomodoDefiSdk>()
        .balances
        .watchBalance(widget.asset.id)
        .listen(
          (balance) {
            setState(() {
              _balanceLoading = false;
              _balanceError = null;
              _balance = balance;
            });
          },
          onError: (Object error) {
            setState(() {
              _balanceLoading = false;
              _balanceError = error.toString();
            });
          },
        );
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final sdk = context.read<KomodoDefiSdk>();
    final user = await sdk.auth.currentUser;
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _exportPrivateKey() async {
    setState(() => _isExportingPrivateKey = true);

    try {
      final sdk = context.read<KomodoDefiSdk>();
      final privateKeyMap = await sdk.security.getPrivateKey(widget.asset.id);
      final privateKeys = privateKeyMap[widget.asset.id];

      if (mounted) {
        setState(() => _privateKeys = privateKeys);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting private key: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingPrivateKey = false);
      }
    }
  }

  Future<void> _showSignMessageDialog() async {
    final isHdWallet = _currentUser?.isHd ?? false;

    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Message'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHdWallet &&
                  widget.pubkeys != null &&
                  widget.pubkeys!.keys.isNotEmpty) ...[
                Text(
                  'Using address: ${widget.pubkeys!.keys[0].address}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
              TextFormField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message to sign',
                  hintText: 'Enter a message to sign',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'The signature can be used to prove that you own this address.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(context, messageController.text);
              }
            },
            child: const Text('Sign'),
          ),
        ],
      ),
    );

    if (message == null) return;

    setState(() => _isSigningMessage = true);
    try {
      final signature = await context
          .read<KomodoDefiSdk>()
          .messageSigning
          .signMessage(
            asset: widget.asset,
            addressInfo: widget.pubkeys!.keys.first,
            message: message,
          );
      setState(() => _signedMessage = signature);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing message: $e')));
    } finally {
      setState(() => _isSigningMessage = false);
    }
  }

  void _retryBalance() {
    setState(() {
      _balanceLoading = true;
      _balanceError = null;
    });
    _balanceSubscription?.cancel();
    _balanceSubscription = context
        .read<KomodoDefiSdk>()
        .balances
        .watchBalance(widget.asset.id)
        .listen(
          (balance) {
            setState(() {
              _balanceLoading = false;
              _balanceError = null;
              _balance = balance;
            });
          },
          onError: (Object error) {
            setState(() {
              _balanceLoading = false;
              _balanceError = error.toString();
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BalanceOverviewWidget(
          balance: _balance,
          isLoading: _balanceLoading,
          error: _balanceError,
          onRetry: _retryBalance,
        ),
        const SizedBox(height: 16),
        AssetActionsWidget(
          asset: widget.asset,
          pubkeys: widget.pubkeys,
          currentUser: _currentUser,
          isSigningMessage: _isSigningMessage,
          isExportingPrivateKey: _isExportingPrivateKey,
          onSend: widget.pubkeys == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => WithdrawalScreen(
                        asset: widget.asset,
                        pubkeys: widget.pubkeys!,
                      ),
                    ),
                  );
                },
          onReceive: () {},
          onSignMessage: _showSignMessageDialog,
          onExportPrivateKey: _exportPrivateKey,
        ),
        if (_signedMessage != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Signed Message'),
              subtitle: Text(_signedMessage!),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _signedMessage!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signature copied to clipboard'),
                    ),
                  );
                },
              ),
              onTap: () {
                setState(() => _signedMessage = null);
              },
            ),
          ),
        ],
        if (_privateKeys != null) ...[
          const SizedBox(height: 16),
          SingleAssetPrivateKeysDisplayWidget(
            privateKeys: _privateKeys!,
            assetId: widget.asset.id,
            onClose: () => setState(() => _privateKeys = null),
          ),
        ],
      ],
    );
  }
}
