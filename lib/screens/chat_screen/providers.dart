import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatProviders {
  static final isLoading = StateProvider((ref) => false);
  static final isConnectedToWebSocket = StateProvider((ref) => false);
  static final hasText = StateProvider((ref) => false);
}
