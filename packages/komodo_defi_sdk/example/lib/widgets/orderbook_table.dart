import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/swap_bloc.dart';

class OrderbookTable extends StatelessWidget {
  const OrderbookTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapBloc, SwapState>(
      buildWhen:
          (p, c) =>
              p.orderbook != c.orderbook ||
              p.loadingOrderbook != c.loadingOrderbook,
      builder: (context, state) {
        if (state.loadingOrderbook) {
          return const Center(child: CircularProgressIndicator());
        }
        final book = state.orderbook;
        if (book == null) {
          return const Center(child: Text('Select assets'));
        }
        final rows = <DataRow>[];
        for (final ask in book.asks) {
          rows.add(
            DataRow(
              cells: [
                const DataCell(Text('Ask')),
                DataCell(Text(ask.price.decimal ?? '')),
                DataCell(Text(ask.baseMaxVolume.decimal ?? '')),
              ],
            ),
          );
        }
        for (final bid in book.bids) {
          rows.add(
            DataRow(
              cells: [
                const DataCell(Text('Bid')),
                DataCell(Text(bid.price.decimal ?? '')),
                DataCell(Text(bid.baseMaxVolume.decimal ?? '')),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Type')),
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
