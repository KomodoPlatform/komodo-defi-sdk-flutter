import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class TransactionsSectionWidget extends StatefulWidget {
  const TransactionsSectionWidget({required this.asset, super.key});

  final Asset asset;

  @override
  State<TransactionsSectionWidget> createState() =>
      _TransactionsSectionWidgetState();
}

class _TransactionsSectionWidgetState extends State<TransactionsSectionWidget> {
  final _transactions = <Transaction>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactionsStream = context
          .read<KomodoDefiSdk>()
          .transactions
          .getTransactionsStreamed(widget.asset);

      await for (final transactions in transactionsStream) {
        if (mounted) {
          _transactions.addAll(transactions);
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              _error != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        const Text('Failed to load transactions'),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTransactions,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : _transactions.isEmpty && !_isLoading
                  ? const Center(child: Text('No transactions found'))
                  : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: Text(
                            transaction.amount.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Hash: ${transaction.txHash}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing:
                              transaction.blockHeight != null
                                  ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      Text(
                                        'Block ${transaction.blockHeight}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  )
                                  : const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pending,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      Text(
                                        'Pending',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Transaction Details'),
                                    content: SingleChildScrollView(
                                      child: SelectableText(
                                        transaction.toJson().toJsonString(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
