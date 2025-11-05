import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/devtools_data_bridge.dart';
import 'features/connection/bloc/vm_connection_bloc.dart';
import 'features/dashboard/view/home_view.dart';
import 'features/logs/bloc/logs_bloc.dart';
import 'features/rpc/bloc/rpc_metrics_bloc.dart';

class KomodoDevToolsApp extends StatefulWidget {
  const KomodoDevToolsApp({super.key});

  @override
  State<KomodoDevToolsApp> createState() => _KomodoDevToolsAppState();
}

class _KomodoDevToolsAppState extends State<KomodoDevToolsApp> {
  late final DevToolsDataBridge _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = DevToolsDataBridge();
  }

  @override
  void dispose() {
    unawaited(_bridge.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<DevToolsDataBridge>.value(
      value: _bridge,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                VmConnectionBloc(context.read<DevToolsDataBridge>())
                  ..add(const VmConnectionSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) =>
                LogsBloc(context.read<DevToolsDataBridge>())
                  ..add(const LogsSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) =>
                RpcMetricsBloc(context.read<DevToolsDataBridge>())
                  ..add(const RpcMetricsSubscriptionRequested()),
          ),
        ],
        child: const KomodoDevToolsHomeView(),
      ),
    );
  }
}
