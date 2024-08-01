// TODO: Create an extension that eliminates the boilerplate code for
// making and parsing HTTP requests and logic needed for body.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'map_extension.dart';

extension HttpExtensions on http.Client {
  Future<JsonMap> getJsonMap(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw http.ClientException(
        '${response.statusCode}: ${response.reasonPhrase}',
        Uri.parse(url),
      );
    }
    return json.decode(response.body);
  }

  Future<List<JsonMap>> getJsonList(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw http.ClientException(
        '${response.statusCode}: ${response.reasonPhrase}',
        Uri.parse(url),
      );
    }

    final list = json.decode(response.body) as List;

    return list.cast<JsonMap>();
  }

  Future<http.Response> postJson(String url, dynamic body) async {
    final response = await post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post data to $url');
    }
    return response;
  }
}
