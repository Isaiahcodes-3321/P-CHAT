import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SnackBarView {
  static void showSnackBar(BuildContext context, String text, {int sec = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColor.colorWhite,
        content: AppText.mediumText(text, FontWeight.bold),
        duration: Duration(seconds: sec),
      ),
    );
  }
}

class ShowMaterialBanner {
  static void materialBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: AppText.mediumText('Click to update APK now', FontWeight.bold),
        backgroundColor: AppColor.colorWhite,
        // leading: Icon(Icons.info, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              final Uri url = Uri.parse(apkLink);
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            child: const Text(
              'UPDATE',
              style: TextStyle(
                  color: AppColor.colorBlue,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
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
