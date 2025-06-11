import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SwapPage extends StatefulWidget {
  const SwapPage(this.asset, {super.key});

  final Asset asset;

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  final _relController = TextEditingController();
  final _amountController = TextEditingController();
  StreamSubscription<SwapStatus>? _subscription;
  SwapStatus? _status;
  OneInchClassicSwapQuote? _quote;
  bool _loading = false;

  KomodoDefiSdk get _sdk => context.read<KomodoDefiSdk>();

  @override
  void dispose() {
    _subscription?.cancel();
    _relController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _getQuote() async {
    setState(() => _loading = true);
    try {
      final amount = Decimal.parse(_amountController.text);
      final quote = await _sdk.swaps.getClassicQuote(
        base: widget.asset.id.id,
        rel: _relController.text,
        amount: amount,
      );
      setState(() => _quote = quote);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quote error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startSwap() async {
    setState(() {
      _status = null;
      _loading = true;
    });
    final amount = Decimal.parse(_amountController.text);
    _subscription = _sdk.swaps
        .buy(base: widget.asset.id.id, rel: _relController.text, volume: amount)
        .listen(
          (status) {
            setState(() {
              _status = status;
              _loading = false;
            });
          },
          onError: (e) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Swap error: $e')));
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Swap ${widget.asset.id.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _relController,
              decoration: const InputDecoration(labelText: 'Rel asset'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _getQuote,
                  child: const Text('Get Quote'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _startSwap,
                  child: const Text('Start Swap'),
                ),
              ],
            ),
            if (_quote != null) ...[
              const SizedBox(height: 16),
              Text('Quote: ${_quote!.dstAmount} ${_relController.text}'),
            ],
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text('Status: ${_status!.events.last.type}'),
            ],
          ],
        ),
      ),
    );
  }
}
