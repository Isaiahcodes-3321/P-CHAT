
import 'package:http/http.dart' as http;
import 'export.dart';


class LoginApi {
  static Future<void> userLogin(
      WidgetRef ref, LoginModel loginModel, BuildContext context) async {
    final response = await http
        .post(
          Uri.parse(loginEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(loginModel.toJson()),
        )
        .timeout(const Duration(seconds: 50));

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    final message = responseData['message'];
        debugPrint('Response on login $prettyprint');


    if (response.statusCode == 200 || response.statusCode == 201) {
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}

class EndpointUpdateUI {
  static updateUi(String message, WidgetRef ref, BuildContext context) {
    ref.read(loadingAnimationSpinkit.notifier).state = false;
    SnackBarView.showSnackBar(context, message);
  }
}
