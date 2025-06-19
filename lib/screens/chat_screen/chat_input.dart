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
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as p;
import 'package:p_chat/services/all_endpoint.dart';
import 'package:p_chat/srorage/pref_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  List<Message> messages = [];
  bool isLoading = false;
  String? uploadedPdfId;
  WebSocketChannel? _channel;
  bool _isConnectedToWebSocket = false;
  String? _accessToken;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _loadAccessToken() async {
    setState(() async {
      _accessToken = await Pref.getStringValue(tokenKey);
    });
  }

  void _connectWebSocket(String pdfId) async {
    if (_channel != null) {
      debugPrint('Closing existing WebSocket connection...');
      await _channel!.sink.close(1000, 'Reconnecting');
      _channel = null;
    }

    if (_accessToken == null || _accessToken!.isEmpty) {
      if (mounted) {
        SnackBarView.showSnackBar(
            context, 'Access token not available. Cannot connect to chat.');
      }
      return;
    }

    try {
      String tokenForWs = _accessToken!.startsWith('Bearer ')
          ? _accessToken!
          : 'Bearer $_accessToken';

      final wsUrl =
          Uri.parse('$chatWebsocketBaseUrl$pdfId?access_token=$tokenForWs');

      debugPrint('Attempting to connect to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      if (mounted) {
        SnackBarView.showSnackBar(context, 'Connecting to chat...');
      }

      await _channel!.ready; // Wait for the connection to be established

      setState(() {
        _isConnectedToWebSocket = true;
        debugPrint('Is connected to websocket $_isConnectedToWebSocket');
      });

      if (mounted) {
        SnackBarView.showSnackBar(context, 'Connected to chat!');
        debugPrint('Connected to chat');
      }

      _channel!.stream.listen(
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

            setState(() {
              messages.add(aiMessage);
              isLoading = false;
            });
            _scrollToBottom();
          } catch (e) {
            debugPrint('Error parsing WebSocket response: $e. Raw data: $data');
            // Fallback to displaying raw data if parsing fails
            final aiMessage = Message(
              text: data.toString(),
              date: DateTime.now(),
              pdfId: pdfId,
              isSentByMe: false,
            );

            setState(() {
              messages.add(aiMessage);
              isLoading = false;
            });
            _scrollToBottom();
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          setState(() {
            _isConnectedToWebSocket = false;
            isLoading = false;
          });
          if (mounted) {
            SnackBarView.showSnackBar(context, 'Chat disconnected.');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          setState(() {
            _isConnectedToWebSocket = false;
            isLoading = false;
          });
          if (mounted) {
            SnackBarView.showSnackBar(context, 'Chat error: $error');
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
      setState(() {
        _isConnectedToWebSocket = false;
        isLoading = false;
        debugPrint('2 is connected to websocket $_isConnectedToWebSocket');
      });
      if (mounted) {
        SnackBarView.showSnackBar(context, 'Failed to connect to chat: $e');
      }
    }
  }

  Future<void> ifTokenHasExpire() async {
    String token = await Pref.getStringValue(tokenKey);
    String yourToken = token.trim();
    bool hasExpired = JwtDecoder.isExpired(yourToken);
    debugPrint('Have token expire ? : $hasExpired');

    if (hasExpired) {
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
        setState(() {
          isLoading = true;
        });

        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        final pdfId = await _uploadPdfToServer(file, fileName);

        if (pdfId != null) {
          uploadedPdfId = pdfId;
          final pdfMessage = Message(
            text: 'PDF uploaded: $fileName',
            date: DateTime.now(),
            pdfId: pdfId,
            isSentByMe: true,
            isPdf: true,
            pdfName: fileName,
          );

          setState(() {
            messages.add(pdfMessage);
            isLoading = false;
          });
          _scrollToBottom();

          _connectWebSocket(pdfId);
        } else {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            SnackBarView.showSnackBar(context, 'Failed to upload PDF');
          }
        }
      } else {
        debugPrint('File picking canceled or no file selected.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error picking file: $e');
      if (mounted) {
        SnackBarView.showSnackBar(context, 'Error picking file: $e');
      }
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
          ref.read(Message.holdPdfId.notifier).state = docId;
          return docId;
        } catch (e) {
          debugPrint(
              'JSON parsing or key access failed. Attempting to treat response as plain string (doc_id). Error: $e');

          String potentialDocId = responseData.trim();
          if (potentialDocId.isNotEmpty) {
            debugPrint('Returning plain string as doc_id: $potentialDocId');
            ref.read(Message.holdPdfId.notifier).state = potentialDocId;
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

    if (uploadedPdfId == null || uploadedPdfId!.isEmpty) {
      if (mounted) {
        SnackBarView.showSnackBar(context, 'Please upload a PDF first.');
      }
      return;
    }

    if (!_isConnectedToWebSocket || _channel == null) {
      debugPrint('WebSocket not connected. Attempting to reconnect...');
      if (mounted) {
        SnackBarView.showSnackBar(context, 'Connecting to chat...');
      }
      _connectWebSocket(uploadedPdfId!);
      return;
    }

    final userMessage = Message(
      text: messageText,
      date: DateTime.now(),
      pdfId: uploadedPdfId!,
      isSentByMe: true,
      isPdf: false,
    );

    setState(() {
      messages.add(userMessage);
      isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final messageData = json.encode({
        'question': messageText,
        'message': messageText,
        'query': messageText,
      });

      debugPrint('Sending message: $messageData');
      _channel!.sink.add(messageData);
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        SnackBarView.showSnackBar(context, 'Error sending message: $e');
      }
    }
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
                  if (mounted) {
                    SnackBarView.showSnackBar(context,
                        'Opening PDF: ${message.pdfName ?? 'Document'} with ID: ${message.pdfId}');
                  }
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
                color: message.isSentByMe ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  decoration: InputDecoration(
                    hintText: uploadedPdfId != null
                        ? 'Type your message here...'
                        : 'Upload PDF to chat',
                    hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 131, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(216, 160, 166, 185),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: uploadedPdfId != null
                      ? (value) => _sendMessage(value)
                      : null,
                  enabled: !isLoading && uploadedPdfId != null,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isLoading ? null : ifTokenHasExpire,
                // _pickPdfFile,
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
                onTap: isLoading || !_hasText || uploadedPdfId == null
                    ? null
                    : () => _sendMessage(_messageController.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLoading || !_hasText || uploadedPdfId == null
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
    if (_channel != null) {
      _channel!.sink.close();
    }
    super.dispose();
  }
}
