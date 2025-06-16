import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/bridge/bridge_bloc.dart';
import 'package:komodo_ui/komodo_ui.dart';

class SourceAssetDropdown extends StatefulWidget {
  const SourceAssetDropdown({super.key});

  @override
  State<SourceAssetDropdown> createState() => _SourceAssetDropdownState();
}

class _SourceAssetDropdownState extends State<SourceAssetDropdown> {
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
              previous.sellAsset != current.sellAsset ||
              previous.sourceAssets != current.sourceAssets ||
              previous.showSourceDropdown != current.showSourceDropdown,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source Protocol',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap:
                  state.sourceAssets.isNotEmpty
                      ? () {
                        context.read<BridgeBloc>().add(
                          BridgeShowSourceDropdown(!state.showSourceDropdown),
                        );
                      }
                      : null,
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
                  color:
                      state.sourceAssets.isEmpty
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                          state.sellAsset != null
                              ? Row(
                                children: [
                                  AssetIcon(state.sellAsset!.id, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.sellAsset!.id.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          state.sellAsset!.id.id,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                state.sourceAssets.isEmpty
                                    ? 'No assets available'
                                    : 'Select source protocol...',
                                style: TextStyle(
                                  color:
                                      state.sourceAssets.isEmpty
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                    ),
                    if (state.sourceAssets.isNotEmpty)
                      Icon(
                        state.showSourceDropdown
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
            if (state.showSourceDropdown && state.sourceAssets.isNotEmpty) ...[
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
                          hintText: 'Search assets...',
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
                    // Filtered asset list
                    Flexible(child: _buildSourceAssetList(context, state)),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSourceAssetList(BuildContext context, BridgeState state) {
    final filteredAssets =
        state.sourceAssets.where((asset) {
          return asset.id.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              asset.id.id.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    if (filteredAssets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No assets found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredAssets.length,
      itemBuilder: (context, index) {
        final asset = filteredAssets[index];
        final isSelected = asset.id.id == state.sellAsset?.id.id;

        return ListTile(
          leading: AssetIcon(asset.id, size: 32),
          title: Text(asset.id.name),
          subtitle: Text(asset.id.id),
          selected: isSelected,
          onTap: () {
            context.read<BridgeBloc>().add(BridgeSetSellAsset(asset));
          },
        );
      },
    );
  }
}
