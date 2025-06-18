import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/bridge/bridge_bloc.dart';
import 'package:kdf_sdk_example/widgets/bridge/bridge_form.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

class BridgePage extends StatelessWidget {
  const BridgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              BridgeBloc(context.read<KomodoDefiSdk>())
                ..add(const BridgeInit(ticker: 'BTC')),
      child: const _BridgeView(),
    );
  }
}

class _BridgeView extends StatelessWidget {
  const _BridgeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge Assets'),
        actions: [
          BlocBuilder<BridgeBloc, BridgeState>(
            buildWhen: (previous, current) => previous.step != current.step,
            builder: (context, state) {
              if (state.step == BridgeStep.form) {
                return IconButton(
                  onPressed: () {
                    context.read<BridgeBloc>().add(const BridgeClear());
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Form',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth * 0.03;
          final verticalPadding = constraints.maxHeight * 0.03;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: const SingleChildScrollView(
              child: Column(
                children: [BridgeHeader(), SizedBox(height: 16), BridgeForm()],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BridgeHeader extends StatelessWidget {
  const BridgeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Bridge Assets Between Protocols',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Trade the same asset across different blockchain protocols using atomic swaps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
