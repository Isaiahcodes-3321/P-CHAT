import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
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
      return 'Good morning';
    } else if (hour >= 12 && hour < 16) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorBlueBlack,
      appBar: AppBar(
        leading: SizedBox(),
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
      body: const Center(child: Text('Chat Screen')),
    );
  }
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
