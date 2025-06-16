import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class StakingPage extends StatefulWidget {
  const StakingPage({super.key, required this.asset});

  final Asset asset;

  @override
  State<StakingPage> createState() => _StakingPageState();
}

class _StakingPageState extends State<StakingPage> {
  late final _sdk = context.read<KomodoDefiSdk>();
  final _addressController = TextEditingController();
  String? _info;
  bool _loading = false;

  Future<void> _loadInfo() async {
    setState(() => _loading = true);
    try {
      final info = await _sdk.staking.getStakingInfo(widget.asset);
      setState(() => _info = info.details.toJson().toString());
    } catch (e) {
      setState(() => _info = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _delegate() async {
    final address = _addressController.text;
    if (address.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _sdk.staking.delegate(asset: widget.asset, address: address);
      setState(() => _info = 'Delegation transaction created');
    } catch (e) {
      setState(() => _info = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _undelegate() async {
    setState(() => _loading = true);
    try {
      await _sdk.staking.undelegate(widget.asset);
      setState(() => _info = 'Delegation removed');
    } catch (e) {
      setState(() => _info = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.asset.id.name} Staking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delegation address',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _delegate,
                  child: const Text('Delegate'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _undelegate,
                  child: const Text('Remove'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _loadInfo,
                  child: const Text('Info'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_info != null) Text(_info!),
          ],
        ),
      ),
    );
  }
}
