import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final simpleProvider = NotifierProvider<SimpleNotifier, String>(SimpleNotifier.new);

class SimpleNotifier extends Notifier<String> {
  @override
  String build() => 'No Data Yet';

  Future<void> fetchOneProduct() async {
    state = 'Loading...';

    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products/1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = data['title'];
      } else {
        state = 'Failed to load product';
      }
    } catch (e) {
      state = 'Error: $e';
    }
  }
}
