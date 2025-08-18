import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class MerchantInvoiceScreen extends StatefulWidget {
  const MerchantInvoiceScreen({super.key, required this.sdk});

  final KomodoDefiSdk sdk;

  @override
  State<MerchantInvoiceScreen> createState() => _MerchantInvoiceScreenState();
}

class _MerchantInvoiceScreenState extends State<MerchantInvoiceScreen> {
  final _amountController = TextEditingController(text: '25.00');
  QuoteCurrency _fiat = FiatCurrency.usd;
  Asset? _selectedAsset;
  MerchantInvoice? _invoice;
  StreamSubscription<InvoiceUpdate>? _sub;
  InvoiceStatus? _latestStatus;

  @override
  void initState() {
    super.initState();
    // Pick a default asset if possible (first activated UTXO or EVM)
    _pickDefaultAsset();
  }

  void _pickDefaultAsset() async {
    final activated = await widget.sdk.assets.getActivatedAssets();
    setState(() {
      _selectedAsset = activated.firstWhere(
        (a) => a.id.subClass == CoinSubClass.utxo || evmCoinSubClasses.contains(a.id.subClass),
        orElse: () => activated.isNotEmpty ? activated.first : null as Asset,
      );
    });
  }

  Future<void> _createInvoice() async {
    if (_selectedAsset == null) return;
    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null) {
      _show('Enter a valid fiat amount');
      return;
    }

    try {
      final invoice = await widget.sdk.merchantInvoices.createInvoice(
        asset: _selectedAsset!,
        fiatAmount: amount,
        fiat: _fiat,
        expiresIn: const Duration(minutes: 15),
        minConfirmations: 1,
      );
      setState(() {
        _invoice = invoice;
        _latestStatus = invoice.status;
      });
      _sub?.cancel();
      _sub = widget.sdk.merchantInvoices.watchInvoice(invoice.id).listen((ev) {
        setState(() => _latestStatus = ev.status);
      });
    } catch (e) {
      _show('Failed to create invoice: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final invoice = _invoice;
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Invoice Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Fiat Amount'),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<QuoteCurrency>(
                value: _fiat,
                items: const [
                  DropdownMenuItem(value: FiatCurrency.usd, child: Text('USD')),
                  DropdownMenuItem(value: FiatCurrency.eur, child: Text('EUR')),
                ],
                onChanged: (v) => setState(() => _fiat = v ?? _fiat),
              ),
            ]),
            const SizedBox(height: 12),
            FutureBuilder<List<Asset>>(
              future: widget.sdk.assets.getActivatedAssets(),
              builder: (context, snap) {
                final assets = snap.data ?? const <Asset>[];
                return DropdownButton<Asset>(
                  value: _selectedAsset,
                  hint: const Text('Select Asset'),
                  items: [
                    for (final a in assets)
                      DropdownMenuItem(
                        value: a,
                        child: Text('${a.id.name} (${a.id.subClass.formatted})'),
                      ),
                  ],
                  onChanged: (a) => setState(() => _selectedAsset = a),
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createInvoice,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate Invoice'),
            ),
            const SizedBox(height: 24),
            if (invoice != null) ...[
              Text('Address: ${invoice.address}'),
              const SizedBox(height: 4),
              Text('Amount: ${invoice.coinAmount} ${invoice.asset.id.symbol.ticker}'),
              const SizedBox(height: 4),
              Text('Payment URI:'),
              SelectableText(invoice.paymentUri),
              const SizedBox(height: 8),
              Text('Status: ${_latestStatus.toString()}'),
            ],
          ],
        ),
      ),
    );
  }
}

