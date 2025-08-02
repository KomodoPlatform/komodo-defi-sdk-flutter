import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/staking/staking_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({required this.asset, super.key});

  final Asset asset;

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final IStakingManager _stakingManager;

  StakingInfo? _stakingInfo;
  List<ValidatorRecommendation>? _validators;
  // List<OngoingUndelegation>? _unbondingPositions;  // Currently unused
  Stream<StakingState>? _stakingStateStream;
  Stream<RewardUpdate>? _rewardStream;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final sdk = context.read<KomodoDefiSdk>();
    _stakingManager = sdk.staking;
    _initializeStreams();
    _loadStakingData();
  }

  void _initializeStreams() {
    _stakingStateStream = _stakingManager.watchStakingState(widget.asset.id);
    _rewardStream = _stakingManager.watchRewards(widget.asset.id);
  }

  Future<void> _loadStakingData() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _stakingManager.getStakingInfo(widget.asset.id),
        _stakingManager.getRecommendedValidators(assetId: widget.asset.id),
        _stakingManager.queryOngoingUndelegations(
          widget.asset.id,
          const StakingInfoDetails(type: 'Cosmos'),
        ),
      ], eagerError: false);

      setState(() {
        _stakingInfo = results[0] as StakingInfo;
        _validators = results[1] as List<ValidatorRecommendation>;
        // _unbondingPositions = results[2] as List<OngoingUndelegation>;
      });

      // Log warning if validators are empty
      if (_validators == null || _validators!.isEmpty) {
        print('Warning: No validators returned for ${widget.asset.id.id}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.asset.id.id} Staking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Stake'),
            Tab(text: 'Manage'),
          ],
        ),
      ),
      body:
          _loading && _stakingInfo == null
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorView()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildStakeTab(),
                  _buildManageTab(),
                ],
              ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadStakingData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadStakingData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_stakingInfo != null) ...[
            StakingOverviewCard(
              stakingInfo: _stakingInfo!,
              asset: widget.asset,
              onClaimRewards:
                  _stakingInfo!.pendingRewards.compareTo(Decimal.zero) > 0
                      ? _claimAllRewards
                      : null,
            ),
            const SizedBox(height: 16),
          ],

          StreamBuilder<StakingState>(
            stream: _stakingStateStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final state = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Staking Health',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      StakingHealthIndicator(
                        health: state.health,
                        onTap: () => _showHealthDetails(state),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (state.positions.isNotEmpty) ...[
                    Text(
                      'Active Delegations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...state.positions.map(
                      (position) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DelegationCard(
                          position: position,
                          asset: widget.asset,
                          onUnstake: () => _showUnstakeDialog(position),
                          onClaimRewards:
                              position.rewards.compareTo(Decimal.zero) > 0
                                  ? () => _claimRewardsFromValidator(
                                    position.validatorAddress,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  ],

                  if (state.unbonding.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Unbonding Positions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...state.unbonding.map(
                      (unbonding) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UnbondingCard(
                          unbonding: unbonding,
                          asset: widget.asset,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          StreamBuilder<RewardUpdate>(
            stream: _rewardStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              return RewardDisplay(
                rewards: snapshot.data!,
                asset: widget.asset,
                onClaim: _claimAllRewards,
                compact: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStakeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StakeForm(
          asset: widget.asset,
          stakingManager: _stakingManager,
          validators: _validators ?? [],
          onStaked: () {
            _loadStakingData();
            _tabController.animateTo(0);
          },
          onRefreshValidators: _loadStakingData,
        ),
      ],
    );
  }

  Widget _buildManageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_fix_high, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Staking Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _stakingInfo != null &&
                                _stakingInfo!.pendingRewards.compareTo(
                                      Decimal.zero,
                                    ) >
                                    0
                            ? _claimAllRewards
                            : null,
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Claim All Rewards'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _stakingInfo != null &&
                                _stakingInfo!.totalStaked.compareTo(
                                      Decimal.zero,
                                    ) >
                                    0
                            ? _showRebalanceDialog
                            : null,
                    icon: const Icon(Icons.balance),
                    label: const Text('Rebalance Stake'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _stakingInfo != null &&
                                _stakingInfo!.pendingRewards.compareTo(
                                      Decimal.zero,
                                    ) >
                                    0
                            ? _claimAndRestake
                            : null,
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Claim & Auto-Restake'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_stakingInfo != null &&
            _stakingInfo!.availableBalance.compareTo(Decimal.zero) > 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.flash_on,
                        size: 24,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _quickStake,
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Quick Stake (Optimal Strategy)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _claimAllRewards() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Claim All Rewards'),
            content: const Text(
              'Do you want to claim rewards from all validators?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Claim'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _loading = true);
      final result = await _stakingManager.claimAllRewards(
        assetId: widget.asset.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully claimed ${formatAssetAmount(result.claimedAmount, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)} from ${result.validators.length} validators',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadStakingData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim rewards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _claimAndRestake() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Claim & Auto-Restake'),
            content: const Text(
              'This will claim all rewards and automatically restake them using the balanced strategy.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Proceed'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _loading = true);
      final result = await _stakingManager.claimAllRewards(
        assetId: widget.asset.id,
        autoRestake: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully claimed and restaked ${formatAssetAmount(result.claimedAmount, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadStakingData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim and restake: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _quickStake() async {
    final suggestions = await _stakingManager.getStakingSuggestions(
      widget.asset.id,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quick Stake'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended amount: ${formatAssetAmount(suggestions.recommendedAmount, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Expected annual returns: ${formatAssetAmount(suggestions.expectedReturns, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)}',
                ),
                const SizedBox(height: 8),
                Text('Risk level: ${suggestions.riskLevel.name}'),
                if (suggestions.warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Warnings:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...suggestions.warnings.map(
                    (w) => Text('• $w', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Stake Now'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _loading = true);
      final result = await _stakingManager.quickStake(
        assetId: widget.asset.id,
        amount: suggestions.recommendedAmount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully staked ${formatAssetAmount(result.amount, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)} across ${result.validators.length} validators',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadStakingData();
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stake: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showRebalanceDialog() async {
    final strategy = await showDialog<StakingStrategy>(
      context: context,
      builder:
          (context) =>
              _RebalanceDialog(currentInfo: _stakingInfo!, asset: widget.asset),
    );

    if (strategy == null) return;

    try {
      setState(() => _loading = true);
      final result = await _stakingManager.rebalanceStaking(
        assetId: widget.asset.id,
        strategy: strategy,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully rebalanced stake across ${result.validators.length} validators',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadStakingData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rebalance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  final _highCommissionThreshold = Decimal.parse('0.2');
  final _highVotingPowerThreshold = Decimal.parse('0.2');
  final _highUptimeThreshold = Decimal.parse('0.95');

  void _showHealthDetails(StakingState state) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Staking Health Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Status: ${state.health.name}'),
                const SizedBox(height: 16),
                if (state.positions.any((p) => p.validator.isJailed))
                  const Text(
                    '⚠️ One or more validators are jailed',
                    style: TextStyle(color: Colors.red),
                  ),
                if (state.positions.any(
                  (p) => p.validator.commission > _highCommissionThreshold,
                ))
                  const Text(
                    '⚠️ High commission rates',
                    style: TextStyle(color: Colors.orange),
                  ),
                if (state.positions.any(
                  (p) => p.validator.votingPower > _highVotingPowerThreshold,
                ))
                  const Text(
                    '⚠️ High validator concentration',
                    style: TextStyle(color: Colors.orange),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showUnstakeDialog(StakingPosition position) {
    showDialog<void>(
      context: context,
      builder:
          (context) => _UnstakeDialog(
            position: position,
            asset: widget.asset,
            stakingManager: _stakingManager,
            onUnstaked: () {
              Navigator.of(context).pop();
              _loadStakingData();
            },
          ),
    );
  }

  Future<void> _claimRewardsFromValidator(String validatorAddress) async {
    try {
      setState(() => _loading = true);
      await _stakingManager.claimRewards(
        widget.asset.id,
        ClaimingDetails(type: 'Cosmos', validatorAddress: validatorAddress),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully claimed rewards'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadStakingData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim rewards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}

// Stake form widget
class _StakeForm extends StatefulWidget {
  const _StakeForm({
    required this.asset,
    required this.stakingManager,
    required this.validators,
    required this.onStaked,
    required this.onRefreshValidators,
  });

  final Asset asset;
  final IStakingManager stakingManager;
  final List<ValidatorRecommendation> validators;
  final VoidCallback onStaked;
  final VoidCallback onRefreshValidators;

  @override
  State<_StakeForm> createState() => _StakeFormState();
}

class _StakeFormState extends State<_StakeForm> {
  StakingStrategy _selectedStrategy = StakingStrategy.balanced;
  Decimal? _amount;
  String? _selectedValidator;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<BalanceInfo>(
          future: context.read<KomodoDefiSdk>().balances.getBalance(
            widget.asset.id,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            return StakeAmountInput(
              asset: widget.asset,
              availableBalance: snapshot.data!.spendable,
              onAmountChanged: (amount) => setState(() => _amount = amount),
            );
          },
        ),
        const SizedBox(height: 24),
        StakingStrategySelector(
          selectedStrategy: _selectedStrategy,
          onStrategyChanged:
              (strategy) => setState(() {
                _selectedStrategy = strategy;
                _selectedValidator = null;
              }),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended Validators',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : widget.onRefreshValidators,
              tooltip: 'Refresh validators',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.validators.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No validators available. Please check your connection or try refreshing.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        else
          ...widget.validators
              .take(5)
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ValidatorListItem(
                    validator: rec.validator,
                    isSelected: _selectedValidator == rec.validator.address,
                    onTap:
                        () => setState(
                          () => _selectedValidator = rec.validator.address,
                        ),
                    showScore: true,
                    score: rec.score,
                    recommendation: rec,
                  ),
                ),
              ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _amount != null &&
                        !_loading &&
                        (_selectedValidator != null ||
                            _selectedStrategy != StakingStrategy.custom)
                    ? _stake
                    : null,
            child:
                _loading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Stake'),
          ),
        ),
      ],
    );
  }

  Future<void> _stake() async {
    if (_amount == null) return;

    // Validate first
    final validation = await widget.stakingManager.validateStaking(
      assetId: widget.asset.id,
      amount: _amount!,
      validatorAddress: _selectedValidator,
    );

    if (!validation.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.issues.first.message),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await widget.stakingManager.stake(
        assetId: widget.asset.id,
        amount: _amount!,
        validatorAddress: _selectedValidator,
        strategy: _selectedStrategy,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully staked ${formatAssetAmount(_amount!, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)} with expected APY of ${result.expectedAPY.toStringAsFixed(2)}%',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onStaked();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stake: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}

// Unstake dialog
class _UnstakeDialog extends StatefulWidget {
  const _UnstakeDialog({
    required this.position,
    required this.asset,
    required this.stakingManager,
    required this.onUnstaked,
  });

  final StakingPosition position;
  final Asset asset;
  final IStakingManager stakingManager;
  final VoidCallback onUnstaked;

  @override
  State<_UnstakeDialog> createState() => _UnstakeDialogState();
}

class _UnstakeDialogState extends State<_UnstakeDialog> {
  Decimal? _amount;
  bool _unstakeAll = true;
  bool _claimRewards = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unstake'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validator: ${widget.position.validator.name ?? widget.position.validatorAddress}',
          ),
          const SizedBox(height: 8),
          Text(
            'Currently staked: ${formatAssetAmount(widget.position.stakedAmount, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)}',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Unstake all'),
            value: _unstakeAll,
            onChanged:
                (value) => setState(() {
                  _unstakeAll = value;
                  if (value) _amount = null;
                }),
          ),
          if (!_unstakeAll)
            StakeAmountInput(
              asset: widget.asset,
              availableBalance: widget.position.stakedAmount,
              onAmountChanged: (amount) => setState(() => _amount = amount),
              label: 'Amount to unstake',
              showBalance: false,
              reserveForFees: false,
            ),
          if (widget.position.rewards.compareTo(Decimal.zero) > 0)
            CheckboxListTile(
              title: const Text('Claim rewards first'),
              subtitle: Text(
                '${formatAssetAmount(widget.position.rewards, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)} available',
              ),
              value: _claimRewards,
              onChanged: (value) => setState(() => _claimRewards = value!),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unstaking will take approximately 21 days to complete',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              !_loading && (_unstakeAll || _amount != null) ? _unstake : null,
          child:
              _loading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Unstake'),
        ),
      ],
    );
  }

  Future<void> _unstake() async {
    setState(() => _loading = true);

    try {
      final result = await widget.stakingManager.unstake(
        assetId: widget.asset.id,
        amount: _unstakeAll ? null : _amount,
        validatorAddress: widget.position.validatorAddress,
        claimRewards: _claimRewards,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully unstaked ${formatAssetAmount(result.amount, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)}. Completion: ${result.completionTime.toLocal()}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUnstaked();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unstake: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}

// Rebalance dialog
class _RebalanceDialog extends StatefulWidget {
  const _RebalanceDialog({required this.currentInfo, required this.asset});

  final StakingInfo currentInfo;
  final Asset asset;

  @override
  State<_RebalanceDialog> createState() => _RebalanceDialogState();
}

class _RebalanceDialogState extends State<_RebalanceDialog> {
  StakingStrategy _selectedStrategy = StakingStrategy.balanced;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rebalance Stake'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current total staked: ${formatAssetAmount(widget.currentInfo.totalStaked, widget.asset.id.chainId.decimals ?? 8, symbol: widget.asset.id.id)}',
          ),
          const SizedBox(height: 8),
          Text(
            'Currently delegated to ${widget.currentInfo.validators.length} validators',
          ),
          const SizedBox(height: 16),
          const Text('Select new strategy:'),
          const SizedBox(height: 12),
          StakingStrategySelector(
            selectedStrategy: _selectedStrategy,
            onStrategyChanged:
                (strategy) => setState(() => _selectedStrategy = strategy),
            showDescriptions: false,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rebalancing may involve unstaking from some validators which will trigger unbonding periods',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedStrategy),
          child: const Text('Rebalance'),
        ),
      ],
    );
  }
}
