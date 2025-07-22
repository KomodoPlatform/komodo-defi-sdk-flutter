// instance_asset_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, ReadContext;
import 'package:kdf_sdk_example/blocs/asset_market_info/asset_market_info_bloc.dart'
    show AssetMarketInfoBloc;
import 'package:kdf_sdk_example/widgets/assets/asset_item.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart' show KomodoDefiSdk;
import 'package:komodo_defi_types/komodo_defi_types.dart';

class InstanceAssetList extends StatelessWidget {
  const InstanceAssetList({
    required this.assets,
    required this.searchController,
    required this.onAssetSelected,
    required this.authOptions,
    super.key,
  });

  final List<Asset> assets;
  final TextEditingController searchController;
  final void Function(Asset) onAssetSelected;
  final AuthOptions authOptions;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssetMarketInfoBloc(sdk: context.read<KomodoDefiSdk>()),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Coins List (${assets.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                width: 200,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Search',
                    hintText: 'Search for an asset',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              key: const Key('asset_list'),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return AssetItemWidget(
                  key: Key(asset.id.id),
                  asset: asset,
                  authOptions: authOptions,
                  onTap: () => onAssetSelected(asset),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
