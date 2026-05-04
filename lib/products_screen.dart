import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:testproject/products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                ref.invalidate(productsProvider);
              },
              child: const Text('Refresh Products'),
            ),
            Expanded(
              child: result.when(
                data: (data) => ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(data[index]['title'].toString())),
                ),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
