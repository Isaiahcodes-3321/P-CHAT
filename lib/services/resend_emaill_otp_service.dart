import 'package:http/http.dart' as http;
import 'package:p_chat/models/resend_email_otp.dart';
import 'export.dart';

class ResendEmailOtpApi {
  static Future<void> resendOtp(WidgetRef ref, ResendEmailModel resendOtpModel,
      BuildContext context) async {
    final response = await http
        .post(
          Uri.parse(resendVerifyEmailEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(resendOtpModel.toJson()),
        )
        .timeout(const Duration(seconds: 50));

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    final message = responseData['message'];
        debugPrint('Response on resend email otp $prettyprint');


    if (response.statusCode == 200 || response.statusCode == 201) {
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}
