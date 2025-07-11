import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/screens/chat_screen/chat_view.dart';
import 'package:p_chat/screens/chat_screen/providers.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'package:p_chat/services/chat_services/delete_chats.dart';
import 'package:p_chat/services/chat_services/web_socketconnection.dart';
import 'package:p_chat/srorage/pref_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


final pdfHistoryListProvider =
    StateNotifierProvider<PdfHistoryListNotifier, List<Map<String, String>>>(
        (ref) => PdfHistoryListNotifier());

class PdfHistoryListNotifier extends StateNotifier<List<Map<String, String>>> {
  PdfHistoryListNotifier() : super([]);

  Future<void> loadHistory() async {
    final List<String> pdfIds = await Pref.getStringListValue(pdfIdListKey);
    final List<Map<String, String>> historyItems = [];

    for (String pdfId in pdfIds) {
      final savedQuestion = await Pref.getStringValue('lastQuestion_$pdfId');
      String displayQuestion = savedQuestion.isNotEmpty
          ? _extractPromptFromJson(savedQuestion) // Extract only the prompt
          : 'Chat with PDF ID: ${pdfId.substring(0, 8)}...';
      historyItems.add({
        'pdfId': pdfId,
        'question': displayQuestion,
      });
    }
    state = historyItems;
  }

  // Helper to extract the inner prompt from a JSON string
  String _extractPromptFromJson(String jsonString) {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      if (decoded.containsKey('prompt') && decoded['prompt'] is String) {
        try {
          final Map<String, dynamic> innerDecoded =
              json.decode(decoded['prompt']);
          if (innerDecoded.containsKey('prompt') &&
              innerDecoded['prompt'] is String) {
            return innerDecoded['prompt'];
          }
        } catch (e) {
          return decoded['prompt'];
        }
      }
    } catch (e) {
      // If decoding fails, or 'prompt' key is not found, return original string
      debugPrint('Error parsing prompt from JSON: $e, original: $jsonString');
    }
    return jsonString;
  }

  Future<void> updateHistoryItem(String pdfId, String lastQuestion) async {
    final List<Map<String, String>> currentHistory = List.from(state);
    int index = currentHistory.indexWhere((item) => item['pdfId'] == pdfId);

    String promptToSave = _extractPromptFromJson(lastQuestion);
    await Pref.setStringValue('lastQuestion_$pdfId', promptToSave);

    final Map<String, String> updatedItem = {
      'pdfId': pdfId,
      // Use the extracted prompt for display
      'question': promptToSave,
    };

    if (index != -1) {
      currentHistory.removeAt(index);
      currentHistory.insert(0, updatedItem);
    } else {
      currentHistory.insert(0, updatedItem);

      List<String> pdfIds = await Pref.getStringListValue(pdfIdListKey);
      if (!pdfIds.contains(pdfId)) {
        pdfIds.insert(0, pdfId);
        await Pref.setStringListValue(pdfIdListKey, pdfIds);
      }
    }
    state = currentHistory;
  }

  Future<void> deleteHistoryItem(String pdfId) async {
    // Remove from the current state list
    final List<Map<String, String>> currentHistory = List.from(state);
    final int initialLength = currentHistory.length;
    currentHistory.removeWhere((item) => item['pdfId'] == pdfId);

    if (currentHistory.length < initialLength) {
      state = currentHistory;

      List<String> pdfIds = await Pref.getStringListValue(pdfIdListKey);
      pdfIds.remove(pdfId);
      await Pref.setStringListValue(pdfIdListKey, pdfIds);

      // Also remove the specific question for this PDF ID from SharedPreferences
      await Pref.removeDateFromStorage('lastQuestion_$pdfId');
      debugPrint(
          'Deleted PDF history item with ID: $pdfId from storage and state.');
    } else {
      debugPrint('PDF history item with ID: $pdfId not found in history.');
    }
  }
}

class HistorySidebarView extends ConsumerStatefulWidget {
  const HistorySidebarView({Key? key}) : super(key: key);

  @override
  ConsumerState<HistorySidebarView> createState() => _HistorySidebarViewState();
}

