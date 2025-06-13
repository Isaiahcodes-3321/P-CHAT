import 'package:http/http.dart' as http;
import 'package:p_chat/screens/chat_screen/chat_view.dart';
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
    
    String message;
    if (responseData.containsKey('detail') && responseData['detail'] is Map && responseData['detail'].containsKey('message')) {
      message = responseData['detail']['message'];
    } else if (responseData.containsKey('message')) {
      message = responseData['message'];
    } else {
      message = 'Unknown error occurred';
    }

    debugPrint('Response on login $prettyprint');

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ChatView(),
        ),
      );
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      debugPrint('Failed ${response.statusCode}');
      EndpointUpdateUI.updateUi(message, ref, context);
      debugPrint('Failed ${response.statusCode}');
    }
  }
}


class EndpointUpdateUI {
  static updateUi(String message, WidgetRef ref, BuildContext context) {
    ref.read(loadingAnimationSpinkit.notifier).state = false;
    SnackBarView.showSnackBar(context, message);
  }
}
