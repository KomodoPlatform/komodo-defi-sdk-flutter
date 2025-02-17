import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/screens/withdrawal_page.dart';
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

  final List<Transaction> _transactions = [];

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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBalanceOverview(context),
        const SizedBox(height: 16),
        _buildActions(context),
      ],
    );
  }

  Widget _buildBalanceOverview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              // TODO: Stream-based
              (widget.pubkeys?.syncStatus == SyncStatusEnum.inProgress)
                  ? 'Loading...'
                  : (widget.pubkeys?.balance.total.toDouble() ?? 0.0)
                      .toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            const SizedBox(width: 128, child: Divider()),
            const SizedBox(height: 8),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Text(
                      'Available',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      widget.pubkeys?.balance.spendable.toDouble().toString() ??
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
                      widget.pubkeys?.balance.unspendable
                              .toDouble()
                              .toString() ??
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
      ],
    );
  }
}

class _AddressesSection extends StatelessWidget {
  const _AddressesSection({
    required this.pubkeys,
    required this.onGenerateNewAddress,
    required this.cantCreateNewAddressReasons,
  });

  final AssetPubkeys pubkeys;
  final VoidCallback? onGenerateNewAddress;
  final Set<CantCreateNewAddressReason>? cantCreateNewAddressReasons;

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
                  onPressed: canCreateNewAddress ? onGenerateNewAddress : null,
                  label: const Text('New'),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pubkeys.keys.length,
              itemBuilder:
                  (context, index) => ListTile(
                    leading: Text(index.toString()),
                    title: Text(pubkeys.keys[index].toJson().toJsonString()),
                    trailing: Text(
                      pubkeys.keys[index].balance.total.toStringAsPrecision(2),
                    ),
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: pubkeys.keys[index].address),
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
