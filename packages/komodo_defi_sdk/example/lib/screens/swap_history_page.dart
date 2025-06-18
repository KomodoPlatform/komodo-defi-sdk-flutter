import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_sdk/src/swaps/swap_history_manager.dart' as history;

class SwapHistoryScreen extends StatefulWidget {
  const SwapHistoryScreen({super.key});

  @override
  State<SwapHistoryScreen> createState() => _SwapHistoryScreenState();
}

class _SwapHistoryScreenState extends State<SwapHistoryScreen> {
  List<SwapStatus> _swaps = [];
  history.SwapHistoryPage? _swapHistoryPage;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSwapHistory();
  }

  Future<void> _loadSwapHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sdk = context.read<KomodoDefiSdk>();
      final swapHistoryPage = await sdk.swapHistory.getSwapHistory();

      setState(() {
        _swapHistoryPage = swapHistoryPage;
        _swaps = swapHistoryPage.swaps;
        _isLoading = false;
      });
    } catch (e, s) {
      setState(() {
        _error = 'Failed to load swap history: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshHistory() async {
    await _loadSwapHistory();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Swap History'),
            if (_swapHistoryPage != null)
              Text(
                'Page ${_swapHistoryPage!.currentPage} of '
                '${_swapHistoryPage!.totalPages} '
                '(${_swapHistoryPage!.total} total)',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _refreshHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: SwapHistoryBody(
        isLoading: _isLoading,
        error: _error,
        swaps: _swaps,
        swapHistoryPage: _swapHistoryPage,
        onRefresh: _refreshHistory,
        onCopyToClipboard: _copyToClipboard,
      ),
    );
  }
}

class SwapHistoryBody extends StatelessWidget {
  const SwapHistoryBody({
    required this.isLoading,
    required this.error,
    required this.swaps,
    required this.swapHistoryPage,
    required this.onRefresh,
    required this.onCopyToClipboard,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final List<SwapStatus> swaps;
  final history.SwapHistoryPage? swapHistoryPage;
  final VoidCallback onRefresh;
  final void Function(String text, String label) onCopyToClipboard;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SwapHistoryLoadingView();
    }

    if (error != null) {
      return SwapHistoryErrorView(error: error!, onRetry: onRefresh);
    }

    if (swaps.isEmpty) {
      return SwapHistoryEmptyView(swapHistoryPage: swapHistoryPage);
    }

    return SwapHistoryListView(
      swaps: swaps,
      swapHistoryPage: swapHistoryPage,
      onRefresh: onRefresh,
      onCopyToClipboard: onCopyToClipboard,
    );
  }
}

class SwapHistoryLoadingView extends StatelessWidget {
  const SwapHistoryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading swap history...'),
        ],
      ),
    );
  }
}

