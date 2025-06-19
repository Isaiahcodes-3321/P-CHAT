import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as p;
import 'package:p_chat/services/all_endpoint.dart';
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
  List<Message> messages = [];
  bool isLoading = false;
  String? uploadedPdfId;

  Future<void> _pickPdfFile() async {
    try {
      // It's important to use FileType.any or check permissions if facing issues
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
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload PDF')),
          );
        }
      } else {
        // User canceled the picker
        debugPrint('File picking canceled or no file selected.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error picking file: $e'); // Debug the specific error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
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

  // / this is to send message
  Future<void> _sendMessage(String messageText) async {
    if (messageText.trim().isEmpty && uploadedPdfId == null) return;

    final userMessage = Message(
      text: messageText.isNotEmpty
          ? messageText
          : (uploadedPdfId != null ? 'Sent PDF' : ''),
      date: DateTime.now(),
      pdfId: uploadedPdfId ?? '',
      isSentByMe: true,
      isPdf: uploadedPdfId != null,
      pdfName: uploadedPdfId != null ? 'Uploaded PDF' : null,
    );

    setState(() {
      messages.add(userMessage);
      isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Replace with your actual chat endpoint
      String getPdfId = ref.watch(Message.holdPdfId);
      String token = await Pref.getStringValue(tokenKey);
      String yourToken = token.trim();

      final response = await http.post(
        Uri.parse('$chatEndpoint$getPdfId$yourToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final aiMessage = Message(
          text: responseData['response'],
          date: DateTime.now(),
          pdfId: uploadedPdfId ?? '',
          isSentByMe: false,
        );

        setState(() {
          messages.add(aiMessage);
          isLoading = false;
          uploadedPdfId = null; // Clear uploaded PDF ID after sending
        });
        _scrollToBottom();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: message.isSentByMe ? const Color(0xFF007AFF) : Colors.white,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Opening PDF: ${message.pdfName ?? 'Document'} with ID: ${message.pdfId}')),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: message.isSentByMe ? Colors.white : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        message.pdfName ?? 'PDF Document',
                        style: TextStyle(
                          color:
                              message.isSentByMe ? Colors.white : Colors.black,
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
              Text(
                message.text,
                style: TextStyle(
                  color: message.isSentByMe ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
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
                        child: Text(
                          groupByValue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, Message message) =>
                      _buildMessageBubble(message),
                  order: GroupedListOrder.ASC,
                  useStickyGroupSeparators:
                      false, // Set to false so the date moves with scroll
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('Processing...',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
                    hintText: 'Type your message here...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: uploadedPdfId != null
                      ? null
                      : (value) => _sendMessage(
                          value), // Only allow sending text if no PDF is attached
                  enabled: !isLoading,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isLoading ? null : _pickPdfFile,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_file,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isLoading ||
                        (_messageController.text.isEmpty &&
                            uploadedPdfId == null)
                    ? null
                    : () => _sendMessage(_messageController.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLoading ||
                            (_messageController.text.isEmpty &&
                                uploadedPdfId == null)
                        ? Colors.grey
                        : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
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
    super.dispose();
  }
}
