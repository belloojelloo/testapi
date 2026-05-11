import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/api_provider.dart';
import 'dart:convert';

final productsProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await ref.read(apiProvider).baseGet('/');
  return jsonDecode(response.body)['data'] as List<dynamic>;
});

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? emptyToNull(String value) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    bool? parseBool(String value) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
      return null;
    }

    String listToText(dynamic value) {
      if (value is List) {
        return value.join(', ');
      }
      return '';
    }

    void showAddItemDialog() {
      final titleController = TextEditingController();
      final slugController = TextEditingController();
      final descriptionController = TextEditingController();
      final quantityController = TextEditingController();
      final priceController = TextEditingController();
      final isFeaturedController = TextEditingController();
      final tagsController = TextEditingController();
      final statusController = TextEditingController();
      final optionalNoteController = TextEditingController();
      final startsAtController = TextEditingController();
      final endsAtController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: slugController,
                  decoration: const InputDecoration(labelText: 'Slug'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Unit Price'),
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: isFeaturedController,
                  decoration: const InputDecoration(
                    labelText: 'Is Featured (true/false)',
                  ),
                ),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                  ),
                ),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: optionalNoteController,
                  decoration: const InputDecoration(labelText: 'Optional Note'),
                ),
                TextField(
                  controller: startsAtController,
                  decoration: const InputDecoration(labelText: 'Starts At'),
                ),
                TextField(
                  controller: endsAtController,
                  decoration: const InputDecoration(labelText: 'Ends At'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text.trim());
                final unitPrice = emptyToNull(priceController.text);
                final isFeatured = parseBool(isFeaturedController.text);
                final tags = emptyToNull(tagsController.text)
                    ?.split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                if (quantity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quantity must be a valid integer.'),
                    ),
                  );
                  return;
                }

                if (isFeatured == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Is Featured must be either true or false.',
                      ),
                    ),
                  );
                  return;
                }

                final response = await ref.read(apiProvider).basePost('/', {
                  "title": titleController.text.trim(),
                  "slug": slugController.text.trim(),
                  "description": emptyToNull(descriptionController.text),
                  "quantity": quantity,
                  "unit_price": unitPrice == null
                      ? null
                      : double.tryParse(unitPrice),
                  "is_featured": isFeatured,
                  "tags": tags,
                  "status": statusController.text.trim(),
                  "optional_note": emptyToNull(optionalNoteController.text),
                  "starts_at": emptyToNull(startsAtController.text),
                  "ends_at": emptyToNull(endsAtController.text),
                });

                final responseBody = jsonDecode(response.body);

                if (response.statusCode == 201) {
                  ref.invalidate(productsProvider);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item created successfully.')),
                  );
                  return;
                }

                final errorMessage =
                    responseBody['message']?.toString() ??
                    'Failed to create item.';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorMessage)));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    final items = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Center(
        child: items.when(
          data: (value) {
            if (value.isEmpty) {
              return const Text('No products found');
            }
            return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                final practiceItem = value[index];
                return ListTile(
                  title: Text(practiceItem['title'].toString()),
                  subtitle: Text('\$${practiceItem['unit_price'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          final titleController = TextEditingController(
                            text: practiceItem['title'].toString(),
                          );
                          final slugController = TextEditingController(
                            text: practiceItem['slug']?.toString() ?? '',
                          );
                          final descriptionController = TextEditingController(
                            text: practiceItem['description']?.toString() ?? '',
                          );
                          final quantityController = TextEditingController(
                            text: practiceItem['quantity']?.toString() ?? '',
                          );
                          final priceController = TextEditingController(
                            text: practiceItem['unit_price']?.toString() ?? '',
                          );
                          final isFeaturedController = TextEditingController(
                            text: practiceItem['is_featured']?.toString() ?? '',
                          );
                          final tagsController = TextEditingController(
                            text: listToText(practiceItem['tags']),
                          );
                          final statusController = TextEditingController(
                            text: practiceItem['status']?.toString() ?? '',
                          );
                          final optionalNoteController = TextEditingController(
                            text:
                                practiceItem['optional_note']?.toString() ?? '',
                          );
                          final startsAtController = TextEditingController(
                            text: practiceItem['starts_at']?.toString() ?? '',
                          );
                          final endsAtController = TextEditingController(
                            text: practiceItem['ends_at']?.toString() ?? '',
                          );

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Edit Product'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                      ),
                                    ),
                                    TextField(
                                      controller: slugController,
                                      decoration: const InputDecoration(
                                        labelText: 'Slug',
                                      ),
                                    ),
                                    TextField(
                                      controller: quantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                      ),
                                    ),
                                    TextField(
                                      controller: priceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        labelText: 'Unit Price',
                                      ),
                                    ),
                                    TextField(
                                      controller: descriptionController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                      ),
                                    ),
                                    TextField(
                                      controller: isFeaturedController,
                                      decoration: const InputDecoration(
                                        labelText: 'Is Featured (true/false)',
                                      ),
                                    ),
                                    TextField(
                                      controller: tagsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tags (comma separated)',
                                      ),
                                    ),
                                    TextField(
                                      controller: statusController,
                                      decoration: const InputDecoration(
                                        labelText: 'Status',
                                      ),
                                    ),
                                    TextField(
                                      controller: optionalNoteController,
                                      decoration: const InputDecoration(
                                        labelText: 'Optional Note',
                                      ),
                                    ),
                                    TextField(
                                      controller: startsAtController,
                                      decoration: const InputDecoration(
                                        labelText: 'Starts At',
                                      ),
                                    ),
                                    TextField(
                                      controller: endsAtController,
                                      decoration: const InputDecoration(
                                        labelText: 'Ends At',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final quantity = int.tryParse(
                                      quantityController.text.trim(),
                                    );
                                    final unitPrice = emptyToNull(
                                      priceController.text,
                                    );
                                    final isFeatured = parseBool(
                                      isFeaturedController.text,
                                    );
                                    final tags =
                                        emptyToNull(tagsController.text)
                                            ?.split(',')
                                            .map((tag) => tag.trim())
                                            .where((tag) => tag.isNotEmpty)
                                            .toList();

                                    if (quantity == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Quantity must be a valid integer.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (isFeatured == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Is Featured must be either true or false.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final response = await ref
                                        .read(apiProvider)
                                        .basePatch('/${practiceItem['id']}', {
                                          'title': titleController.text.trim(),
                                          'slug': slugController.text.trim(),
                                          'description': emptyToNull(
                                            descriptionController.text,
                                          ),
                                          'quantity': quantity,
                                          'unit_price': unitPrice == null
                                              ? null
                                              : double.tryParse(unitPrice),
                                          'is_featured': isFeatured,
                                          'tags': tags,
                                          'status': statusController.text
                                              .trim(),
                                          'optional_note': emptyToNull(
                                            optionalNoteController.text,
                                          ),
                                          'starts_at': emptyToNull(
                                            startsAtController.text,
                                          ),
                                          'ends_at': emptyToNull(
                                            endsAtController.text,
                                          ),
                                        });

                                    final responseBody = jsonDecode(
                                      response.body,
                                    );

                                    if (response.statusCode == 200) {
                                      ref.invalidate(productsProvider);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Item updated successfully.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final errorMessage =
                                        responseBody['message']?.toString() ??
                                        'Failed to update item.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
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
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text(
                                'Are you sure you want to delete this item?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final response = await ref
                                        .read(apiProvider)
                                        .baseDelete('/${practiceItem['id']}');

                                    Navigator.pop(context);

                                    if (response.statusCode == 200) {
                                      ref.invalidate(productsProvider);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Item deleted successfully.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to delete item.'),
                                      ),
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(practiceItem['title']),
                        content: Text(practiceItem['description']),
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
      floatingActionButton: FloatingActionButton(
        onPressed: showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
