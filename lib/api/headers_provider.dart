import 'package:flutter_riverpod/flutter_riverpod.dart';

final headersProvider = Provider<HeadersProvider>(
  (ref) => HeadersProvider(ref),
);

class HeadersProvider {
  final Ref ref;
  HeadersProvider(this.ref);

  Map<String, String> get basic => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<Map<String, String>> get token async => basic;
}
