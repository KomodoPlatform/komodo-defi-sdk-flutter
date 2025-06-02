import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class AssetDropdown extends StatefulWidget {
  const AssetDropdown({
    required this.selectedAsset,
    required this.onChanged,
    required this.hintText,
    this.width = 300.0,
    this.maxHeight = 300.0,
    super.key,
  });

  final Asset? selectedAsset;
  final ValueChanged<Asset> onChanged;
  final String hintText;
  final double width;
  final double maxHeight;

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends State<AssetDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _currentOverlayEntry;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = context.select<KomodoDefiSdk, List<Asset>>((sdk) {
      final list =
          sdk.assets.available.values.toList()
            ..sort((a, b) => a.id.id.compareTo(b.id.id));
      return list;
    });

    // Filter assets based on search query
    final filteredAssets =
        assets.where((asset) {
          return asset.id.id.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: () {
          _toggleDropdown(context, filteredAssets);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (widget.selectedAsset != null) ...[
                AssetIcon(widget.selectedAsset!.id, size: 24),
                const SizedBox(width: 8),
                Text(widget.selectedAsset!.id.id),
              ] else
                Text(widget.hintText),
              const Spacer(),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown(BuildContext context, List<Asset> assets) {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown(context, assets);
    }
  }

  void _openDropdown(BuildContext context, List<Asset> assets) {
    setState(() {
      _isDropdownOpen = true;
      _searchQuery = '';
      _searchController.clear();
    });

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: widget.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 60),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                            _searchQuery = value;
                            // Rebuild the overlay with updated search results
                            _updateOverlay(context, assets);
                          },
                        ),
                      ),
                      // Filtered asset list
                      Flexible(child: _buildAssetList(context, assets)),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    // Store the overlay entry to remove it later
    _currentOverlayEntry = overlayEntry;
  }

  Widget _buildAssetList(BuildContext context, List<Asset> assets) {
    final filteredAssets =
        assets.where((asset) {
          return asset.id.id.toLowerCase().contains(_searchQuery.toLowerCase());
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
        final isSelected = widget.selectedAsset?.id.id == asset.id.id;

        return ListTile(
          selected: isSelected,
          leading: AssetIcon(asset.id, size: 24),
          title: Text(asset.id.id),
          onTap: () {
            widget.onChanged(asset);
            _closeDropdown();
          },
        );
      },
    );
  }

  void _updateOverlay(BuildContext context, List<Asset> assets) {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.markNeedsBuild();
    }
  }

  void _closeDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}
