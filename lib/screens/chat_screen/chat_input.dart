// ignore_for_file: unused_field

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/screens/chat_screen/chat_view.dart';
import 'package:p_chat/screens/chat_screen/providers.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as p;
import 'package:p_chat/services/all_endpoint.dart';
import 'package:p_chat/services/chat_services/web_socketconnection.dart';
import 'package:p_chat/srorage/pref_storage.dart';

class Message {
  final String text;
  final DateTime date;
  final String pdfId;
  final bool isSentByMe;
  final bool isPdf;
  final String? pdfName;

  const Message({
    required this.text,
    required this.date,
    required this.pdfId,
    required this.isSentByMe,
    this.isPdf = false,
    this.pdfName,
  });

  static final holdPdfId = StateProvider((ref) => '');
}

class ChatPreview extends ConsumerStatefulWidget {
  const ChatPreview({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPreview> createState() => _ChatPreviewState();
}

class _ChatPreviewState extends ConsumerState<ChatPreview> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
    _messageController.addListener(() {
      ref.read(ChatProviders.hasText.notifier).state =
          _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadAccessToken() async {
    _accessToken = await Pref.getStringValue(tokenKey);
  }

  Future<void> ifTokenHasExpire() async {
    String token = await Pref.getStringValue(tokenKey);
    String yourToken = token.trim();
    debugPrint('Have token expire ? : ${JwtDecoder.isExpired(yourToken)}');

    if (JwtDecoder.isExpired(yourToken)) {
      LogOutUser.logUserOut(ref, context);
    } else {
      _pickPdfFile();
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        ref.read(ChatProviders.isLoading.notifier).state = true;

        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        final pdfId = await _uploadPdfToServer(file, fileName);

        if (pdfId != null) {
          ref.read(ChatProviders.uploadedPdfId.notifier).state = pdfId;
          final pdfMessage = Message(
            text: 'PDF uploaded: $fileName',
            date: DateTime.now(),
            pdfId: pdfId,
            isSentByMe: true,
            isPdf: true,
            pdfName: fileName,
          );

          ref.read(messagesProvider.notifier).addMessage(pdfMessage);
          _scrollToBottom();

          // Save the new PDF ID to the list in shared preferences
          List<String> pdfHistory = await Pref.getStringListValue(pdfIdListKey);
          if (!pdfHistory.contains(pdfId)) {
            pdfHistory.add(pdfId);
            await Pref.setStringListValue(pdfIdListKey, pdfHistory);
            debugPrint('Added PDF ID to history: $pdfId');
          }

          // Pass the necessary callbacks to the service
          await WebSocketConnectionServices.connectWebSocket(
            pdfId,
            ref,
            context,
            onMessageReceived: _scrollToBottom,
            addMessageToUi: (message) {
              ref.read(messagesProvider.notifier).addMessage(message);
            },
          );
        } else {
          SnackBarView.showSnackBar(context, 'Failed to upload PDF');
        }
        ref.read(ChatProviders.isLoading.notifier).state = false;
      } else {
        debugPrint('File picking canceled or no file selected.');
      }
    } catch (e) {
      ref.read(ChatProviders.isLoading.notifier).state = false;
      debugPrint('Error picking file: $e');
      SnackBarView.showSnackBar(context, 'Error picking file: $e');
    }
  }

  Future<String?> _uploadPdfToServer(File file, String fileName) async {
    String token = await Pref.getStringValue(tokenKey);
    String yourToken = token.trim();
    debugPrint('User token is: $yourToken');
    debugPrint('Uploading file now \nFile name is $fileName');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadPdfEndpoint));
      request.headers['Authorization'] = 'Bearer $yourToken';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      );
      debugPrint(
          'Sending file to backend as application.pdf (with explicit Content-Type)');
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      debugPrint('PDF Upload Response Status: ${response.statusCode}');
      debugPrint('PDF Upload Response Body: $responseData');
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(responseData);

          String docId = jsonResponse['data']['doc_id'].toString();
          debugPrint('Extracted doc_id from JSON: $docId');

