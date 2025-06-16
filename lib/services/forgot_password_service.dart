import 'package:http/http.dart' as http;
import 'package:p_chat/models/forgot_password_model.dart';
import 'package:p_chat/screens/auth_screen/forgot_password/newpassword.dart';
import 'export.dart';

class ForgotPasswordApi {
  static Future<void> userForgotPassword(WidgetRef ref,
      ForgotPasswordModel forgotPasswordModel, BuildContext context) async {
    final response = await http
        .post(
          Uri.parse(forgotPasswordEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(forgotPasswordModel.toJson()),
        )
        .timeout(const Duration(seconds: 50));

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    String message;
    if (responseData.containsKey('detail') &&
        responseData['detail'] is Map &&
        responseData['detail'].containsKey('message')) {
      message = responseData['detail']['message'];
    } else if (responseData.containsKey('message')) {
      message = responseData['message'];
    } else {
      message = 'Unknown error occurred';
    }
    debugPrint('Response on forgot Password $prettyprint');

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const NewPasswordView(),
        ),
      );
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}
