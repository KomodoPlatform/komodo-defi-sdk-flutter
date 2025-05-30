import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/swap_bloc.dart';

class BestOrdersTable extends StatelessWidget {
  const BestOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapBloc, SwapState>(
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
            rows.add(
              DataRow(
                cells: [
                  DataCell(Text(pair)),
                  DataCell(Text(order.price.decimal ?? '')),
                  DataCell(Text(order.baseMaxVolume.decimal ?? '')),
                ],
              ),
            );
          }
        });
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Pair')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Vol')),
            ],
            rows: rows,
          ),
        );
      },
    );
  }
}
