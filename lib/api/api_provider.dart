import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'headers_provider.dart';

final apiProvider = Provider<ApiProvider>((ref) => ApiProvider(ref));

final apiUrl = "https://dummyjson.com";

class ApiProvider {
  final Ref ref;
  ApiProvider(this.ref);

  Future<http.Response> baseGet(String endpoint) async {
    final url = Uri.parse("$apiUrl$endpoint");
    final headers = await ref.read(headersProvider).token;
    final response = await http.get(url, headers: headers);
    return response;
  }

  Future<http.Response> basePost(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$apiUrl$endpoint");
    final headers = await ref.read(headersProvider).token;
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
    return response;
  }

  Future<http.Response> basePut(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$apiUrl$endpoint");
    final headers = await ref.read(headersProvider).token;
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
    return response;
  }

  Future<http.Response> baseDelete(String endpoint) async {
    final url = Uri.parse("$apiUrl$endpoint");
    final headers = await ref.read(headersProvider).token;
    final response = await http.delete(url, headers: headers);
    return response;
  }

  Future<http.Response> basePatch(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$apiUrl$endpoint");
    final headers = await ref.read(headersProvider).token;
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
    return response;
  }

  Future<http.Response> basePostWithFile(String endpoint, String path) async {
    final url = Uri.parse("$apiUrl$endpoint");
    final headers = await ref.read(headersProvider).token;
    final request = http.MultipartRequest('POST', url);
    request.headers['accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('file', path));
    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }
}
