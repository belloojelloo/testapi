import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ProductsNotifier extends Notifier<List> {
  @override
  List build() => [];

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products'),
    );
    final data = jsonDecode(response.body);
    state = data['products'] as List;
  }

  Future<void> deleteProduct(int index) async {
    await http.delete(Uri.parse('https://dummyjson.com/products/$index'));
    state = state.where((p) => p['id'] != index).toList();
  }
}
