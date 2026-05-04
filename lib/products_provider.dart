import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final productsProvider = FutureProvider((ref) async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));
  final data = jsonDecode(response.body);
  return data['products'] as List;
});
