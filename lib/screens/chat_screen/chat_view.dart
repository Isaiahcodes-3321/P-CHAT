import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'package:p_chat/screens/chat_screen/chat_input.dart';
import 'package:p_chat/screens/chat_screen/history_view.dart';
import 'package:p_chat/screens/chat_screen/providers.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'package:p_chat/services/chat_services/web_socketconnection.dart';
import 'package:p_chat/srorage/pref_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning ${ref.watch(ProviderUserDetails.holdUserName)}';
    } else if (hour >= 12 && hour < 16) {
      return 'Good Afternoon ${ref.watch(ProviderUserDetails.holdUserName)}';
    } else {
      return 'Good Evening ${ref.watch(ProviderUserDetails.holdUserName)}';
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    isAppUpdated();
    _loadInitialFabPosition();
    _checkPdfHistoryAndConnect();
  }

  Future<void> isAppUpdated() async {
    try {
      final getApkVersion = await Pref.getIntValue(apkVersionKey);
      debugPrint('ApkVersion is $getApkVersion');
      if (getApkVersion == 1) {
        // App is updated - do nothing
        return;
      } else {
        if (!mounted) return;
        debugPrint('Show nOtification Now');
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          ShowMaterialBanner.materialBanner(context);
          Future.delayed(const Duration(seconds: 4), () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            isAppUpdated();
          });
        });
      }
    } catch (e) {
      debugPrint('Error checking app version: $e');
    }
  }

  Future<void> _checkPdfHistoryAndConnect() async {
    final pdfHistoryIds = await Pref.getStringListValue(pdfIdListKey);
    debugPrint("pdf lents its ${pdfHistoryIds.length}");
    if (pdfHistoryIds.isNotEmpty) {
      final lastPdfId = pdfHistoryIds.last;
      debugPrint('Found last Pdf ID in history: $lastPdfId');
      ref.read(ChatProviders.uploadedPdfId.notifier).state = lastPdfId;
      await WebSocketConnectionServices.initConnectWebSocket(
          ref, context, lastPdfId);

      await ref.read(pdfHistoryListProvider.notifier).loadHistory();
    }
  }

  getUserInfo() async {
    String getUserId = await Pref.getStringValue(userIdKey);
    String getUserName = await Pref.getStringValue(userNameKey);
    ref.read(ProviderUserDetails.holdUserId.notifier).state = getUserId;
    ref.read(ProviderUserDetails.holdUserName.notifier).state = getUserName;
  }

  // Offset _fabPosition = const Offset(280, 490);
  Offset _fabPosition = Offset(79.w, 66.h);

  void _loadInitialFabPosition() async {
    setState(() {
      _fabPosition = Offset(MediaQuery.of(context).size.width - 80,
          MediaQuery.of(context).size.height * 0.7);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _fabPosition = _fabPosition + details.delta;
    });
  }

  void _clearChatAndResetPdf() {
    debugPrint('Clearing chat ui for new screen');
    ref.read(messagesProvider.notifier).clearMessages();
    ref.read(ChatProviders.uploadedPdfId.notifier).state = '';
    ref.read(ChatProviders.isConnectedToWebSocket.notifier).state = false;
    if (ChatProviders.channel != null) {
      ChatProviders.channel!.sink.close();
      ChatProviders.channel = null;
    }
    // Optionally update the history list to reflect the cleared chat state
    ref.read(pdfHistoryListProvider.notifier).loadHistory();
  }

  popMenuText(String text) {
    return AppText.boldText(
      text,
      FontWeight.bold,
      fontSize: FontSize.font14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.7;

    return Scaffold(
        backgroundColor: AppColor.colorBlueBlack,
        appBar: AppBar(
          title: AppText.boldText(
            _getGreeting(),
            FontWeight.bold,
            fontSize: FontSize.font20,
            color: AppColor.colorWhite,
          ),
          backgroundColor: AppColor.colorBlueBlack,
          shadowColor: AppColor.colorWhite,
          elevation: 7.0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColor.colorWhite),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  onTap: () {
                    // Trigger loading history when sidebar is opened
                    ref.read(pdfHistoryListProvider.notifier).loadHistory();
                    ref
                        .read(ProviderUserDetails.showHistorySidebar.notifier)
                        .state = true;
                  },
                  value: 'history',
                  child: Row(
                    children: [
                      const Icon(Icons.history_sharp,
                          color: AppColor.colorGreen),
                      const SizedBox(width: 8),
                      popMenuText('History')
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    LogOutUser.logUserOut(ref, context);
                  },
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 8),
                      popMenuText('Log-Out')
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            const SafeArea(child: ChatPreview()),
            AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                right: ref.watch(ProviderUserDetails.showHistorySidebar)
                    ? 0
                    : -sidebarWidth,
                top: 0,
                bottom: 0,
                width: sidebarWidth,
                child: const HistorySidebarView()),
            Positioned(
              left: _fabPosition.dx,
              top: _fabPosition.dy,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: FloatingActionButton(
                  backgroundColor: AppColor.colorBlue,
                  onPressed: _clearChatAndResetPdf,
                  child: const Icon(
                    Icons.add,
                    size: 39,
                    color: AppColor.colorWhite,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class ProviderUserDetails {
  static final holdUserName = StateProvider((ref) => '');
  static final holdUserId = StateProvider((ref) => '');
  static final showHistorySidebar = StateProvider((ref) => false);
}

class LogOutUser {
  static logUserOut(WidgetRef ref, BuildContext context) async {
    await Pref.setStringValue(tokenKey, '');
    await Pref.setStringValue(userNameKey, '');
    // Clear PDF history on logout
    // await Pref.setStringListValue(pdfIdListKey, []);
    // Also clear all individual last question entries
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final allKeys = prefs.getKeys();
    // for (String key in allKeys) {
    //   if (key.startsWith('lastQuestion_')) {
    //     await prefs.remove(key);
    //   }
    // }
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginView(),
      ),
    );
    ref.read(loadingAnimationSpinkit.notifier).state = false;
  }
}



 // leading: Center(
          //   child: AppText.boldText(
          //     " Good",
          //     FontWeight.bold,
          //     fontSize: FontSize.font20,
          //     color: AppColor.colorWhite,
          //   ),
          // ),