import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/screens/withdrawal_page.dart';
import 'package:kdf_sdk_example/screens/staking_page.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
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

  @override
  void initState() {
    super.initState();
    _refreshUnavailableReasons().ignore();
    _loadPubkeys();
  }

  Future<void> _loadPubkeys() async {
    setState(() => _isLoading = true);
    try {
      final pubkeys = await _sdk.pubkeys.getPubkeys(widget.asset);
      _pubkeys = pubkeys;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _refreshUnavailableReasons().ignore();
    }
  }

  Future<void> _generateNewAddress() async {
    setState(() => _isLoading = true);
    try {
      final newPubkey = await _sdk.pubkeys.createNewPubkey(widget.asset);
      setState(() {
        _pubkeys?.keys.add(newPubkey);
      });
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPubkeys),
        ],
      ),
      body:
          _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                children: [
                  // Add linear progress indicator for pubkey loading
                  if (_isLoading) const LinearProgressIndicator(minHeight: 4),
                  // const SizedBox(height: 32),
                  AssetHeader(widget.asset, _pubkeys),
                  const SizedBox(height: 32),
                  Flexible(
                    child: _AddressesSection(
                      pubkeys:
                          _pubkeys == null
                              ? AssetPubkeys(
                                keys: [],
                                assetId: widget.asset.id,
                                availableAddressesCount: 0,
                                syncStatus: SyncStatusEnum.inProgress,
                              )
                              : _pubkeys!,
                      onGenerateNewAddress: _generateNewAddress,
                      cantCreateNewAddressReasons: _cantCreateNewAddressReasons,
                      isGeneratingAddress: _isLoading,
                    ),
                  ),
                  Expanded(child: _TransactionsSection(widget.asset)),
                ],
              ),
    );
  }
}

class AssetHeader extends StatefulWidget {
  const AssetHeader(this.asset, this.pubkeys, {super.key});

  final Asset asset;
  final AssetPubkeys? pubkeys;

  @override
  State<AssetHeader> createState() => _AssetHeaderState();
}

