import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({
    required this.asset,
    required this.pubkeys,
    super.key,
  });

  final Asset asset;
  final AssetPubkeys pubkeys;

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  final _ibcChannelController = TextEditingController();

  late final _sdk = context.read<KomodoDefiSdk>();

  PubkeyInfo? _selectedFromAddress;
  bool _isMaxAmount = false;
  FeeInfo? _selectedFee;
  WithdrawalPreview? _preview;
  String? _error;
  bool _isIbcTransfer = false;

  AddressValidation? _addressValidation;
  Timer? _validationDebounce;

  @override
  void initState() {
    super.initState();
    _toAddressController.addListener(_onAddressChanged);
    if (widget.asset.supportsMultipleAddresses) {
      _selectedFromAddress = widget.pubkeys.keys.first;
    }
  }

  void _onAddressChanged() {
    // Clear validation when input changes
    setState(() => _addressValidation = null);

    // Cancel previous validation if it exists
    _validationDebounce?.cancel();

    final address = _toAddressController.text;
    if (address.isEmpty) return;

    // Start new validation after debounce
    _validationDebounce = Timer(const Duration(milliseconds: 500), () {
      _validateAddress(address);
    });
  }

  String? _addressValidator(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter recipient address';

    // If validation is in progress, consider it invalid
    if (_addressValidation == null) {
      return 'Validating address...';
    }

    // Return validation error if invalid
    if (!_addressValidation!.isValid) {
      return _addressValidation!.invalidReason ?? 'Invalid address format';
    }

    return null;
  }

  Future<void> _previewWithdrawal() async {
    if (_addressValidation == null) {
      setState(() => _error = 'Please wait for address validation to complete');
      return;
    }

    if (!_addressValidation!.isValid) {
      setState(
        () =>
            _error =
                _addressValidation!.invalidReason ?? 'Invalid address format',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _error = null);

      final params = WithdrawParameters(
        asset: widget.asset.id.id,
        toAddress: _toAddressController.text,
        amount: _isMaxAmount ? null : Decimal.parse(_amountController.text),
        fee: _selectedFee,
        from:
            _selectedFromAddress?.derivationPath != null
                ? WithdrawalSource.hdDerivationPath(
                  _selectedFromAddress!.derivationPath!,
                )
                : null,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        isMax: _isMaxAmount,
        ibcTransfer: _isIbcTransfer ? true : null,
      );

      final preview = await _sdk.withdrawals.previewWithdrawal(params);

      if (!mounted) return;

      setState(() {
        _preview = preview;
        _selectedFee = preview.fee;
      });

      await _showPreviewDialog(params);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _validationDebounce?.cancel();
    _toAddressController.removeListener(_onAddressChanged);
    _toAddressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _ibcChannelController.dispose();
    super.dispose();
  }

  Future<void> _showPreviewDialog(WithdrawParameters params) async {
    if (_preview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Withdrawal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount: ${_preview!.balanceChanges.netChange} '
                    '${widget.asset.id.id}',
                  ),
                  Text('To: ${_preview!.to.join(', ')}'),
                  _buildFeeDetails(_preview!.fee),
                  if (_preview!.kmdRewards != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'KMD Rewards Available: ${_preview!.kmdRewards!.amount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  if (_isIbcTransfer) ...[
                    const SizedBox(height: 8),
                    Text('IBC Channel: ${_ibcChannelController.text}'),
                    const Text(
                      'Note: IBC transfers may take longer to complete',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _executeWithdrawal(params);
    }
  }

  Widget _buildFeeDetails(FeeInfo details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Fee Details:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // If it's an ETH gas variant:
        if (details is FeeInfoEthGas) ...[
          Text('Gas: ${details.gas} units'),
          // If you're storing gasPrice in ETH, then you might print:
          Text('Gas Price: ${details.gasPrice} ETH/1gas'),
          // or convert to Gwei if you prefer
        ],

        if (details is FeeInfoQrc20Gas) ...[
          Text('Gas Limit: ${details.gasLimit}'),
          Text('Gas Price: ${details.gasPrice} (coin units)'),
        ],

        if (details is FeeInfoCosmosGas) ...[
          Text('Gas Limit: ${details.gasLimit}'),
          Text('Gas Price: ${details.gasPrice} (coin units)'),
        ],

        if (details is FeeInfoUtxoFixed) ...[
          Text('Amount: ${details.amount} ${details.coin} (fixed)'),
        ],
        if (details is FeeInfoUtxoPerKbyte) ...[
          Text('Amount per KB: ${details.amount} ${details.coin}'),
        ],

        const SizedBox(height: 4),
        Text(
          'Total Fee: ${details.totalFee} ${details.coin}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Future<void> _executeWithdrawal(WithdrawParameters params) async {
    try {
      await for (final progress in _sdk.withdrawals.withdraw(params)) {
        if (progress.status == WithdrawalStatus.complete) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Withdrawal completed: ${progress.withdrawalResult!.txHash}',
                ),
                action: SnackBarAction(
                  label: 'Copy Hash',
                  onPressed:
                      () => Clipboard.setData(
                        ClipboardData(text: progress.withdrawalResult!.txHash),
                      ),
                ),
              ),
            );
            Navigator.pop(context);
          }
          return;
        }

        if (progress.status == WithdrawalStatus.error) {
          throw Exception(progress.errorMessage);
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  bool get _isTendermintProtocol => widget.asset.protocol is TendermintProtocol;

  Future<void> _validateAddress(String address) async {
    try {
      final validation = await _sdk.addresses.validateAddress(
        asset: widget.asset,
        address: address,
      );

      if (mounted) {
        setState(() => _addressValidation = validation);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Address validation failed: $e');
      }
    }
  }

  bool isCustomFee = false;

  /// Convert Gwei -> ETH by dividing by 10^9
  static final Decimal _gweiToEth = Decimal.fromInt(1000000000);

  Widget _buildFeeSelection() {
    final protocol = widget.asset.protocol;

    if (protocol is Erc20Protocol) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gas Settings'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: isCustomFee,
                  decoration: const InputDecoration(
                    labelText: 'Gas Price (Gwei)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final gweiInput = Decimal.tryParse(value);
                    if (gweiInput != null) {
                      final ethPrice = gweiInput / _gweiToEth;

                      setState(() {
                        final oldFee = _selectedFee;

                        // Preserve whatever gas limit we had before if oldFee is ethGas
                        final oldGasLimit = oldFee?.maybeMap(
                          ethGas: (eth) => eth.gas,
                          orElse: () => 21000,
                        );

                        // Now create a new ethGas FeeInfo using the old gas limit.
                        _selectedFee = FeeInfo.ethGas(
                          coin: widget.asset.id.id,
                          gasPrice: ethPrice.toDecimal(),
                          gas: oldGasLimit ?? 21000,
                        );
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  enabled: isCustomFee,
                  decoration: const InputDecoration(labelText: 'Gas Limit'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final gasLimit = int.tryParse(value);
                    if (gasLimit != null) {
                      setState(() {
                        final oldFee = _selectedFee;
                        final oldGasPrice = oldFee?.maybeMap(
                          ethGas: (eth) => eth.gasPrice,
                          orElse: () => Decimal.parse('0.000000003'),
                        );

                        _selectedFee = FeeInfo.ethGas(
                          coin: widget.asset.id.id,
                          gasPrice: oldGasPrice ?? Decimal.parse('0.000000003'),
                          gas: gasLimit,
                        );
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // UTXO fee selection
    if (protocol is UtxoProtocol) {
      final defaultFee = protocol.txFee ?? 10000;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction Fee'),
          const SizedBox(height: 8),
          SegmentedButton<Decimal>(
            segments: [
              ButtonSegment(
                value: Decimal.parse(defaultFee.toString()),
                label: Text('Standard ($defaultFee)'),
              ),
              ButtonSegment(
                value: Decimal.parse((defaultFee * 2).toString()),
                label: Text('Fast (${defaultFee * 2})'),
              ),
              ButtonSegment(
                value: Decimal.parse((defaultFee * 5).toString()),
                label: Text('Urgent (${defaultFee * 5})'),
              ),
            ],
            selected: {
              if (_selectedFee != null)
                _selectedFee!.maybeMap(
                  utxoFixed: (f) => f.amount,
                  utxoPerKbyte: (p) => p.amount,
                  orElse: () => Decimal.zero,
                )
              else
                Decimal.parse(defaultFee.toString()),
            },
            onSelectionChanged:
                !isCustomFee
                    ? null
                    : (value) {
                      setState(() {
                        _selectedFee = FeeInfo.utxoFixed(
                          coin: widget.asset.id.id,
                          amount: value.first,
                        );
                      });
                    },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              // TODO: Check if wallet is currently in HD mode. Use KW coin
              // details' page address management as an example of how to
              // handle this.
              if (widget.asset.supportsMultipleAddresses) ...[
                DropdownButtonFormField<PubkeyInfo>(
                  value: _selectedFromAddress,
                  decoration: InputDecoration(
                    labelText: 'From Address',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _onCopyAddress(_selectedFromAddress),
                    ),
                  ),
                  items:
                      widget.pubkeys.keys
                          .map(
                            (addr) => DropdownMenuItem(
                              value: addr,
                              child: Text(
                                '${addr.address} (${addr.balance.spendable})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      widget.pubkeys.keys.any((k) => k.derivationPath == null)
                          ? null
                          : (value) =>
                              setState(() => _selectedFromAddress = value),
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select a source address'
                              : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _toAddressController,
                decoration: InputDecoration(
                  labelText: 'To Address',
                  hintText: 'Enter recipient address',
                  // Show validation status
                  suffixIcon: _buildValidationStatus(),
                ),
                validator: _addressValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              if (_isTendermintProtocol) ...[
                SwitchListTile(
                  title: const Text('IBC Transfer'),
                  subtitle: const Text('Send to another Cosmos chain'),
                  value: _isIbcTransfer,
                  onChanged: (value) => setState(() => _isIbcTransfer = value),
                ),
                if (_isIbcTransfer) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ibcChannelController,
                    decoration: const InputDecoration(
                      labelText: 'IBC Channel',
                      hintText: 'Enter IBC channel ID',
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty == true
                                ? 'Please enter IBC channel'
                                : null,
                  ),
                ],
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount to send',
                  suffix: Text(widget.asset.id.id),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !_isMaxAmount,
                validator: (value) {
                  if (_isMaxAmount) return null;
                  if (value?.isEmpty == true) return 'Please enter an amount';
                  final amount = Decimal.tryParse(value!);
                  if (amount == null) return 'Please enter a valid number';
                  if (amount <= Decimal.zero) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                value: _isMaxAmount,
                onChanged:
                    (value) => setState(() {
                      _isMaxAmount = value == true;
                      if (_isMaxAmount) {
                        _amountController.clear();
                      }
                    }),
                title: const Text('Send maximum amount'),
              ),
              const SizedBox(height: 16),
              Text('Fees', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Custom fee'),
                value: isCustomFee,
                onChanged: (value) => setState(() => isCustomFee = value),
              ),
              // Reusable fee input
              FeeInfoInput(
                asset: widget.asset,
                selectedFee: _selectedFee,
                isCustomFee: isCustomFee,
                onFeeSelected: (fee) {
                  setState(() => _selectedFee = fee);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'Memo (Optional)',
                  hintText: 'Enter optional transaction memo',
                  helperText: 'Required for some exchanges',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildTransactionSummary(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _previewWithdrawal,
                icon: const Icon(Icons.send),
                label: const Text('Preview Withdrawal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildValidationStatus() {
    if (_toAddressController.text.isEmpty) return null;

    if (_addressValidation == null) {
      return Container(
        padding: const EdgeInsets.all(4),
        width: 16,
        height: 16,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Icon(
      _addressValidation!.isValid ? Icons.check_circle : Icons.error,
      color:
          _addressValidation!.isValid
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
    );
  }

  void _onCopyAddress(PubkeyInfo? address) {
    if (address == null) return;

    Clipboard.setData(ClipboardData(text: address.address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard')),
    );
  }

  Widget _buildTransactionSummary() {
    final protocol = widget.asset.protocol;
    final balance = _selectedFromAddress?.balance ?? widget.pubkeys.balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Available Balance:'),
            Text(
              '${balance.spendable} ${widget.asset.id.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (balance.unspendable > Decimal.zero) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Locked:'),
              Text(
                '${balance.unspendable} ${widget.asset.id.id}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
        const Divider(),
        if (_selectedFee != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Fee:'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Text(_getFeeDisplay())],
              ),
            ],
          ),
        ],
        if (!_isMaxAmount && _amountController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount:'),
              Text(
                '${_amountController.text} ${widget.asset.id.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        if (_isIbcTransfer) ...[
          const Divider(),
          const Text(
            'IBC transfers may take several minutes to complete and require additional fees on the destination chain.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  String _getFeeDisplay() {
    final fee = _selectedFee;
    if (fee == null) return 'Calculating...';

    return switch (fee) {
      FeeInfoUtxoFixed(:final amount, :final coin) => '$amount $coin',
      FeeInfoUtxoPerKbyte(:final amount, :final coin) => '$amount $coin',
      FeeInfoEthGas(:final gasPrice, :final gas) =>
        '${(gasPrice * Decimal.fromInt(gas)) * Decimal.fromInt(1000000000)} Gwei',
      FeeInfoQrc20Gas(:final gasPrice, :final gasLimit, :final coin) =>
        '${gasPrice * Decimal.fromInt(gasLimit)} $coin',
      FeeInfoCosmosGas(:final gasPrice, :final gasLimit, :final coin) =>
        '${gasPrice * Decimal.fromInt(gasLimit)} $coin',
    };
  }
}

// Helper widget for fee selection
class FeeOption extends StatelessWidget {
  const FeeOption({
    required this.title,
    required this.subtitle,
    required this.fee,
    required this.isSelected,
    required this.onSelect,
    super.key,
  });

  final String title;
  final String subtitle;
  final WithdrawalFeeType fee;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onSelect(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
