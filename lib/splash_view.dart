import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: DefaultTextStyle(
          style: const TextStyle(
              fontSize: 60, color: Colors.black, fontWeight: FontWeight.bold),
          child: AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText('P-CHAT'),
              WavyAnimatedText('P-CHAT'),
              WavyAnimatedText('P-CHAT'),
            ],
            isRepeatingAnimation: true,
            onTap: () {
              debugPrint("Tap Event");
            },
          ),
        ),
      ),
    );
  }
}