class _AssetHeaderState extends State<AssetHeader> {
  StreamSubscription<BalanceInfo?>? _balanceSubscription;
  BalanceInfo? _balance;
  bool _balanceLoading = false;
  String? _balanceError;

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
          onError: (error) {
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

  String? _signedMessage;
  bool _isSigningMessage = false;
  KdfUser? _currentUser;

  Future<void> _loadCurrentUser() async {
    final sdk = context.read<KomodoDefiSdk>();
    final user = await sdk.auth.currentUser;
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBalanceOverview(context),
        const SizedBox(height: 16),
        _buildActions(context),
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
      ],
    );
  }

  Widget _buildBalanceOverview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              _balanceLoading
                  ? [
                    const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(),
                    ),
                  ]
                  : _balanceError != null
                  ? [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading balance',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      _balanceError!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
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
                              onError: (error) {
                                setState(() {
                                  _balanceLoading = false;
                                  _balanceError = error.toString();
                                });
                              },
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ]
                  : [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      (_balance?.total.toDouble() ?? 0.0).toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(width: 128, child: Divider()),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Available',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _balance?.spendable.toDouble().toString() ??
                                  '0.0',
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              'Locked',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _balance?.unspendable.toDouble().toString() ??
                                  '0.0',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
        ),
      ),
    );
  }

  //TODO: Eradicate this widget helper function
  Widget _buildActions(BuildContext context) {
    final isHdWallet =
        _currentUser?.authOptions.derivationMethod == DerivationMethod.hdWallet;
    final hasAddresses =
        widget.pubkeys != null && widget.pubkeys!.keys.isNotEmpty;

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 8,
      children: [
        FilledButton.icon(
          onPressed:
              widget.pubkeys == null
                  ? null
                  : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (context) => WithdrawalScreen(
                              asset: widget.asset,
                              pubkeys: widget.pubkeys!,
                            ),
                      ),
                    );
                  },
          icon: const Icon(Icons.send),
          label: const Text('Send'),
        ),
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code),
          label: const Text('Receive'),
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => StakingPage(asset: widget.asset),
              ),
            );
          },
          icon: const Icon(Icons.stacked_line_chart),
          label: const Text('Stake'),
        ),

        Tooltip(
          message:
              !hasAddresses
                  ? 'No addresses available to sign with'
                  : isHdWallet
                  ? 'Will sign with the first address'
                  : 'Sign a message with this address',
          child: FilledButton.tonalIcon(
            onPressed:
                _isSigningMessage || !hasAddresses
                    ? null
                    : () => _showSignMessageDialog(context),
            icon: const Icon(Icons.edit_document),
            label:
                _isSigningMessage
                    ? const Text('Signing...')
                    : const Text('Sign'),
          ),
        ),
      ],
    );
  }

  Future<void> _showSignMessageDialog(BuildContext context) async {
    final isHdWallet = _currentUser?.isHd ?? false;

    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final message = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      final signature = await context.read<KomodoDefiSdk>().messageSigning
      // TODO: Dropdown for address selection
      .signMessage(
        coin: widget.asset.id.id,
        message: message,
        address: widget.pubkeys!.keys.first.address,
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
}

class _AddressesSection extends StatelessWidget {
  const _AddressesSection({
    required this.pubkeys,
    required this.onGenerateNewAddress,
    required this.cantCreateNewAddressReasons,
    this.isGeneratingAddress = false,
  });

  final AssetPubkeys pubkeys;
  final VoidCallback? onGenerateNewAddress;
  final Set<CantCreateNewAddressReason>? cantCreateNewAddressReasons;
  final bool isGeneratingAddress;

  String _getTooltipMessage() {
    if (cantCreateNewAddressReasons?.isEmpty ?? true) {
      return '';
    }

    return cantCreateNewAddressReasons!
        .map((reason) {
          return switch (reason) {
            CantCreateNewAddressReason.maxGapLimitReached =>
              'Maximum gap limit reached - please use existing unused addresses first',
            CantCreateNewAddressReason.maxAddressesReached =>
              'Maximum number of addresses reached for this asset',
            CantCreateNewAddressReason.missingDerivationPath =>
              'Missing derivation path configuration',
            CantCreateNewAddressReason.protocolNotSupported =>
              'Protocol does not support multiple addresses',
            CantCreateNewAddressReason.derivationModeNotSupported =>
              'Current wallet mode does not support multiple addresses',
            CantCreateNewAddressReason.noActiveWallet =>
              'No active wallet - please sign in first',
          };
        })
        .join('\n');
  }

  bool get canCreateNewAddress => cantCreateNewAddressReasons?.isEmpty ?? true;

  @override
  Widget build(BuildContext context) {
    final tooltipMessage = _getTooltipMessage();
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Addresses'),
              Tooltip(
                message: tooltipMessage,
                preferBelow: true,
                child: ElevatedButton.icon(
                  onPressed:
                      (canCreateNewAddress && !isGeneratingAddress)
                          ? onGenerateNewAddress
                          : null,
                  label: const Text('New'),
                  icon:
                      isGeneratingAddress
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.add),
                ),
              ),
            ],
          ),
          Expanded(
            child:
                pubkeys.keys.isEmpty &&
                        pubkeys.syncStatus != SyncStatusEnum.inProgress
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pubkeys.syncStatus ==
                              SyncStatusEnum.inProgress) ...[
                            const SizedBox(
                              height: 32,
                              width: 32,
                              child: CircularProgressIndicator(),
                            ),
                            const SizedBox(height: 16),
                            const Text('Loading addresses...'),
                          ] else
                            const Text('No addresses available'),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: pubkeys.keys.length,
                      itemBuilder:
                          (context, index) => ListTile(
                            leading: Text(index.toString()),
                            title: Text(
                              pubkeys.keys[index].toJson().toJsonString(),
                            ),
                            trailing: Text(
                              pubkeys.keys[index].balance.total
                                  .toStringAsPrecision(2),
                            ),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: pubkeys.keys[index].address,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
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

class _TransactionsSection extends StatefulWidget {
  // ignore: unused_element
  const _TransactionsSection(this.asset);

  final Asset asset;

  @override
  State<_TransactionsSection> createState() => __TransactionsSectionState();
}

class __TransactionsSectionState extends State<_TransactionsSection> {
  final _transactions = <Transaction>[];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text('Transactions'),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return ListTile(
                title: Text(transaction.amount.toString()),
                subtitle: Text(transaction.toJson().toJsonString()),
              );
            },
          ),
        ),
      ],
    );
  }

  bool loading = false;

  Future<void> _loadTransactions() async {
    try {
      final transactionsStream = context
          .read<KomodoDefiSdk>()
          .transactions
          .getTransactionsStreamed(widget.asset);

      await for (final transactions in transactionsStream) {
        _transactions.addAll(transactions);
        setState(() {});
      }
    } catch (e) {
      print('FAILED TO FETCH TXs');
      print(e);
    }
  }
}
