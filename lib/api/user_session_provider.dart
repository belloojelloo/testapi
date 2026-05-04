import 'package:flutter_riverpod/flutter_riverpod.dart';

final userSessionProvider = Provider<UserSessionProvider>((ref) => UserSessionProvider());

class UserSessionProvider {
  String get token {
    // Return your actual session token here
    return 'YOUR_USER_TOKEN';
  }
}