class _HistorySidebarViewState extends ConsumerState<HistorySidebarView> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await ref.read(pdfHistoryListProvider.notifier).loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final historyItems = ref.watch(pdfHistoryListProvider);

    return Material(
      elevation: 8.0,
      child: Container(
        color: AppColor.colorBlueBlack1,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: AppColor.colorWhite,
                  size: 29,
                ),
                onPressed: () {
                  ref
                      .read(ProviderUserDetails.showHistorySidebar.notifier)
                      .state = false;
                },
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: 100.w,
                height: 100.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          'P-',
                          textStyle: TextStyle(
                            fontFamily: AppText.familyFont,
                            fontSize: 45,
                            color: AppColor.colorOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      onTap: () {
                        debugPrint("Tap Event");
                      },
                    ),
                    AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          'CHAT',
                          textStyle: TextStyle(
                            fontFamily: AppText.familyFont,
                            fontSize: 45,
                            color: AppColor.colorOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      onTap: () {
                        debugPrint("Tap Event");
                      },
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 9,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppText.boldText(
                      'Chat History',
                      FontWeight.bold,
                      fontSize: FontSize.font20,
                      color: AppColor.colorWhite,
                    ),
                  ),
                  Expanded(
                    child: historyItems.isEmpty
                        ? Center(
                            child: AppText.mediumText(
                              'No chat history yet. Upload a PDF to start!',
                              FontWeight.w500,
                              fontSize: FontSize.font16,
                              color: AppColor.colorWhite.withOpacity(0.7),
                            ),
                          )
                        : ListView.builder(
                            itemCount: historyItems.length,
                            itemBuilder: (context, index) {
                              final item = historyItems[index];
                              final pdfId = item['pdfId']!;
                              final displayQuestion = item['question']!;

                              return Card(
                                color: AppColor.colorBlueBlack,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title: AppText.mediumText(
                                    displayQuestion,
                                    FontWeight.w600,
                                    fontSize: FontSize.font16,
                                    color: AppColor.colorWhite,
                                  ),
                                  subtitle: AppText.mediumText(
                                    'PDF ID: ${pdfId.substring(0, 8)}...',
                                    FontWeight.normal,
                                    fontSize: FontSize.font12,
                                    color: AppColor.colorWhite.withOpacity(0.7),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        color: AppColor.colorWhite),
                                    onSelected: (value) {},
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        onTap: () {
                                          Future.microtask(() {
                                            debugPrint(
                                                'User PDFID $pdfId \n index number $index');
                                            ref
                                                .read(ProviderUserDetails
                                                    .showHistorySidebar
                                                    .notifier)
                                                .state = false;
                                            ref
                                                .read(pdfHistoryListProvider
                                                    .notifier)
                                                .deleteHistoryItem(pdfId);

                                            SnackBarView.showSnackBar(context,
                                                'Deleting Pdf history...',
                                                sec: 2);

                                            DeleteChatsServices.deleteChat(
                                                ref, context, pdfId);

                                            //  clear the chat messages or reset the active PDF.
                                            // Example:
                                            // if (ref.read(ChatProviders.uploadedPdfId) == pdfId) {
                                            //   ref.read(ChatProviders.messages.notifier).state = []; // Clear chat messages
                                            //   ref.read(ChatProviders.uploadedPdfId.notifier).state = ''; // Clear active PDF ID
                                            // }
                                          });
                                        },
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outlined,
                                                color: Colors.red),
                                            const SizedBox(width: 8),
                                            AppText.mediumText(
                                              'Delete',
                                              FontWeight.normal,
                                              fontSize: FontSize.font18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    debugPrint('Tapped on PDF ID: $pdfId');
                                    ref
                                        .read(ChatProviders
                                            .uploadedPdfId.notifier)
                                        .state = pdfId;
                                    // Hide the sidebar after selecting a history item
                                    ref
                                        .read(ProviderUserDetails
                                            .showHistorySidebar.notifier)
                                        .state = false;
                                    // Connect to WebSocket with the selected PDF ID
                                    await WebSocketConnectionServices
                                        .initConnectWebSocket(
                                            ref, context, pdfId);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