          // Save the new PDF ID to the list in shared preferences
          List<String> pdfHistory = await Pref.getStringListValue(pdfIdListKey);
          if (!pdfHistory.contains(docId)) {
            pdfHistory.add(docId);
            await Pref.setStringListValue(pdfIdListKey, pdfHistory);
            debugPrint('Added PDF ID to history: $docId');
          }
          return docId;
        } catch (e) {
          debugPrint(
              'JSON parsing or key access failed. Attempting to treat response as plain string (doc_id). Error: $e');

          String potentialDocId = responseData.trim();
          if (potentialDocId.isNotEmpty) {
            debugPrint('Returning plain string as doc_id: $potentialDocId');
            return potentialDocId;
          } else {
            debugPrint('Response was empty or not a valid doc_id string.');
            return null;
          }
        }
      } else {
        debugPrint(
            'Server responded with non-success status. Error details: $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    final uploadedPdfId = ref.watch(ChatProviders.uploadedPdfId);
    debugPrint('sending chat pdf Id $uploadedPdfId');

    if (uploadedPdfId.isEmpty) {
      SnackBarView.showSnackBar(context, 'Please upload a PDF first.');
      return;
    }

    if (!ref.watch(ChatProviders.isConnectedToWebSocket) ||
        ChatProviders.channel == null) {
      debugPrint('WebSocket not connected. Attempting to reconnect...');
      SnackBarView.showSnackBar(context, 'Connecting to chat...');
      await WebSocketConnectionServices.connectWebSocket(
        uploadedPdfId,
        ref,
        context,
        onMessageReceived: _scrollToBottom,
        addMessageToUi: (message) {
          ref.read(messagesProvider.notifier).addMessage(message);
        },
      );
      if (!ref.read(ChatProviders.isConnectedToWebSocket)) {
        SnackBarView.showSnackBar(
            context, 'Failed to connect to chat. Try again.');
        return;
      }
    }

    final userMessage = Message(
      text: messageText,
      date: DateTime.now(),
      pdfId: uploadedPdfId,
      isSentByMe: true,
      isPdf: false,
    );

    ref.read(messagesProvider.notifier).addMessage(userMessage);
    ref.read(ChatProviders.isLoading.notifier).state = true;

    _messageController.clear();
    _scrollToBottom();

    WebSocketConnectionServices.sendMessage(
        messageText, uploadedPdfId, ref, context);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd,EEEE').format(date);
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: message.isSentByMe
              ? const Color(0xFF007AFF)
              : AppColor.colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: message.isSentByMe
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: message.isSentByMe
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isPdf)
              GestureDetector(
                onTap: () {
                  SnackBarView.showSnackBar(context,
                      'Opening PDF: ${message.pdfName ?? 'Document'} with ID: ${message.pdfId}');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color:
                          message.isSentByMe ? AppColor.colorWhite : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        message.pdfName ?? 'PDF Document',
                        style: TextStyle(
                          fontFamily: AppText.familyFont,
                          color: message.isSentByMe
                              ? AppColor.colorWhite
                              : AppColor.colorBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              AppText.mediumText(
                message.text,
                FontWeight.w600,
                fontSize: FontSize.font16,
                color: message.isSentByMe
                    ? AppColor.colorWhite
                    : AppColor.colorBlack,
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.date),
              style: TextStyle(
                color: message.isSentByMe
                    ? Colors.white70
                    : const Color.fromARGB(255, 97, 97, 97),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: AppText.familyFont,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(ChatProviders.isLoading);
    final hasText = ref.watch(ChatProviders.hasText);
    final uploadedPdfId = ref.watch(ChatProviders.uploadedPdfId);
    final messages = ref.watch(messagesProvider); // Watch the messages provider

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: AppText.boldText(
                    'Upload a PDF and start chatting!',
                    FontWeight.bold,
                    fontSize: FontSize.font20,
                    color: AppColor.colorWhite,
                  ),
                )
              : GroupedListView<Message, String>(
                  elements: messages,
                  groupBy: (message) => _formatDate(message.date),
                  groupSeparatorBuilder: (String groupByValue) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText.mediumText(
                          groupByValue,
                          FontWeight.w500,
                          fontSize: FontSize.font12,
                          color: AppColor.colorWhite,
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, Message message) =>
                      _buildMessageBubble(message),
                  order: GroupedListOrder.ASC,
                  useStickyGroupSeparators: false,
                  floatingHeader: false,
                  controller: _scrollController,
                ),
        ),
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.colorWhite,
                  ),
                ),
                const SizedBox(width: 12),
                AppText.boldText(
                  'Processing...',
                  FontWeight.w500,
                  fontSize: FontSize.font16,
                  color: AppColor.colorWhite,
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.colorWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppText.familyFont,
                  ),
                  decoration: InputDecoration(
                    hintText: uploadedPdfId.isNotEmpty
                        ? 'Type your message here...'
                        : 'Upload PDF to chat',
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 131, 131, 131),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppText.familyFont,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(216, 160, 166, 185),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: uploadedPdfId.isNotEmpty
                      ? (value) => _sendMessage(value)
                      : null,
                  enabled: !isLoading && uploadedPdfId.isNotEmpty,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isLoading ? null : ifTokenHasExpire,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : AppColor.colorBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_file,
                    color: AppColor.colorWhite,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isLoading || !hasText || uploadedPdfId.isEmpty
                    ? null
                    : () => _sendMessage(_messageController.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLoading || !hasText || uploadedPdfId.isEmpty
                        ? const Color.fromARGB(216, 160, 166, 185)
                        : AppColor.colorBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 250, 248, 248),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (ChatProviders.channel != null) {
      ChatProviders.channel!.sink.close();
    }
    super.dispose();
  }
}
