import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'package:p_chat/screens/chat_screen/chat_input.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'package:p_chat/srorage/pref_storage.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning ${ref.watch(ProviderUserDetails.holdUserName)}';
    } else if (hour >= 12 && hour < 16) {
      return 'Afternoon ${ref.watch(ProviderUserDetails.holdUserName)}';
    } else {
      return 'Evening ${ref.watch(ProviderUserDetails.holdUserName)}';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    String getUserId = await Pref.getStringValue(userIdKey);
    String getUserName = await Pref.getStringValue(userNameKey);
    ref.read(ProviderUserDetails.holdUserId.notifier).state = getUserId;
    ref.read(ProviderUserDetails.holdUserName.notifier).state = getUserName;
  }

  bool _showHistorySidebar = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.7; 

    return Scaffold(
        backgroundColor: AppColor.colorBlueBlack,
        appBar: AppBar(
          leading: Center(
            child: AppText.boldText(
              "  Good",
              FontWeight.bold,
              fontSize: FontSize.font20,
              color: AppColor.colorWhite,
            ),
          ),
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
                    setState(() {
                      _showHistorySidebar = true;
                    });
                  },
                  value: 'history',
                  child: const Row(
                    children: [
                      Icon(Icons.history_sharp, color: AppColor.colorGreen),
                      SizedBox(width: 8),
                      Text('History'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    LogOutUser.logUserOut(ref, context);
                  },
                  value: 'logout',
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Log-Out'),
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
              right: _showHistorySidebar ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Material(
                elevation: 8.0,
                child: Container(
                  color: AppColor.colorWhite,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColor.colorBlueBlack),
                          onPressed: () {
                            setState(() {
                              _showHistorySidebar = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: AppText.boldText(
                            "History Content",
                            FontWeight.bold,
                            fontSize: FontSize.font20,
                            color: AppColor.colorBlueBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
        // const SafeArea(child: ChatPreview()),
        );
  }
}

class ProviderUserDetails {
  static final holdUserName = StateProvider((ref) => '');
  static final holdUserId = StateProvider((ref) => '');
}

class LogOutUser {
  static logUserOut(WidgetRef ref, BuildContext context) {
    Pref.setStringValue(tokenKey, '');
    Pref.setStringValue(userNameKey, '');
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginView(),
      ),
    );
    ref.read(loadingAnimationSpinkit.notifier).state = false;
  }
}
