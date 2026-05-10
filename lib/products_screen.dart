import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/api_provider.dart';
import 'dart:convert';

final productsProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await ref.read(apiProvider).baseGet('/products');
  return jsonDecode(response.body)['products'] as List<dynamic>;
});

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Center(
        child: items.when(
          data: (value) {
            return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                final product = value[index];
                return ListTile(
                  title: Text(product['title'].toString()),
                  subtitle: Text('\$${product['price'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          final titleController = TextEditingController(
                            text: product['title'].toString(),
                          );

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Edit Product'),
                              content: TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(apiProvider)
                                        .basePut('/products/${product['id']}', {
                                          'title': titleController.text,
                                        })
                                        .then((response) {
                                          print(
                                            'PUT Status Code: ${response.statusCode}',
                                          );
                                        });

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(apiProvider)
                              .baseDelete('/products/${product['id']}');
                          ref.invalidate(productsProvider);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(product['title']),
                        content: Text(product['description']),
                      ),
                    );
                  },
                );
              },
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
