import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

import '../blocs/swap_bloc.dart';

class BuyAssetDropdown extends StatelessWidget {
  const BuyAssetDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = context.select<KomodoDefiSdk, List<Asset>>((sdk) {
      final list = sdk.assets.available.values.toList();
      list.sort((a, b) => a.id.id.compareTo(b.id.id));
      return list;
    });
    return BlocBuilder<SwapBloc, SwapState>(
      buildWhen: (p, c) => p.buyAsset != c.buyAsset,
      builder: (context, state) {
        return DropdownButton<Asset>(
          isExpanded: true,
          value: state.buyAsset,
          hint: const Text('Buy Asset'),
          onChanged: (asset) {
            if (asset != null) {
              context.read<SwapBloc>().add(BuyAssetSelected(asset));
            }
          },
          items:
              assets
                  .map(
                    (asset) => DropdownMenuItem(
                      value: asset,
                      child: Text(asset.id.id),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
