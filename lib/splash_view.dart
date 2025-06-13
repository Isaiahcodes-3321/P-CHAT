import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';

// class SplashView extends ConsumerStatefulWidget {
//   const SplashView({Key? key}) : super(key: key);

//   @override
//   ConsumerState<SplashView> createState() => _SplashViewState();
// }

// class _SplashViewState extends ConsumerState<SplashView> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Future.delayed(const Duration(seconds: 13), () {
//       navigate();
//     });
//   }

//   navigate() {
//     Navigator.push<void>(
//       context,
//       MaterialPageRoute<void>(
//         builder: (BuildContext context) => const LoginView(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.colorBlueBlack,
//       body: Center(
//         child: DefaultTextStyle(
//           style: TextStyle(
//               fontFamily: AppText.familyFont,
//               fontSize: 60,
//               color: AppColor.colorWhite,
//               fontWeight: FontWeight.bold),
//           child: AnimatedTextKit(
//             animatedTexts: [
//               WavyAnimatedText('P-CHAT'),
//               WavyAnimatedText('P-CHAT'),
//               WavyAnimatedText('P-CHAT'),
//             ],
//             isRepeatingAnimation: true,
//             onTap: () {
//               debugPrint("Tap Event");
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }








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
      navigate();
    });
  }

  navigate() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginView(),
      ),
    );
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