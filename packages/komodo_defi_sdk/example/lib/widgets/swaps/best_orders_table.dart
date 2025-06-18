import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/swap/swap_bloc.dart';

class BestOrdersTable extends StatelessWidget {
  const BestOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'Best Orders',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 300,
            child: BlocBuilder<SwapBloc, SwapState>(
              buildWhen:
                  (p, c) =>
                      p.bestOrders != c.bestOrders ||
                      p.loadingBestOrders != c.loadingBestOrders,
              builder: (context, state) {
                if (state.loadingBestOrders) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = state.bestOrders;
                if (data == null) {
                  return const Center(child: Text('Select sell asset'));
                }
                final rows = <DataRow>[];
                data.orders.forEach((pair, orders) {
                  for (final order in orders) {
                    // Format decimal numbers to 8 decimal places
                    String formatDecimal(String? value) {
                      if (value == null || value.isEmpty) return '';
                      final number = double.tryParse(value);
                      if (number == null) return value;
                      return number.toStringAsFixed(8);
                    }

                    rows.add(
                      DataRow(
                        cells: [
                          DataCell(Text(pair)),
                          DataCell(Text(formatDecimal(order.price.decimal))),
                          DataCell(
                            Text(formatDecimal(order.baseMaxVolume.decimal)),
                          ),
                          DataCell(
                            order.isMine
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  }
                });
                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowMaxHeight: double.infinity,
                        columns: const [
                          DataColumn(label: Text('Pair')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Vol')),
                          DataColumn(label: Text('Is Mine')),
                        ],
                        rows: rows,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
