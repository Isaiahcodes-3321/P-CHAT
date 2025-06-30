import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'package:p_chat/screens/chat_screen/chat_view.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'package:p_chat/srorage/pref_storage.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 7), () {
      tokenCheck();
    });
  }

  tokenCheck() async {
    try {
      String token = await Pref.getStringValue(tokenKey);
      String yourToken = token.trim();
      debugPrint('Token its $yourToken');

      if (yourToken.isEmpty || yourToken == 'null' || yourToken.length < 20) {
        debugPrint('User token its empty or invalid token :$yourToken');
        navigateToLogin();
        return;
      }

      try {
        bool hasExpired = JwtDecoder.isExpired(yourToken);
        debugPrint('Have token expire ? : $hasExpired');

        if (hasExpired) {
          navigateToLogin();
        } else {
          navigateToChatScreen();
        }
      } catch (jwtError) {
        debugPrint('Invalid token format, navigating to login $jwtError');
        navigateToLogin();
      }
    } catch (e) {
      debugPrint('Error in tokenCheck: $e');
      navigateToLogin();
    }
  }

  navigateToChatScreen() {
    if (mounted) {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ChatView(),
        ),
      );
    }
  }

  navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorBlueBlack,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText(
                  'P-',
                  textStyle: TextStyle(
                    fontFamily: AppText.familyFont,
                    fontSize: 60,
                    color: AppColor.colorWhite,
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
                    fontSize: 60,
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
    );
  }
}
