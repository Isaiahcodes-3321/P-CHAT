import 'package:http/http.dart' as http;
import 'package:p_chat/models/verify_emailotp_model.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'export.dart';

class VerifyEmailOtpApi {
  static Future<void> verifyOtp(WidgetRef ref,
      VerifyEmailOtpModel verifyMailOtpModel, BuildContext context) async {
    final response = await http
        .post(
          Uri.parse(verifyOTPEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(verifyMailOtpModel.toJson()),
        )
        .timeout(const Duration(seconds: 50));

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    debugPrint('Response on verify email otp $prettyprint');

    String message;
    if (responseData.containsKey('detail') &&
        responseData['detail'] is Map<String, dynamic> &&
        responseData['detail'].containsKey('message')) {
      message = responseData['detail']['message'] as String;
    } else if (responseData.containsKey('message')) {
      message = responseData['message'] as String;
    } else {
      message = 'An unknown error occurred';
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      Pref.setStringValue(rememberPasswordKey, '');
      Pref.setStringValue(rememberEmailKey, '');
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginView(),
        ),
      );
      ref.read(loadingAnimationSpinkit.notifier).state = false;
      // EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}
