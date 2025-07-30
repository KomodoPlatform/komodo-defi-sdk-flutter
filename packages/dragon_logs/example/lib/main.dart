// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:dragon_logs/dragon_logs.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DragonLogs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LogDemoPage(),
    );
  }
}

class LogDemoPage extends StatefulWidget {
  const LogDemoPage({super.key});

  @override
  State<LogDemoPage> createState() => _LogDemoPageState();
}

class _LogDemoPageState extends State<LogDemoPage> {
  late final Timer periodicMetricsTimer;
  bool isLoading = false;

  static const int itemCount = 10 * 1000;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored logs demo'),
        backgroundColor: isLoading ? Colors.purple : null,
        leading: isLoading
            ? Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : null,
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => isLoading = true);

                  for (var i = 0; i < itemCount; i++) {
                    log('${('$i')} This is a log');
                  }

                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Logged 10k items',
                        ),
                      ),
                    );

                  setState(() => isLoading = false);
                },
                child: const Text('Log 10k items'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final stopWatch = Stopwatch()..start();

                  // ignore: unused_local_variable
                  final string = await DragonLogs.exportLogsStream()
                      .asyncMap((event) => event)
                      .join();

                  stopWatch.stop();

                  final size = await DragonLogs.getLogFolderSize();

                  final message =
                      'Read logs in ${stopWatch.elapsedMilliseconds}ms. '
                      'Log size: ${size ~/ 1024} KB';

                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(content: Text(message)),
                    );

                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text('Read logs'),
              ),

              // Button to download logs
              ElevatedButton(
                onPressed: () async {
                  setState(() => isLoading = true);

                  await DragonLogs.exportLogsToDownload();

                  final size = await DragonLogs.getLogFolderSize();

                  final message = 'Downloaded logs in {unknown} ms. '
                      'Log size: ${size ~/ 1024} KB';

                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(content: Text(message)),
                    );

                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text('Download logs'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    periodicMetricsTimer.cancel();
    super.dispose();
  }
}
