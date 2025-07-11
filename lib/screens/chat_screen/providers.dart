import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p_chat/screens/chat_screen/chat_input.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
//   return MessagesNotifier();
// });


// class MessagesNotifier extends StateNotifier<List<Message>> {
//   MessagesNotifier() : super([]);

//   void addMessage(Message message) {
//     state = [...state, message];
//   }

//   void clearMessages() {
//     state = [];
//   }
// }

// class ChatProviders {
//   static final isLoading = StateProvider((ref) => false);
//   static final isConnectedToWebSocket = StateProvider((ref) => false);
//   static final hasText = StateProvider((ref) => false);
//   static final uploadedPdfId = StateProvider((ref) => '');
//   static WebSocketChannel? channel; 
// }




final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier();
});


class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}

class ChatProviders {
  static final isLoading = StateProvider((ref) => false);
  static final isConnectedToWebSocket = StateProvider((ref) => false);
  static final hasText = StateProvider((ref) => false);
  static final uploadedPdfId = StateProvider((ref) => '');
  static WebSocketChannel? channel;
}