// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:postman_collection/postman_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestPlayground extends StatefulWidget {
  final Future<String> Function(Map<String, dynamic> payload) executeRequest;

  const RequestPlayground({super.key, required this.executeRequest});

  @override
  _RequestPlaygroundState createState() => _RequestPlaygroundState();
}

class _RequestPlaygroundState extends State<RequestPlayground> {
  late PostmanCollection _collection;
  late final List<PostmanCollectionItem> _requests = [];
  int _selectedRequestIndex = 0;
  late Map<String, dynamic> _jsonData = {};
  String _response = '';
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadCollection();
    _loadHistory();
  }

  Future<void> _loadCollection() async {
    setState(() => _isLoading = true);
    try {
      final defaultBundle = DefaultAssetBundle.of(context);

      final prefs = await SharedPreferences.getInstance();
      String? storedConfig = prefs.getString('postman_config');
      storedConfig = null; // Remove this line to use stored config

      if (storedConfig == null) {
        // Load the default configuration from assets
        String jsonString = await defaultBundle
            .loadString('assets/komodo_defi.postman_collection.json');

        _collection = PostmanCollection.fromJson(
          parseJsonWithCommentStripping(jsonString),
        );
      } else {
        _collection = PostmanCollection.fromJson(
          parseJsonWithCommentStripping(storedConfig),
        );
      }

      _extractRequests(_collection.item);
      _selectRequest(0);
    } catch (e) {
      _showErrorDialog('Failed to load collection: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String stripJsonComments(String input) {
    RegExp regex = RegExp(
      r'\\"|"(?:\\"|[^"])*"|(//.*|/\*[\s\S]*?\*/)',
      multiLine: true,
    );

    return input.replaceAllMapped(regex, (match) {
      if (match.group(1) == null) {
        // This is a string literal, keep it as is
        return match.group(0)!;
      } else {
        // This is a comment, remove it
        return '';
      }
    });
  }

  dynamic parseJsonWithCommentStripping(String jsonString) {
    String strippedJson = stripJsonComments(jsonString);
    return json.decode(strippedJson);
  }

  void _extractRequests(List<PostmanCollectionItem> items) {
    for (var item in items) {
      if (item.item != null) {
        _extractRequests(item.item!);
      } else if (item.request != null) {
        _requests.add(item);
      }
    }
  }

  void _selectRequest(int index) {
    setState(() {
      _selectedRequestIndex = index;
      String rawBody =
          jsonDecode(jsonEncode(_requests[index].request?.body))['raw'] ?? '{}';
      try {
        _jsonData = parseJsonWithCommentStripping(rawBody);
      } catch (e) {
        print('Error parsing JSON for request: ${_requests[index].name}');
        _jsonData = {};
      }
      print('Selected request: ${_requests[index].name}');
      _response = ''; // Clear previous response
    });
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? historyString = prefs.getString('request_history');
      if (historyString != null) {
        setState(() {
          _history =
              List<Map<String, dynamic>>.from(json.decode(historyString));
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to load history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('request_history', json.encode(_history));
    } catch (e) {
      _showErrorDialog('Failed to save history: $e');
    }
  }

  Future<void> _executeRequest() async {
    setState(() => _isSending = true);
    try {
      String response = await widget.executeRequest(_jsonData);
      setState(() {
        _response = response;
        _history.add({
          'request': _jsonData,
          'response': response,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      await _saveHistory();
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
      // _showErrorDialog('Failed to execute request: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Postman collection: ${_collection.info.name}'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_requests[index].name),
                  selected: index == _selectedRequestIndex,
                  onTap: () => _selectRequest(index),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isSending ? null : _executeRequest,
                      label: _isSending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send'),
                      icon: const Icon(Icons.send),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                HistoryScreen(history: _history),
                          ),
                        );
                      },
                      label: const Text('History'),
                      icon: const Icon(Icons.history),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      label: const Text('Upload Collection'),
                      icon: const Icon(Icons.upload_file),
                      // onPressed: _onUploadCollection,
                      onPressed: null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: JsonEditor(
                    key: Key(_selectedRequestIndex.toString()),
                    json: jsonEncode(_jsonData),
                    onChanged: (value) {
                      setState(() {
                        _jsonData = value;
                      });
                    },
                    themeColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(_response),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onUploadCollection() async {
    // TODO! Implement this method
  }
}
// HistoryScreen and HistoryDetailScreen remain unchanged

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[history.length - 1 - index];
          return ListTile(
            title: Text('Request ${history.length - index}'),
            subtitle: Text(item['timestamp']),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HistoryDetailScreen(item: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Request:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                const JsonEncoder.withIndent('  ').convert(item['request']),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(item['response']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
