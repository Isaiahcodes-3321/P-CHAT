


import 'package:http/http.dart' as http;
import 'package:p_chat/models/verify_emailotp_model.dart';
import 'export.dart';

class VerifyEmailOtpApi {
  static Future<void> verifyOtp(
      WidgetRef ref,  VerifyEmailOtpModel verifyMailOtpModel, BuildContext context) async {
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
    final message = responseData['message'];
    debugPrint('Response on verify email otp $prettyprint');

    if (response.statusCode == 200 || response.statusCode == 201) {
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}