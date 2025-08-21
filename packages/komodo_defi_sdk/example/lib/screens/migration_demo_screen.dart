import 'package:flutter/material.dart';

/// Placeholder demo screen for migration functionality
/// This is a temporary replacement to avoid build errors while
/// the migration system is being fixed
class MigrationDemoScreen extends StatelessWidget {
  const MigrationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Migration Feature',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The migration functionality is currently under development.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This feature will allow you to migrate assets between different wallet types.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Planned Features:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• Asset balance scanning'),
                      Text('• Migration preview'),
                      Text('• Safe asset transfer'),
                      Text('• Progress tracking'),
                      Text('• Result verification'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Main'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
