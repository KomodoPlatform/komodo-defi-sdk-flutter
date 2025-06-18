import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/bridge/bridge_bloc.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_ui/komodo_ui.dart';

class TargetOrdersDropdown extends StatefulWidget {
  const TargetOrdersDropdown({super.key});

  @override
  State<TargetOrdersDropdown> createState() => _TargetOrdersDropdownState();
}

class _TargetOrdersDropdownState extends State<TargetOrdersDropdown> {
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
              previous.bestOrder != current.bestOrder ||
              previous.bestOrders != current.bestOrders ||
              previous.showTargetDropdown != current.showTargetDropdown,
      builder: (context, state) {
        final ordersMap =
            state.bestOrders?.orders ?? <String, List<OrderData>>{};
        final orders =
            ordersMap.values.expand((list) => list.cast<OrderData>()).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Protocol',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap:
                  orders.isNotEmpty
                      ? () {
                        context.read<BridgeBloc>().add(
                          BridgeShowTargetDropdown(!state.showTargetDropdown),
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
                      orders.isEmpty
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
                          state.bestOrder != null
                              ? Row(
                                children: [
                                  AssetIcon.ofTicker(
                                    state.bestOrder!.coin,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.bestOrder!.coin,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Price: ${state.bestOrder!.price.toDecimal()}',
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
                                orders.isEmpty
                                    ? 'No orders available'
                                    : 'Select target order...',
                                style: TextStyle(
                                  color:
                                      orders.isEmpty
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                    ),
                    if (orders.isNotEmpty)
                      Icon(
                        state.showTargetDropdown
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
            if (state.showTargetDropdown && orders.isNotEmpty) ...[
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
                          hintText: 'Search orders...',
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
                    // Filtered orders list
                    Flexible(
                      child: _buildTargetOrdersList(context, state, orders),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTargetOrdersList(
    BuildContext context,
    BridgeState state,
    List<OrderData> orders,
  ) {
    final filteredOrders =
        orders.where((order) {
          return order.coin.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    if (filteredOrders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No orders found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final isSelected = order.uuid == state.bestOrder?.uuid;

        return ListTile(
          leading: AssetIcon.ofTicker(order.coin, size: 32),
          title: Text(order.coin),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: ${order.price.toDecimal()}'),
              Text(
                'Volume: ${order.baseMinVolume.toDecimal()} - ${order.baseMaxVolume.toDecimal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          selected: isSelected,
          onTap: () {
            context.read<BridgeBloc>().add(BridgeSelectBestOrder(order));
          },
        );
      },
    );
  }
}
