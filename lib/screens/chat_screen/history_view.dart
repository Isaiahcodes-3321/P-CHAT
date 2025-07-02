import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/screens/chat_screen/chat_view.dart';
import 'package:p_chat/screens/chat_screen/providers.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
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
      // Retrieve the saved question for this PDF ID
      final savedQuestion = await Pref.getStringValue('lastQuestion_$pdfId');
      historyItems.add({
        'pdfId': pdfId,
        'question': savedQuestion.isNotEmpty
            ? savedQuestion
            : 'Chat with PDF ID: ${pdfId.substring(0, 8)}...',
      });
    }
    state = historyItems;
  }

  // Method to update a history item's last question
  Future<void> updateHistoryItem(String pdfId, String lastQuestion) async {
    final List<Map<String, String>> currentHistory = List.from(state);
    int index = currentHistory.indexWhere((item) => item['pdfId'] == pdfId);

    if (index != -1) {
      currentHistory[index]['question'] = lastQuestion;
      state = currentHistory;
      await Pref.setStringValue('lastQuestion_$pdfId', lastQuestion);
    } else {
      // If the item doesn't exist, add it
      currentHistory.add({'pdfId': pdfId, 'question': lastQuestion});
      state = currentHistory;
      await Pref.setStringValue('lastQuestion_$pdfId', lastQuestion);
      // Also add the PDF ID to the main list if it's new
      List<String> pdfIds = await Pref.getStringListValue(pdfIdListKey);
      if (!pdfIds.contains(pdfId)) {
        pdfIds.add(pdfId);
        await Pref.setStringListValue(pdfIdListKey, pdfIds);
      }
    }
  }
}

// This is the actual sidebar widget that will be shown
class HistorySidebarView extends ConsumerStatefulWidget {
  const HistorySidebarView({Key? key}) : super(key: key);

  @override
  ConsumerState<HistorySidebarView> createState() => _HistorySidebarViewState();
}

class _HistorySidebarViewState extends ConsumerState<HistorySidebarView> {
  @override
  void initState() {
    super.initState();
    // Load history when the sidebar is initialized
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
                icon: const Icon(Icons.close, color: AppColor.colorWhite),
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
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      color: AppColor.colorWhite, size: 16),
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
