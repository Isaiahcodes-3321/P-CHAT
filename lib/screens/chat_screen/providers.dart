import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p_chat/screens/chat_screen/chat_input.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) => MessagesNotifier());

// class MessagesNotifier extends StateNotifier<List<Message>> {
//   MessagesNotifier() : super([]);

//   void addMessage(Message message) {
//     state = [...state, message];
//   }

//   void clearMessages() {
//     state = [];
//   }

//   void removeMessage(int index) {
//     if (index >= 0 && index < state.length) {
//       final List<Message> newState = List.from(state);
//       newState.removeAt(index);
//       state = newState;
//     }
//   }

//   void updateMessage(int index, Message newMessage) {
//     if (index >= 0 && index < state.length) {
//       final List<Message> newState = List.from(state);
//       newState[index] = newMessage;
//       state = newState;
//     }
//   }
// }


// class ChatProviders {
//   static final isLoading = StateProvider((ref) => false);
//   static final isConnectedToWebSocket = StateProvider((ref) => false);
//   static final hasText = StateProvider((ref) => false);
//   static final uploadedPdfId = StateProvider((ref) => '');
//   static WebSocketChannel? channel;
  
//   // Add this reference to your messages provider
//   static final messages = messagesProvider;
// }



final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) => MessagesNotifier());

class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }

  void removeMessage(int index) {
    if (index >= 0 && index < state.length) {
      final List<Message> newState = List.from(state);
      newState.removeAt(index);
      state = newState;
    }
  }

  void updateMessage(int index, Message newMessage) {
    if (index >= 0 && index < state.length) {
      final List<Message> newState = List.from(state);
      newState[index] = newMessage;
      state = newState;
    }
  }

  // Corrected method added to handle streaming updates
  void updateLastMessage(Message newMessage) {
    if (state.isNotEmpty) {
      final List<Message> newState = List.from(state);
      newState[newState.length - 1] = newMessage;
      state = newState;
    } else {
      // If for some reason the list is empty when trying to update, add it.
      // This case is less common for "updateLastMessage" but ensures robustness.
      addMessage(newMessage);
    }
  }
}


class ChatProviders {
  static final isLoading = StateProvider((ref) => false);
  static final isConnectedToWebSocket = StateProvider((ref) => false);
  static final hasText = StateProvider((ref) => false);
  static final uploadedPdfId = StateProvider((ref) => '');
  static WebSocketChannel? channel;

  // Add this reference to your messages provider
  static final messages = messagesProvider;
}