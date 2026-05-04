import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:testproject/products_provider.dart';
import 'package:testproject/api/api_provider.dart';

class TestHttp extends ConsumerWidget {
  const TestHttp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = Uri.parse('https://dummyjson.com/products/1');
    Future<void> fetch() async {
      // final response = await ref.read(apiProvider).baseGet('/practice-items/1');
      final response = await ref
          .read(apiProvider)
          .baseGet('/practiceitems/schema');
      final data = jsonDecode(response.body);
      print('Get');
      print(response.statusCode);
      print(data['data']);
      return data;
    }

    Future<void> post() async {
      final response = await ref.read(apiProvider).basePost('/practice-items', {
        "title": "bello",
        "slug": "jello",
        "quantity": 10,
        "is_featured": false,
        "status": "draft",
        "description": null,
        "unit_price": null,
        "tags": ["test"],
        "optional_note": null,
        "starts_at": null,
        "ends_at": null,
        "message": "hi",
        "errors": null,
      });
      print('Post');
      print(response.statusCode);
      print(response.body);
    }

    Future<void> put() async {
      final response = await http.put(
        uri,
        body: {
          "title": "bello",
          "slug": "jello",
          "quantity": 10,
          "is_featured": false,
          "status": "draft",
          "description": null,
          "unit_price": null,
          "tags": ["test"],
          "optional_note": null,
          "starts_at": null,
          "ends_at": null,
        },
      );
      print('Put');
      print(response.statusCode);
    }

    Future<void> patch() async {
      final response = await ref.read(apiProvider).basePatch(
        '/practice-items/1',
        {"title": "bello new"},
      );
      print('Patch');
      print(response.statusCode);
      print(response.body);
    }

    Future<void> delete() async {
      final response = await ref
          .read(apiProvider)
          .baseDelete('/practice-items/1');
      print('Delete');
      print(response.statusCode);
      print(response.body);
    }

    Future<void> postWithFile() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      final response = await ref
          .read(apiProvider)
          .basePostWithFile('/practice-items/1/media', image!.path);
      print('Post with file');
      print(response.statusCode);
      print(response.body);
    }

    return Scaffold(
      appBar: AppBar(title: Text('http test')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                fetch();
              },
              child: const Text('Refresh Products'),
            ),
          ],
        ),
      ),
    );
  }
}
