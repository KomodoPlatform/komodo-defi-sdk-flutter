import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/bridge/bridge_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class TickerDropdown extends StatefulWidget {
  const TickerDropdown({super.key});

  @override
  State<TickerDropdown> createState() => _TickerDropdownState();
}

class _TickerDropdownState extends State<TickerDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BridgeBloc, BridgeState>(
      buildWhen:
          (previous, current) =>
              previous.selectedTicker != current.selectedTicker ||
              previous.availableTickers != current.availableTickers ||
              previous.showTickerDropdown != current.showTickerDropdown,
      builder: (context, state) {
        // Get representative assets for each ticker
        final assets = context.select<KomodoDefiSdk, Map<String, Asset>>((sdk) {
          final assetMap = <String, Asset>{};
          for (final ticker in state.availableTickers) {
            // Find first asset for this ticker
            final asset = sdk.assets.available.values.firstWhere(
              (asset) => _getTickerFromAsset(asset) == ticker,
              orElse: () => sdk.assets.available.values.first,
            );
            assetMap[ticker] = asset;
          }
          return assetMap;
        });

        final selectedAsset =
            state.selectedTicker != null ? assets[state.selectedTicker] : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Ticker',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                context.read<BridgeBloc>().add(
                  BridgeShowTickerDropdown(!state.showTickerDropdown),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                          selectedAsset != null
                              ? Row(
                                children: [
                                  AssetIcon(selectedAsset.id, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.selectedTicker!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                'Select ticker...',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                    ),
                    Icon(
                      state.showTickerDropdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (state.showTickerDropdown) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search tickers...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    // Filtered ticker list
                    Flexible(child: _buildTickerList(context, state, assets)),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTickerList(
    BuildContext context,
    BridgeState state,
    Map<String, Asset> assets,
  ) {
    final filteredTickers =
        state.availableTickers.where((ticker) {
          return ticker.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (assets[ticker]?.id.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();

    if (filteredTickers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No tickers found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredTickers.length,
      itemBuilder: (context, index) {
        final ticker = filteredTickers[index];
        final asset = assets[ticker];
        final isSelected = ticker == state.selectedTicker;

        return ListTile(
          leading: asset != null ? AssetIcon(asset.id, size: 32) : null,
          title: Text(ticker),
          subtitle: asset != null ? Text(asset.id.name) : null,
          selected: isSelected,
          onTap: () {
            context.read<BridgeBloc>().add(BridgeTickerChanged(ticker));
          },
        );
      },
    );
  }

  String? _getTickerFromAsset(Asset asset) {
    // Simple ticker extraction - matches the logic in BridgeBloc
    final name = asset.id.name.toUpperCase();
    if (name.contains('-')) {
      return name.split('-')[0];
    }
    return name;
  }
}
