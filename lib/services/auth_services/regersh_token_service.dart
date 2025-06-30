import 'package:http/http.dart' as http;
import '../export.dart';

class RefreshTokenApi {
  static Future<void> refreshToken(WidgetRef ref, BuildContext context) async {
    final response = await http
        .post(
          Uri.parse(registerEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}),
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
    debugPrint('Response on refresh token $prettyprint');

    if (response.statusCode == 200 || response.statusCode == 201) {
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}
