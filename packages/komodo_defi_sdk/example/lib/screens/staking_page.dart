import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({required this.asset, super.key});

  final Asset asset;

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  List<DelegationInfo>? _delegations;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDelegations();
  }

  Future<void> _loadDelegations() async {
    setState(() => _loading = true);
    final sdk = context.read<KomodoDefiSdk>();
    try {
      final infos = await sdk.staking.queryDelegations(
        widget.asset.id,
        infoDetails: const StakingInfoDetails(type: 'Cosmos'),
      );
      setState(() => _delegations = infos);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staking ${widget.asset.id.name}')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView(
                children:
                    _delegations?.map((d) {
                      return ListTile(
                        title: Text(d.validatorAddress),
                        subtitle: Text(
                          'Delegated: ${d.delegatedAmount} Reward: ${d.rewardAmount}',
                        ),
                      );
                    }).toList() ??
                    [const ListTile(title: Text('No delegations'))],
              ),
    );
  }
}