class SwapHistoryErrorView extends StatelessWidget {
  const SwapHistoryErrorView({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class SwapHistoryEmptyView extends StatelessWidget {
  const SwapHistoryEmptyView({required this.swapHistoryPage, super.key});

  final history.SwapHistoryPage? swapHistoryPage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No swap history found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your completed and in-progress swaps will appear here',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (swapHistoryPage != null && swapHistoryPage!.total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Total swaps available: ${swapHistoryPage!.total}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class SwapHistoryListView extends StatelessWidget {
  const SwapHistoryListView({
    required this.swaps,
    required this.swapHistoryPage,
    required this.onRefresh,
    required this.onCopyToClipboard,
    super.key,
  });

  final List<SwapStatus> swaps;
  final history.SwapHistoryPage? swapHistoryPage;
  final VoidCallback onRefresh;
  final void Function(String text, String label) onCopyToClipboard;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Column(
        children: [
          if (swapHistoryPage != null)
            SwapHistoryPaginationInfo(swapHistoryPage: swapHistoryPage!),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: swaps.length,
              itemBuilder:
                  (context, index) => SwapCard(
                    swap: swaps[index],
                    onCopyToClipboard: onCopyToClipboard,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class SwapHistoryPaginationInfo extends StatelessWidget {
  const SwapHistoryPaginationInfo({required this.swapHistoryPage, super.key});

  final history.SwapHistoryPage swapHistoryPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${swapHistoryPage.foundRecords}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text('Found', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${swapHistoryPage.total}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text('Total', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${swapHistoryPage.currentPage}/${swapHistoryPage.totalPages}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text('Page', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwapCard extends StatelessWidget {
  const SwapCard({
    required this.swap,
    required this.onCopyToClipboard,
    super.key,
  });

  final SwapStatus swap;
  final void Function(String text, String label) onCopyToClipboard;

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getSwapStatus(SwapStatus swap) {
    if (swap.isFinished == true) {
      return swap.errorEvents.isNotEmpty ? 'Failed' : 'Completed';
    }
    return 'In Progress';
  }

  Color _getStatusColor(SwapStatus swap) {
    if (swap.isFinished == true) {
      return swap.errorEvents.isNotEmpty ? Colors.red : Colors.green;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final myInfo = swap.myInfo;
    final startTime = myInfo?.startedAt ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${myInfo?.myCoin ?? swap.makerCoin} → '
                    '${myInfo?.otherCoin ?? swap.takerCoin}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (startTime > 0)
                    Text(
                      _formatTimestamp(startTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(swap).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(swap)),
              ),
              child: Text(
                _getSwapStatus(swap),
                style: TextStyle(
                  color: _getStatusColor(swap),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Amount: ${myInfo?.myAmount ?? swap.makerAmount}'),
            Text('Receive: ${myInfo?.otherAmount ?? swap.takerAmount}'),
          ],
        ),
        children: [
          SwapCardDetails(swap: swap, onCopyToClipboard: onCopyToClipboard),
        ],
      ),
    );
  }
}

class SwapCardDetails extends StatelessWidget {
  const SwapCardDetails({
    required this.swap,
    required this.onCopyToClipboard,
    super.key,
  });

  final SwapStatus swap;
  final void Function(String text, String label) onCopyToClipboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwapDetailRow(
            label: 'UUID',
            value: swap.uuid,
            onCopyToClipboard: onCopyToClipboard,
          ),
          SwapDetailRow(
            label: 'Type',
            value: swap.type,
            onCopyToClipboard: onCopyToClipboard,
          ),
          if (swap.makerCoinUsdPrice != null)
            SwapDetailRow(
              label: 'Maker USD Price',
              value: '\$${swap.makerCoinUsdPrice}',
              onCopyToClipboard: onCopyToClipboard,
            ),
          if (swap.takerCoinUsdPrice != null)
            SwapDetailRow(
              label: 'Taker USD Price',
              value: '\$${swap.takerCoinUsdPrice}',
              onCopyToClipboard: onCopyToClipboard,
            ),
          if (swap.errorEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            SwapEventsList(
              title: 'Errors:',
              events: swap.errorEvents,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
          if (swap.successEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SwapEventsList(
              title: 'Success Events:',
              events: [],
              color: Colors.green,
            ),
            ...swap.successEvents.map(
              (event) =>
                  Text('• $event', style: const TextStyle(color: Colors.green)),
            ),
          ],
        ],
      ),
    );
  }
}

class SwapDetailRow extends StatelessWidget {
  const SwapDetailRow({
    required this.label,
    required this.value,
    required this.onCopyToClipboard,
    super.key,
  });

  final String label;
  final String value;
  final void Function(String text, String label) onCopyToClipboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onCopyToClipboard(value, label),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SwapEventsList extends StatelessWidget {
  const SwapEventsList({
    required this.title,
    required this.events,
    required this.color,
    super.key,
  });

  final String title;
  final List<String> events;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        ...events.map(
          (event) => Text('• $event', style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
