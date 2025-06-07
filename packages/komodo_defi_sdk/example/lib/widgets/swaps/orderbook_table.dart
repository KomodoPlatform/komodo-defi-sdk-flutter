import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/swap/swap_bloc.dart';

class OrderbookTable extends StatelessWidget {
  const OrderbookTable({super.key});

  String _formatNumber(String? value) {
    if (value == null || value.isEmpty) return '0.00000000';

    try {
      final number = double.parse(value);
      return number.toStringAsFixed(8);
    } catch (e) {
      return value; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
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
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'Orderbook',
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

                return Row(
                  children: [
                    // Asks table
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                            child: Text(
                              'Asks',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DataTable(
                                    columnSpacing: 16,
                                    horizontalMargin: 24,
                                    dataRowMinHeight: 40,
                                    dataRowMaxHeight: double.infinity,
                                    columns: const [
                                      DataColumn(label: Text('Coin')),
                                      DataColumn(label: Text('Price')),
                                      DataColumn(label: Text('Volume')),
                                      DataColumn(label: Text('Mine')),
                                    ],
                                    rows:
                                        book.asks
                                            .map(
                                              (ask) => DataRow(
                                                cells: [
                                                  DataCell(Text(ask.coin)),
                                                  DataCell(
                                                    Text(
                                                      _formatNumber(
                                                        ask.price.decimal,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      _formatNumber(
                                                        ask
                                                            .baseMaxVolume
                                                            .decimal,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ask.isMine
                                                        ? const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                          size: 16,
                                                        )
                                                        : const SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      width: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    // Bids table
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                            child: Text(
                              'Bids',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DataTable(
                                    columnSpacing: 16,
                                    horizontalMargin: 16,
                                    dataRowMinHeight: 40,
                                    dataRowMaxHeight: double.infinity,
                                    columns: const [
                                      DataColumn(label: Text('Coin')),
                                      DataColumn(label: Text('Price')),
                                      DataColumn(label: Text('Volume')),
                                      DataColumn(label: Text('Mine')),
                                    ],
                                    rows:
                                        book.bids
                                            .map(
                                              (bid) => DataRow(
                                                cells: [
                                                  DataCell(Text(bid.coin)),
                                                  DataCell(
                                                    Text(
                                                      _formatNumber(
                                                        bid.price.decimal,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      _formatNumber(
                                                        bid
                                                            .baseMaxVolume
                                                            .decimal,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    bid.isMine
                                                        ? const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                          size: 16,
                                                        )
                                                        : const SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
