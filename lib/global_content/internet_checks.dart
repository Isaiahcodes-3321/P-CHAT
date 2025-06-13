import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final isUserConnected = StateProvider((ref) => false);

class InternetChecks {
  static Future<void> loginInternetCheck(
      WidgetRef ref, BuildContext context) async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      ref.read(isUserConnected.notifier).state = true;
    } else {
      ref.read(isUserConnected.notifier).state = false;
      SnackBarView.showSnackBar(context, 'Internet connection is needed');
    }
  }
}
