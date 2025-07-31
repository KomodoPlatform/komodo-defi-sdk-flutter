import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AddressesSectionWidget extends StatelessWidget {
  const AddressesSectionWidget({
    required this.pubkeys,
    required this.onGenerateNewAddress,
    required this.cantCreateNewAddressReasons,
    this.isGeneratingAddress = false,
    super.key,
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
                      key: const Key('asset_addresses_list'),
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
