import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class RecipientAddressField extends StatefulWidget {
  const RecipientAddressField({
    required this.address,
    required this.onChanged,
    this.onQrScanned,
    this.validation,
    this.isValidating = false,
    this.errorText,
    this.asset,
    super.key,
  });

  final String address;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onQrScanned;
  final AddressValidation? validation;
  final bool isValidating;

  /// Optional error text override
  /// If provided, this will be displayed instead of the default validation.
  final String? Function()? errorText;
  final Asset? asset;

  @override
  State<RecipientAddressField> createState() => _RecipientAddressFieldState();
}

class _RecipientAddressFieldState extends State<RecipientAddressField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _showPasteButton = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.address);
    _focusNode.addListener(_onFocusChange);

    // Update paste button visibility based on initial text
    _showPasteButton = widget.address.isEmpty;
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void didUpdateWidget(RecipientAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.address != _controller.text) {
      _controller.text = widget.address;
      _showPasteButton = widget.address.isEmpty;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      _controller.text = clipboardData.text!;
      widget.onChanged(clipboardData.text!);
      setState(() {
        _showPasteButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = widget.validation?.isValid ?? false;
    final hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recipient Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.asset != null)
              Text(
                'Network: ${widget.asset!.id.chainId.formattedChainId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Enter recipient address or scan QR code',
            filled: true,
            fillColor:
                _hasFocus
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surface.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _getStatusColor(theme)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _getStatusColor(theme)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 2, color: _getStatusColor(theme)),
            ),
            prefixIcon:
                hasText && isValid
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showPasteButton)
                  TextButton(
                    onPressed: _pasteFromClipboard,
                    child: const Text('Paste'),
                  )
                else if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      setState(() {
                        _showPasteButton = true;
                      });
                    },
                    tooltip: 'Clear',
                  ),
                const SizedBox(width: 4),
                if (widget.onQrScanned != null)
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanQrCode,
                    tooltip: 'Scan QR code',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                _buildStatusIndicator(),
              ],
            ),
            errorText: _getErrorText(),
          ),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {
              _showPasteButton = value.isEmpty;
            });
          },
          style: theme.textTheme.bodyLarge,
        ),
        if (_shouldShowValidationMessage()) ...[
          const SizedBox(height: 8),
          _buildValidationMessage(),
        ],
        if (hasText && isValid) ...[
          const SizedBox(height: 8),
          _buildAddressPreview(),
        ],
      ],
    );
  }

  Color _getStatusColor(ThemeData theme) {
    if (widget.isValidating) return theme.colorScheme.primary;
    if (_controller.text.isEmpty) return theme.colorScheme.outline;
    if (widget.errorText?.call() != null) return theme.colorScheme.error;
    if (widget.validation != null) {
      return widget.validation!.isValid
          ? theme.colorScheme.primary
          : theme.colorScheme.error;
    }
    return theme.colorScheme.outline;
  }

  bool _shouldShowValidationMessage() {
    return widget.validation != null &&
        !widget.validation!.isValid &&
        widget.validation!.invalidReason != null &&
        _controller.text.isNotEmpty;
  }

  Widget _buildStatusIndicator() {
    final theme = Theme.of(context);

    // Show loading indicator while validating
    if (widget.isValidating) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return const SizedBox(width: 4);
  }

  String? _getErrorText() {
    if (_controller.text.isEmpty) {
      return null;
    }

    // Check for error override first
    final errorOverride = widget.errorText?.call();
    if (errorOverride != null) {
      return errorOverride;
    }

    // Show validation error if address is invalid
    if (widget.validation != null &&
        !widget.validation!.isValid &&
        _controller.text.isNotEmpty) {
      return widget.validation!.invalidReason ?? 'Invalid address format';
    }

    return null;
  }

  Widget _buildValidationMessage() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.validation!.invalidReason!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPreview() {
    final theme = Theme.of(context);

    // Display only the start and end of the address for clarity
    final address = _controller.text;
    final previewAddress =
        address.length > 16
            ? '${address.substring(0, 8)}...${address.substring(address.length - 8)}'
            : address;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Valid address: $previewAddress',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address copied to clipboard')),
              );
            },
            tooltip: 'Copy address',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _scanQrCode() async {
    // Placeholder for QR code scanning functionality
    // In production, this would call the device's QR scanner

    // For demo purposes, simulate a successful scan
    await Future.delayed(const Duration(seconds: 1));
    const scannedAddress = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

    if (mounted) {
      widget.onQrScanned?.call(scannedAddress);
      setState(() {
        _showPasteButton = false;
      });
    }
  }
}
