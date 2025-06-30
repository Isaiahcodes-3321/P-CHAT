// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/screens/chat_screen/chat_input.dart';
import 'package:p_chat/screens/chat_screen/providers.dart';
import 'package:p_chat/services/all_endpoint.dart';
import 'package:p_chat/srorage/pref_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;


class WebSocketConnectionServices {
  static Future<void> connectWebSocket(
      String pdfId, WidgetRef ref, BuildContext context,
      {required VoidCallback onMessageReceived,
      required Function(Message) addMessageToUi}) async {
    String token = await Pref.getStringValue(tokenKey);
    String _accessToken = token.trim();

    if (ChatProviders.channel != null) {
      debugPrint('Closing existing WebSocket connection...');
      await ChatProviders.channel!.sink.close(1000, 'Reconnecting');
      ChatProviders.channel = null;
    }

    if (_accessToken.isEmpty) {
      SnackBarView.showSnackBar(
          context, 'Access token not available. Cannot connect to chat.');
      return;
    }

    try {
      String tokenForWs = _accessToken.startsWith('Bearer ')
          ? _accessToken
          : 'Bearer $_accessToken';

      final wsUrl =
          Uri.parse('$chatWebsocketBaseUrl$pdfId?access_token=$tokenForWs');

      debugPrint('Attempting to connect to WebSocket: $wsUrl');

      ChatProviders.channel = WebSocketChannel.connect(wsUrl);
      SnackBarView.showSnackBar(context, 'Connecting to chat...');
      await ChatProviders
          .channel!.ready; 

      ref.read(ChatProviders.isConnectedToWebSocket.notifier).state = true;
      debugPrint(
          'Is connected to websocket ${ref.watch(ChatProviders.isConnectedToWebSocket)}');

      SnackBarView.showSnackBar(context, 'Connected to chat!');
      debugPrint('Connected to chat');

      ChatProviders.channel!.stream.listen(
        (data) {
          debugPrint('Received WebSocket data: $data');
          try {
            final Map<String, dynamic> responseData = json.decode(data);
            final String aiResponse = responseData['response'] ??
                responseData['message'] ??
                data.toString();
            final aiMessage = Message(
              text: aiResponse,
              date: DateTime.now(),
              pdfId: pdfId,
              isSentByMe: false,
            );

            addMessageToUi(aiMessage); 
            ref.read(ChatProviders.isLoading.notifier).state = false;
            onMessageReceived(); // Notify UI to scroll to bottom
          } catch (e) {
            debugPrint('Error parsing WebSocket response: $e. Raw data: $data');
            final aiMessage = Message(
              text: data.toString(),
              date: DateTime.now(),
              pdfId: pdfId,
              isSentByMe: false,
            );

            addMessageToUi(aiMessage); 
            ref.read(ChatProviders.isLoading.notifier).state = false;
            onMessageReceived(); 
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          ref.read(ChatProviders.isConnectedToWebSocket.notifier).state = false;
          ref.read(ChatProviders.isLoading.notifier).state = false;
          SnackBarView.showSnackBar(context, 'Chat disconnected.');
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          ref.read(ChatProviders.isConnectedToWebSocket.notifier).state = false;
          ref.read(ChatProviders.isLoading.notifier).state = false;
          SnackBarView.showSnackBar(context, 'Chat error: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
      ref.read(ChatProviders.isConnectedToWebSocket.notifier).state = false;
      ref.read(ChatProviders.isLoading.notifier).state = false;
      debugPrint(
          '2 is connected to websocket ${ref.watch(ChatProviders.isConnectedToWebSocket)}');
      SnackBarView.showSnackBar(context, 'Failed to connect to chat: $e');
    }
  }

  static void sendMessage(String messageText, String pdfId, WidgetRef ref, BuildContext context) {
    if (ChatProviders.channel == null || !ref.read(ChatProviders.isConnectedToWebSocket)) {
      debugPrint('WebSocket not connected. Cannot send message.');
      SnackBarView.showSnackBar(context, 'WebSocket not connected. Please ensure a PDF is uploaded and connection is active.');
      return;
    }

    try {
      final messageData = json.encode({
        'question': messageText,
        'message': messageText,
        'query': messageText,
      });

      debugPrint('Sending message: $messageData');
      ChatProviders.channel!.sink.add(messageData);
    } catch (e) {
      debugPrint('Error sending message: $e');
      SnackBarView.showSnackBar(context, 'Error sending message: $e');
    }
  }
}