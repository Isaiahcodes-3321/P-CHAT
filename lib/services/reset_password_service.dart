import 'package:http/http.dart' as http;
import 'package:p_chat/models/reset_password_model.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'export.dart';

class ResetPasswordApi {
  static Future<void> resetPassword(WidgetRef ref,
      ResetPasswordModel resetPasswordModel, BuildContext context) async {
    final response = await http
        .patch(
          Uri.parse(resetPasswordEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(resetPasswordModel.toJson()),
        )
        .timeout(const Duration(seconds: 50));

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    final message = responseData['message'];
    debugPrint('Response on resetPassword $prettyprint');
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginView(),
        ),
      );
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}
