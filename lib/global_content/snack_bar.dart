import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';

class SnackBarView {
  static void showSnackBar(BuildContext context, String text, {int sec = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColor.colorWhite,
        content: AppText.mediumText(text, FontWeight.bold),
        duration: Duration(seconds: sec),
      ),
    );
  }
}

/// value holding loading animation across app
final loadingAnimationSpinkit = StateProvider((ref) => false);
Widget loadingAnimation() {
  return const SpinKitWaveSpinner(
    color: AppColor.colorWhite,
  );
}
